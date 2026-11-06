"""Consumer order placement.

Catalog stays fail-closed until ``QOSHNI_CONSUMER_CATALOG_ENABLED``. When the SQL
catalog is wired, stock holds use ``consumer_catalog_inventory`` in the same
transaction. The in-memory ledger remains only for test catalog overrides.
"""

from __future__ import annotations

import uuid

from fastapi import APIRouter, Depends, Header
from fastapi.responses import JSONResponse
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from app.api.deps.access import get_current_principal
from app.api.deps.checkout import get_consumer_catalog_authority
from app.api.schemas.order_placement import (
    OrderLineSnapshotView,
    OrderPlacementErrorResponse,
    PlaceOrderRequest,
    PlaceOrderResponse,
)
from app.core.database import get_db
from app.services.auth.principal import AuthenticatedPrincipal
from app.services.checkout.catalog_authority import ConsumerCatalogAuthority
from app.services.checkout.checkout_quote_service import validate_quote_for_placement
from app.services.checkout.inventory_reservation_service import InventoryReservationService
from app.services.checkout.order_placement_service import (
    OrderPlacementError,
    OrderPlacementErrorCode,
    OrderPlacementDependencies,
    PlaceOrderCommand,
    PlaceOrderSuccess,
    place_order,
    place_order_request_fingerprint,
)
from app.services.checkout.sql_catalog_authority import SqlConsumerCatalogAuthority
from app.services.checkout.sql_inventory import SqlCatalogInventoryService
from app.services.checkout.sql_order_repository import (
    SqlAlchemyOrderPlacementStore,
    SqlOrderLifecycleService,
    is_idempotency_unique_violation,
)
from app.services.checkout.order_placement_store import IdempotencyScope
from app.services.checkout.reservation_maintenance import sweep_stale_reservations

router = APIRouter(prefix="/orders", tags=["orders"])

# Shared only by test catalog overrides. The SQL catalog path builds a
# session-scoped ``SqlCatalogInventoryService`` per request.
_inventory_service = InventoryReservationService()


def _inventory_for(session: Session, catalog: ConsumerCatalogAuthority):
    if isinstance(catalog, SqlConsumerCatalogAuthority):
        return SqlCatalogInventoryService(session)
    return _inventory_service


def _replay_idempotent_order(
    session: Session,
    command: PlaceOrderCommand,
) -> PlaceOrderSuccess | OrderPlacementError | None:
    """After a unique-key conflict, return the committed order or a 409."""
    store = SqlAlchemyOrderPlacementStore(session)
    existing = store.get_idempotency(
        IdempotencyScope(
            buyer_user_id=command.buyer_user_id,
            operation="place_order",
            idempotency_key=command.idempotency_key.strip(),
        )
    )
    if existing is None:
        return None
    if existing.request_fingerprint != place_order_request_fingerprint(command):
        return OrderPlacementError(
            code=OrderPlacementErrorCode.IDEMPOTENCY_CONFLICT,
            message="Idempotency key was already used with a different request.",
        )
    order = store.get_order(existing.order_id)
    if order is None:
        return None
    return PlaceOrderSuccess(order=order, idempotent_replay=True)


def _error_status(code: OrderPlacementErrorCode) -> int:
    if code in {
        OrderPlacementErrorCode.VALIDATION_FAILED,
        OrderPlacementErrorCode.STALE_QUOTE,
        OrderPlacementErrorCode.INSUFFICIENT_STOCK,
        OrderPlacementErrorCode.UNSUPPORTED_MULTI_BUSINESS,
    }:
        return 400
    if code == OrderPlacementErrorCode.IDEMPOTENCY_CONFLICT:
        return 409
    if code in {
        OrderPlacementErrorCode.AUTHORITATIVE_CATALOG_UNAVAILABLE,
        OrderPlacementErrorCode.AUTHORITATIVE_INVENTORY_UNAVAILABLE,
    }:
        return 503
    return 400


def _order_response(success: PlaceOrderSuccess) -> PlaceOrderResponse:
    order = success.order
    return PlaceOrderResponse(
        order_id=order.order_id,
        status=order.status,
        payment_status=order.payment_status,
        fulfillment_status=order.fulfillment_status,
        currency_code=order.currency_code,
        subtotal_minor=order.subtotal_minor,
        total_minor=order.total_minor,
        checkout_correlation_id=order.checkout_correlation_id,
        idempotent_replay=success.idempotent_replay,
        created_at=order.created_at,
        lines=[
            OrderLineSnapshotView(
                business_stable_id=line.business_stable_id,
                catalog_item_stable_id=line.catalog_item_stable_id,
                title_snapshot=line.title_snapshot,
                quantity=line.quantity,
                unit_price_minor=line.unit_price_minor,
                line_subtotal_minor=line.line_subtotal_minor,
                currency_code=line.currency_code,
            )
            for line in order.lines
        ],
    )


def _quote_validator(session: Session, catalog: ConsumerCatalogAuthority):
    def validate(command: PlaceOrderCommand, fingerprint: str) -> OrderPlacementError | None:
        if command.server_quote_id is None or command.server_quote_revision is None:
            return OrderPlacementError(
                code=OrderPlacementErrorCode.STALE_QUOTE,
                message="Server quote is required.",
            )
        try:
            quote_id = uuid.UUID(command.server_quote_id)
        except ValueError:
            return OrderPlacementError(
                code=OrderPlacementErrorCode.STALE_QUOTE,
                message="Server quote identifier is invalid.",
            )
        error = validate_quote_for_placement(
            session,
            buyer_user_id=command.buyer_user_id,
            server_quote_id=quote_id,
            server_quote_revision=command.server_quote_revision,
            request_fingerprint=fingerprint,
            fulfillment_type=command.fulfillment_type,
            lines=command.lines,
            catalog=catalog,
        )
        if error is None:
            return None
        return OrderPlacementError(
            code=OrderPlacementErrorCode.STALE_QUOTE,
            message=error.message,
        )

    return validate


@router.post(
    "",
    response_model=PlaceOrderResponse,
    responses={
        400: {"model": OrderPlacementErrorResponse},
        409: {"model": OrderPlacementErrorResponse},
        503: {"model": OrderPlacementErrorResponse},
    },
)
def post_place_order(
    payload: PlaceOrderRequest,
    session: Session = Depends(get_db),
    principal: AuthenticatedPrincipal = Depends(get_current_principal),
    catalog: ConsumerCatalogAuthority = Depends(get_consumer_catalog_authority),
    idempotency_key: str | None = Header(default=None, alias="Idempotency-Key"),
) -> PlaceOrderResponse | JSONResponse:
    sweep_stale_reservations(session, worker_id="order-placement", record=False)
    session.commit()

    if not idempotency_key or not idempotency_key.strip():
        return JSONResponse(
            status_code=400,
            content=OrderPlacementErrorResponse(
                code="validation_failed",
                message="Idempotency-Key header is required.",
            ).model_dump(),
        )

    command = PlaceOrderCommand(
        buyer_user_id=principal.user_id,
        idempotency_key=idempotency_key.strip(),
        fulfillment_type=payload.fulfillment_type,
        checkout_correlation_id=payload.checkout_correlation_id,
        server_quote_id=payload.server_quote_id,
        server_quote_revision=payload.server_quote_revision,
        lines=payload.lines,
        client_submitted_total_minor=payload.client_submitted_total_minor,
    )
    deps = OrderPlacementDependencies(
        catalog=catalog,
        store=SqlAlchemyOrderPlacementStore(session),
        inventory=_inventory_for(session, catalog),
        validate_quote=_quote_validator(session, catalog),
    )
    result = place_order(command, deps)
    if isinstance(result, OrderPlacementError):
        session.rollback()
        return JSONResponse(
            status_code=_error_status(result.code),
            content=OrderPlacementErrorResponse(
                code=result.code.value,
                message=result.message,
            ).model_dump(mode="json"),
        )
    assert isinstance(result, PlaceOrderSuccess)
    if not result.idempotent_replay:
        try:
            session.commit()
        except IntegrityError as exc:
            session.rollback()
            if not is_idempotency_unique_violation(exc):
                raise
            replayed = _replay_idempotent_order(session, command)
            if isinstance(replayed, PlaceOrderSuccess):
                return _order_response(replayed)
            if isinstance(replayed, OrderPlacementError):
                return JSONResponse(
                    status_code=_error_status(replayed.code),
                    content=OrderPlacementErrorResponse(
                        code=replayed.code.value,
                        message=replayed.message,
                    ).model_dump(mode="json"),
                )
            raise
    return _order_response(result)


@router.post(
    "/{order_id}/cancel",
    response_model=PlaceOrderResponse,
    responses={404: {"model": OrderPlacementErrorResponse}},
)
def post_cancel_order(
    order_id: uuid.UUID,
    session: Session = Depends(get_db),
    principal: AuthenticatedPrincipal = Depends(get_current_principal),
) -> PlaceOrderResponse | JSONResponse:
    sweep_stale_reservations(session, worker_id="order-cancel", record=False)
    session.commit()
    lifecycle = SqlOrderLifecycleService(session)
    record = lifecycle.cancel_order(buyer_user_id=principal.user_id, order_id=order_id)
    if record is None:
        session.rollback()
        return JSONResponse(
            status_code=404,
            content=OrderPlacementErrorResponse(
                code="not_found",
                message="Order not found or cannot be cancelled.",
            ).model_dump(),
        )
    session.commit()
    return PlaceOrderResponse(
        order_id=record.order_id,
        status=record.status,
        payment_status=record.payment_status,
        fulfillment_status=record.fulfillment_status,
        currency_code=record.currency_code,
        subtotal_minor=record.subtotal_minor,
        total_minor=record.total_minor,
        checkout_correlation_id=record.checkout_correlation_id,
        idempotent_replay=True,
        created_at=record.created_at,
        lines=[
            OrderLineSnapshotView(
                business_stable_id=line.business_stable_id,
                catalog_item_stable_id=line.catalog_item_stable_id,
                title_snapshot=line.title_snapshot,
                quantity=line.quantity,
                unit_price_minor=line.unit_price_minor,
                line_subtotal_minor=line.line_subtotal_minor,
                currency_code=line.currency_code,
            )
            for line in record.lines
        ],
    )

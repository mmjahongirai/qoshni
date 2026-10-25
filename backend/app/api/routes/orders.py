"""Consumer order placement (fail-closed until catalog authority exists)."""

from __future__ import annotations

import uuid

from fastapi import APIRouter, Depends, Header
from fastapi.responses import JSONResponse
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
)
from app.services.checkout.sql_order_repository import (
    SqlAlchemyOrderPlacementStore,
    SqlOrderLifecycleService,
)

router = APIRouter(prefix="/orders", tags=["orders"])

_inventory_service = InventoryReservationService()


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
    if code == OrderPlacementErrorCode.AUTHORITATIVE_CATALOG_UNAVAILABLE:
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


def _quote_validator(session: Session):
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
        inventory=_inventory_service,
        validate_quote=_quote_validator(session),
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
        session.commit()
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

"""Place-order orchestration with idempotency and inventory holds."""

from __future__ import annotations

import uuid
from dataclasses import dataclass
from enum import StrEnum
from typing import Callable, Protocol

from app.api.schemas.checkout_preparation import CheckoutCartLineRequest
from app.domain.checkout_fulfillment import CheckoutFulfillmentType
from app.domain.checkout_limits import CHECKOUT_CURRENCY_UZS
from app.domain.order_lifecycle import (
    ConsumerOrderFulfillmentStatus,
    ConsumerOrderPaymentStatus,
    ConsumerOrderStatus,
)
from app.services.checkout.catalog_authority import ConsumerCatalogAuthority
from app.services.checkout.inventory_reservation_service import (
    InventoryReservationService,
    SkuKey,
)
from app.services.checkout.order_placement_store import (
    ConsumerOrderRecord,
    IdempotencyRecord,
    IdempotencyScope,
    InMemoryOrderPlacementStore,
    OrderLineSnapshot,
    fingerprint_place_order_request,
)
from app.services.checkout.preparation_service import validate_prepare_request
from app.api.schemas.checkout_preparation import CheckoutPrepareRequest


class OrderPlacementErrorCode(StrEnum):
    VALIDATION_FAILED = "validation_failed"
    UNAUTHORIZED = "unauthorized"
    AUTHORITATIVE_CATALOG_UNAVAILABLE = "authoritative_catalog_unavailable"
    STALE_QUOTE = "stale_quote"
    INSUFFICIENT_STOCK = "insufficient_stock"
    IDEMPOTENCY_CONFLICT = "idempotency_conflict"
    UNSUPPORTED_MULTI_BUSINESS = "unsupported_multi_business"


@dataclass(frozen=True, slots=True)
class OrderPlacementError:
    code: OrderPlacementErrorCode
    message: str


@dataclass(frozen=True, slots=True)
class PlaceOrderCommand:
    buyer_user_id: uuid.UUID
    idempotency_key: str
    fulfillment_type: CheckoutFulfillmentType
    checkout_correlation_id: str
    server_quote_id: str | None
    server_quote_revision: int | None
    lines: list[CheckoutCartLineRequest]
    client_submitted_total_minor: int | None


@dataclass(frozen=True, slots=True)
class PlaceOrderSuccess:
    order: ConsumerOrderRecord
    idempotent_replay: bool


class OrderPlacementStore(Protocol):
    def get_idempotency(self, scope: IdempotencyScope) -> IdempotencyRecord | None: ...

    def get_order(self, order_id: uuid.UUID) -> ConsumerOrderRecord | None: ...

    def save_order(self, order: ConsumerOrderRecord) -> None: ...

    def save_idempotency(self, record: IdempotencyRecord) -> None: ...


@dataclass
class OrderPlacementDependencies:
    catalog: ConsumerCatalogAuthority
    store: OrderPlacementStore
    inventory: InventoryReservationService
    validate_quote: Callable[[PlaceOrderCommand, str], OrderPlacementError | None] | None = None


def _request_fingerprint(command: PlaceOrderCommand) -> str:
    payload = {
        "fulfillment_type": command.fulfillment_type.value,
        "checkout_correlation_id": command.checkout_correlation_id,
        "server_quote_id": command.server_quote_id,
        "server_quote_revision": command.server_quote_revision,
        "lines": [
            {
                "business_stable_id": line.business_stable_id,
                "catalog_item_stable_id": line.catalog_item_stable_id,
                "quantity": line.quantity,
            }
            for line in command.lines
        ],
    }
    return fingerprint_place_order_request(payload)


def place_order(
    command: PlaceOrderCommand,
    deps: OrderPlacementDependencies,
) -> PlaceOrderSuccess | OrderPlacementError:
    if not command.idempotency_key.strip():
        return OrderPlacementError(
            code=OrderPlacementErrorCode.VALIDATION_FAILED,
            message="Idempotency key is required.",
        )

    validation_payload = CheckoutPrepareRequest(
        fulfillment_type=command.fulfillment_type,
        lines=command.lines,
        client_submitted_total_minor=command.client_submitted_total_minor,
    )
    validation = validate_prepare_request(validation_payload)
    if validation is not None:
        return OrderPlacementError(
            code=OrderPlacementErrorCode.VALIDATION_FAILED,
            message=validation.message,
        )

    scope = IdempotencyScope(
        buyer_user_id=command.buyer_user_id,
        operation="place_order",
        idempotency_key=command.idempotency_key.strip(),
    )
    fingerprint = _request_fingerprint(command)
    existing = deps.store.get_idempotency(scope)
    if existing is not None:
        if existing.request_fingerprint != fingerprint:
            return OrderPlacementError(
                code=OrderPlacementErrorCode.IDEMPOTENCY_CONFLICT,
                message="Idempotency key was already used with a different request.",
            )
        order = deps.store.get_order(existing.order_id)
        if order is None:
            return OrderPlacementError(
                code=OrderPlacementErrorCode.VALIDATION_FAILED,
                message="Idempotency record is corrupt.",
            )
        return PlaceOrderSuccess(order=order, idempotent_replay=True)

    if not deps.catalog.is_operational():
        return OrderPlacementError(
            code=OrderPlacementErrorCode.AUTHORITATIVE_CATALOG_UNAVAILABLE,
            message=(
                "Authoritative consumer catalog, pricing, and inventory are not "
                "available on the backend."
            ),
        )

    if command.server_quote_id is None or command.server_quote_revision is None:
        return OrderPlacementError(
            code=OrderPlacementErrorCode.STALE_QUOTE,
            message="A server-issued checkout quote is required for placement.",
        )

    if deps.validate_quote is not None:
        quote_error = deps.validate_quote(command, fingerprint)
        if quote_error is not None:
            return quote_error

    businesses = {line.business_stable_id for line in command.lines}
    if len(businesses) > 1:
        return OrderPlacementError(
            code=OrderPlacementErrorCode.UNSUPPORTED_MULTI_BUSINESS,
            message="Multi-business placement is not supported yet.",
        )

    snapshots: list[OrderLineSnapshot] = []
    reservation_ids: list[uuid.UUID] = []
    order_id = uuid.uuid4()

    for line in command.lines:
        authority = deps.catalog.resolve_line(
            business_stable_id=line.business_stable_id,
            catalog_item_stable_id=line.catalog_item_stable_id,
            requested_quantity=line.quantity,
        )
        if authority is None:
            return OrderPlacementError(
                code=OrderPlacementErrorCode.VALIDATION_FAILED,
                message="One or more lines are not purchasable.",
            )
        if authority.unit_price_minor < 0:
            return OrderPlacementError(
                code=OrderPlacementErrorCode.VALIDATION_FAILED,
                message="Invalid authoritative price.",
            )
        if line.quantity > authority.available_quantity:
            return OrderPlacementError(
                code=OrderPlacementErrorCode.INSUFFICIENT_STOCK,
                message="Insufficient stock for one or more lines.",
            )
        subtotal = authority.unit_price_minor * line.quantity
        snapshots.append(
            OrderLineSnapshot(
                business_stable_id=line.business_stable_id,
                catalog_item_stable_id=line.catalog_item_stable_id,
                title_snapshot=authority.title_snapshot,
                quantity=line.quantity,
                unit_price_minor=authority.unit_price_minor,
                line_subtotal_minor=subtotal,
                currency_code=authority.currency_code,
            )
        )

    for line in command.lines:
        sku = SkuKey(
            business_stable_id=line.business_stable_id,
            catalog_item_stable_id=line.catalog_item_stable_id,
        )
        reservation = deps.inventory.reserve_for_order(
            sku=sku,
            quantity=line.quantity,
            order_id=order_id,
        )
        if reservation is None:
            return OrderPlacementError(
                code=OrderPlacementErrorCode.INSUFFICIENT_STOCK,
                message="Concurrent stock change prevented reservation.",
            )
        reservation_ids.append(reservation.reservation_id)

    subtotal_minor = sum(line.line_subtotal_minor for line in snapshots)
    total_minor = subtotal_minor
    if command.client_submitted_total_minor is not None and (
        command.client_submitted_total_minor != total_minor
    ):
        _ = command.client_submitted_total_minor  # explicitly ignored for authority

    quote_uuid: uuid.UUID | None = None
    try:
        quote_uuid = uuid.UUID(command.server_quote_id)
    except (ValueError, TypeError):
        return OrderPlacementError(
            code=OrderPlacementErrorCode.STALE_QUOTE,
            message="Server quote identifier is invalid.",
        )

    order = ConsumerOrderRecord(
        order_id=order_id,
        buyer_user_id=command.buyer_user_id,
        status=ConsumerOrderStatus.PENDING_ACCEPTANCE,
        payment_status=ConsumerOrderPaymentStatus.UNPAID,
        fulfillment_status=ConsumerOrderFulfillmentStatus.NOT_STARTED,
        currency_code=CHECKOUT_CURRENCY_UZS,
        subtotal_minor=subtotal_minor,
        total_minor=total_minor,
        checkout_correlation_id=command.checkout_correlation_id,
        checkout_quote_id=quote_uuid,
        idempotency_key=command.idempotency_key.strip(),
        lines=snapshots,
        reservation_ids=reservation_ids,
    )
    deps.store.save_order(order)
    deps.store.save_idempotency(
        IdempotencyRecord(
            scope=scope,
            request_fingerprint=fingerprint,
            order_id=order_id,
        )
    )
    return PlaceOrderSuccess(order=order, idempotent_replay=False)

"""SQLAlchemy persistence for orders, idempotency and reservations."""

from __future__ import annotations

import uuid
from datetime import UTC, datetime

from sqlalchemy import select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from app.db.models.consumer_orders import (
    ConsumerOrder,
    ConsumerOrderItem,
    ConsumerOrderStatusEvent,
    InventoryReservation,
    OrderIdempotencyRecord,
)
from app.domain.inventory_reservation import InventoryReservationStatus
from app.domain.order_lifecycle import (
    ConsumerOrderFulfillmentStatus,
    ConsumerOrderPaymentStatus,
    ConsumerOrderStatus,
)
from app.services.checkout.order_placement_store import (
    ConsumerOrderRecord,
    IdempotencyRecord,
    IdempotencyScope,
    OrderLineSnapshot,
)


def _to_record(order: ConsumerOrder) -> ConsumerOrderRecord:
    return ConsumerOrderRecord(
        order_id=order.id,
        buyer_user_id=order.buyer_user_id,
        status=ConsumerOrderStatus(order.status),
        payment_status=ConsumerOrderPaymentStatus(order.payment_status),
        fulfillment_status=ConsumerOrderFulfillmentStatus(order.fulfillment_status),
        currency_code=order.currency_code,
        subtotal_minor=order.subtotal_minor,
        total_minor=order.total_minor,
        checkout_correlation_id=order.checkout_correlation_id,
        checkout_quote_id=order.checkout_quote_id,
        idempotency_key=order.idempotency_key,
        lines=[
            OrderLineSnapshot(
                business_stable_id=item.business_stable_id,
                catalog_item_stable_id=item.catalog_item_stable_id,
                title_snapshot=item.title_snapshot,
                quantity=item.quantity,
                unit_price_minor=item.unit_price_minor,
                line_subtotal_minor=item.line_subtotal_minor,
                currency_code=item.currency_code,
            )
            for item in order.items
        ],
        reservation_ids=[res.id for res in order.reservations],
        created_at=order.created_at,
        updated_at=order.updated_at,
    )


class SqlAlchemyOrderPlacementStore:
    def __init__(self, session: Session) -> None:
        self._session = session

    def get_idempotency(self, scope: IdempotencyScope) -> IdempotencyRecord | None:
        row = self._session.scalar(
            select(OrderIdempotencyRecord).where(
                OrderIdempotencyRecord.buyer_user_id == scope.buyer_user_id,
                OrderIdempotencyRecord.operation == scope.operation,
                OrderIdempotencyRecord.idempotency_key == scope.idempotency_key,
            )
        )
        if row is None:
            return None
        return IdempotencyRecord(
            scope=scope,
            request_fingerprint=row.request_fingerprint,
            order_id=row.order_id,
        )

    def get_order(self, order_id: uuid.UUID) -> ConsumerOrderRecord | None:
        order = self._session.get(ConsumerOrder, order_id)
        if order is None:
            return None
        return _to_record(order)

    def save_order(self, order: ConsumerOrderRecord) -> None:
        self.persist_new_order(order)

    def save_idempotency(self, record: IdempotencyRecord) -> None:
        self._session.add(
            OrderIdempotencyRecord(
                buyer_user_id=record.scope.buyer_user_id,
                operation=record.scope.operation,
                idempotency_key=record.scope.idempotency_key,
                request_fingerprint=record.request_fingerprint,
                order_id=record.order_id,
            )
        )

    def persist_new_order(self, order: ConsumerOrderRecord) -> None:
        row = ConsumerOrder(
            id=order.order_id,
            buyer_user_id=order.buyer_user_id,
            checkout_correlation_id=order.checkout_correlation_id,
            checkout_quote_id=order.checkout_quote_id,
            idempotency_key=order.idempotency_key,
            status=order.status.value,
            payment_status=order.payment_status.value,
            fulfillment_status=order.fulfillment_status.value,
            currency_code=order.currency_code,
            subtotal_minor=order.subtotal_minor,
            total_minor=order.total_minor,
        )
        row.items = [
            ConsumerOrderItem(
                business_stable_id=line.business_stable_id,
                catalog_item_stable_id=line.catalog_item_stable_id,
                title_snapshot=line.title_snapshot,
                quantity=line.quantity,
                unit_price_minor=line.unit_price_minor,
                line_subtotal_minor=line.line_subtotal_minor,
                currency_code=line.currency_code,
            )
            for line in order.lines
        ]
        row.status_events = [
            ConsumerOrderStatusEvent(
                from_status=None,
                to_status=order.status.value,
                reason="placed",
            )
        ]
        row.reservations = [
            InventoryReservation(
                id=res_id,
                business_stable_id=line.business_stable_id,
                catalog_item_stable_id=line.catalog_item_stable_id,
                quantity=line.quantity,
                status=InventoryReservationStatus.HELD.value,
            )
            for res_id, line in zip(order.reservation_ids, order.lines, strict=True)
        ]
        self._session.add(row)

    def try_save_idempotency(self, record: IdempotencyRecord) -> bool:
        try:
            self.save_idempotency(record)
            self._session.flush()
            return True
        except IntegrityError:
            self._session.rollback()
            return False


class SqlOrderLifecycleService:
    def __init__(self, session: Session) -> None:
        self._session = session

    def cancel_order(
        self,
        *,
        buyer_user_id: uuid.UUID,
        order_id: uuid.UUID,
        reason: str = "buyer_cancelled",
    ) -> ConsumerOrderRecord | None:
        order = self._session.get(ConsumerOrder, order_id)
        if order is None or order.buyer_user_id != buyer_user_id:
            return None
        current = ConsumerOrderStatus(order.status)
        if current == ConsumerOrderStatus.CANCELLED:
            return _to_record(order)
        from app.domain.order_transitions import can_transition

        if not can_transition(current, ConsumerOrderStatus.CANCELLED):
            return None
        order.status = ConsumerOrderStatus.CANCELLED.value
        order.updated_at = datetime.now(UTC)
        order.status_events.append(
            ConsumerOrderStatusEvent(
                from_status=current.value,
                to_status=ConsumerOrderStatus.CANCELLED.value,
                reason=reason,
            )
        )
        for reservation in order.reservations:
            if reservation.status == InventoryReservationStatus.HELD.value:
                reservation.status = InventoryReservationStatus.RELEASED.value
                reservation.updated_at = datetime.now(UTC)
        self._session.flush()
        return _to_record(order)

    def expire_stale_reservations(self, *, now: datetime | None = None) -> int:
        """Idempotent maintenance hook — invoke from ops/cron when scheduler exists."""
        moment = now or datetime.now(UTC)
        updated = 0
        rows = self._session.scalars(select(InventoryReservation)).all()
        for row in rows:
            if row.status != InventoryReservationStatus.HELD.value:
                continue
            if row.expires_at is not None and row.expires_at <= moment:
                row.status = InventoryReservationStatus.EXPIRED.value
                row.updated_at = moment
                updated += 1
        if updated:
            self._session.flush()
        return updated

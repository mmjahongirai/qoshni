"""SQLAlchemy persistence for orders, idempotency and reservations."""

from __future__ import annotations

import uuid
from dataclasses import dataclass
from datetime import UTC, datetime
from enum import StrEnum

from sqlalchemy import select, update
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from app.db.models.business_onboarding import BusinessOnboardingApplication
from app.services.checkout.sql_inventory import release_reservation_stock
from app.services.search_discovery.stable_ids import stable_id_for_application

from app.db.models.consumer_orders import (
    ConsumerOrder,
    ConsumerOrderItem,
    ConsumerOrderStatusEvent,
    InventoryReservation,
    OrderIdempotencyRecord,
)
from app.domain.inventory_reservation import (
    INVENTORY_RESERVATION_TTL,
    InventoryReservationStatus,
)
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
        hold_until = datetime.now(UTC) + INVENTORY_RESERVATION_TTL
        row.reservations = [
            InventoryReservation(
                id=res_id,
                business_stable_id=line.business_stable_id,
                catalog_item_stable_id=line.catalog_item_stable_id,
                quantity=line.quantity,
                status=InventoryReservationStatus.HELD.value,
                expires_at=hold_until,
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


def is_idempotency_unique_violation(exc: IntegrityError) -> bool:
    """True when the failure is the buyer/operation/key unique constraint."""
    orig = getattr(exc, "orig", None)
    diag = getattr(orig, "diag", None)
    constraint = getattr(diag, "constraint_name", None)
    if constraint == "uq_order_idempotency_buyer_operation_key":
        return True
    text = str(orig if orig is not None else exc).lower()
    return "unique" in text and "order_idempotency" in text


class OrderRejectionOutcome(StrEnum):
    REJECTED = "rejected"
    REPLAY = "replay"
    NOT_FOUND = "not_found"
    INVALID_TRANSITION = "invalid_transition"
    RELEASE_FAILED = "release_failed"


@dataclass(frozen=True, slots=True)
class OrderRejectionResult:
    outcome: OrderRejectionOutcome
    record: ConsumerOrderRecord | None = None


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
        now = datetime.now(UTC)
        held = [
            reservation
            for reservation in order.reservations
            if reservation.status == InventoryReservationStatus.HELD.value
        ]
        for reservation in held:
            restored = release_reservation_stock(
                self._session,
                business_stable_id=reservation.business_stable_id,
                catalog_item_stable_id=reservation.catalog_item_stable_id,
                quantity=reservation.quantity,
            )
            if not restored:
                return None
            reservation.status = InventoryReservationStatus.RELEASED.value
            reservation.updated_at = now
        order.status = ConsumerOrderStatus.CANCELLED.value
        order.updated_at = now
        order.status_events.append(
            ConsumerOrderStatusEvent(
                from_status=current.value,
                to_status=ConsumerOrderStatus.CANCELLED.value,
                reason=reason,
            )
        )
        self._session.flush()
        return _to_record(order)

    def reject_order(
        self,
        *,
        owner_user_id: uuid.UUID,
        business_application_id: uuid.UUID,
        order_id: uuid.UUID,
        reason: str = "business_rejected",
    ) -> OrderRejectionResult:
        """Move ``pending_acceptance`` to ``rejected`` and release held stock.

        Already-rejected orders return the current record and do not release
        again. The caller commits a success and rolls back every other outcome.
        """
        application = self._session.get(BusinessOnboardingApplication, business_application_id)
        if application is None or application.owner_user_id != owner_user_id:
            return OrderRejectionResult(outcome=OrderRejectionOutcome.NOT_FOUND)
        order = self._session.get(ConsumerOrder, order_id)
        if order is None or not order.items:
            return OrderRejectionResult(outcome=OrderRejectionOutcome.NOT_FOUND)
        expected_business = stable_id_for_application(business_application_id)
        if any(item.business_stable_id != expected_business for item in order.items):
            return OrderRejectionResult(outcome=OrderRejectionOutcome.NOT_FOUND)
        current = ConsumerOrderStatus(order.status)
        if current == ConsumerOrderStatus.REJECTED:
            return OrderRejectionResult(
                outcome=OrderRejectionOutcome.REPLAY,
                record=_to_record(order),
            )
        from app.domain.order_transitions import can_transition

        if not can_transition(current, ConsumerOrderStatus.REJECTED):
            return OrderRejectionResult(outcome=OrderRejectionOutcome.INVALID_TRANSITION)
        now = datetime.now(UTC)
        cleaned = reason.strip() or "business_rejected"
        if not self._release_held_reservations(order, now):
            return OrderRejectionResult(outcome=OrderRejectionOutcome.RELEASE_FAILED)
        order.status = ConsumerOrderStatus.REJECTED.value
        order.updated_at = now
        order.status_events.append(
            ConsumerOrderStatusEvent(
                from_status=current.value,
                to_status=ConsumerOrderStatus.REJECTED.value,
                reason=cleaned[:256],
            )
        )
        self._session.flush()
        return OrderRejectionResult(
            outcome=OrderRejectionOutcome.REJECTED,
            record=_to_record(order),
        )

    def _release_held_reservations(self, order: ConsumerOrder, moment: datetime) -> bool:
        held_ids = [
            reservation.id
            for reservation in order.reservations
            if reservation.status == InventoryReservationStatus.HELD.value
        ]
        for reservation_id in held_ids:
            try:
                with self._session.begin_nested():
                    claimed = self._session.execute(
                        update(InventoryReservation)
                        .where(
                            InventoryReservation.id == reservation_id,
                            InventoryReservation.status == InventoryReservationStatus.HELD.value,
                        )
                        .values(
                            status=InventoryReservationStatus.RELEASED.value,
                            updated_at=moment,
                        ),
                        execution_options={"synchronize_session": False},
                    )
                    if claimed.rowcount != 1:
                        raise _ReservationReleaseFailed
                    row = self._session.get(InventoryReservation, reservation_id)
                    if row is None:
                        raise _ReservationReleaseFailed
                    self._session.refresh(row)
                    restored = release_reservation_stock(
                        self._session,
                        business_stable_id=row.business_stable_id,
                        catalog_item_stable_id=row.catalog_item_stable_id,
                        quantity=row.quantity,
                    )
                    if not restored:
                        raise _ReservationReleaseFailed
            except _ReservationReleaseFailed:
                self._session.expire_all()
                return False
        return True

    def expire_stale_reservations(self, *, now: datetime | None = None) -> int:
        """Free stock for holds whose ``expires_at`` has passed.

        Each hold is claimed with a conditional status update before stock is
        released, inside a savepoint. A second worker sees no ``held`` row and
        does not release again. A failed release rolls that savepoint back, so
        the hold stays ``held`` for the next attempt.

        Order status changes only where ``pending_acceptance`` may already move
        to ``expired``. Accepted and other states keep their hold.
        """
        moment = now or datetime.now(UTC)
        if moment.tzinfo is None:
            moment = moment.replace(tzinfo=UTC)
        candidate_ids = list(
            self._session.scalars(
                select(InventoryReservation.id)
                .where(
                    InventoryReservation.status == InventoryReservationStatus.HELD.value,
                    InventoryReservation.expires_at.is_not(None),
                    InventoryReservation.expires_at <= moment,
                )
                .limit(50)
            )
        )
        updated = 0
        for reservation_id in candidate_ids:
            if self._expire_one(reservation_id, moment):
                updated += 1
        return updated

    def _expire_one(self, reservation_id: uuid.UUID, moment: datetime) -> bool:
        preview = self._session.get(InventoryReservation, reservation_id)
        if preview is None or preview.status != InventoryReservationStatus.HELD.value:
            return False
        order = preview.order
        if order is not None and order.status not in {
            ConsumerOrderStatus.PENDING_ACCEPTANCE.value,
            ConsumerOrderStatus.EXPIRED.value,
        }:
            return False
        try:
            with self._session.begin_nested():
                claimed = self._session.execute(
                    update(InventoryReservation)
                    .where(
                        InventoryReservation.id == reservation_id,
                        InventoryReservation.status == InventoryReservationStatus.HELD.value,
                        InventoryReservation.expires_at.is_not(None),
                        InventoryReservation.expires_at <= moment,
                    )
                    .values(
                        status=InventoryReservationStatus.EXPIRED.value,
                        updated_at=moment,
                    ),
                    execution_options={"synchronize_session": False},
                )
                if claimed.rowcount != 1:
                    return False
                self._session.expire(preview)
                row = self._session.get(InventoryReservation, reservation_id)
                if row is None:
                    return False
                restored = release_reservation_stock(
                    self._session,
                    business_stable_id=row.business_stable_id,
                    catalog_item_stable_id=row.catalog_item_stable_id,
                    quantity=row.quantity,
                )
                if not restored:
                    raise _ReservationReleaseFailed
                current_order = row.order
                if (
                    current_order is not None
                    and current_order.status == ConsumerOrderStatus.PENDING_ACCEPTANCE.value
                ):
                    current_order.status = ConsumerOrderStatus.EXPIRED.value
                    current_order.updated_at = moment
                    current_order.status_events.append(
                        ConsumerOrderStatusEvent(
                            from_status=ConsumerOrderStatus.PENDING_ACCEPTANCE.value,
                            to_status=ConsumerOrderStatus.EXPIRED.value,
                            reason="reservation_expired",
                        )
                    )
        except _ReservationReleaseFailed:
            self._session.expire_all()
            return False
        return True


class _ReservationReleaseFailed(Exception):
    """Raised to roll back one reservation savepoint."""

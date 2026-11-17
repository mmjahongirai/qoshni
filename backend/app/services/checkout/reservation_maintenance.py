"""Explicit and request-path expiry of stale inventory holds."""

from __future__ import annotations

from dataclasses import dataclass
from datetime import UTC, datetime

from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.db.models.consumer_catalog import InventoryMaintenanceRun
from app.db.models.consumer_orders import InventoryReservation
from app.domain.inventory_reservation import InventoryReservationStatus
from app.services.checkout.sql_order_repository import SqlOrderLifecycleService


@dataclass(frozen=True, slots=True)
class ReservationMaintenanceStatus:
    overdue_held_count: int
    oldest_overdue_expires_at: datetime | None
    last_run_finished_at: datetime | None
    last_run_outcome: str | None
    last_expired_count: int | None
    last_error_message: str | None


def sweep_stale_reservations(
    session: Session,
    *,
    worker_id: str,
    record: bool,
) -> int:
    """Expire due holds. Recording is for the ops endpoint, not every request."""
    started = datetime.now(UTC)
    try:
        expired = SqlOrderLifecycleService(session).expire_stale_reservations(now=started)
    except Exception as exc:
        if record:
            session.add(
                InventoryMaintenanceRun(
                    worker_id=worker_id[:64],
                    outcome="failed",
                    expired_count=0,
                    error_message=str(exc)[:500],
                    started_at=started,
                    finished_at=datetime.now(UTC),
                )
            )
            session.flush()
        raise
    if record:
        session.add(
            InventoryMaintenanceRun(
                worker_id=worker_id[:64],
                outcome="succeeded",
                expired_count=expired,
                error_message=None,
                started_at=started,
                finished_at=datetime.now(UTC),
            )
        )
        session.flush()
    return expired


def run_recorded_sweep(session: Session, *, worker_id: str) -> int:
    """Expire due holds and store the outcome in a committed maintenance row.

    A failure rolls the sweep back, then stores the error in a new transaction
    so the next iteration can claim the same holds again.
    """
    started = datetime.now(UTC)
    try:
        expired = sweep_stale_reservations(session, worker_id=worker_id, record=False)
        session.add(
            InventoryMaintenanceRun(
                worker_id=worker_id[:64],
                outcome="succeeded",
                expired_count=expired,
                error_message=None,
                started_at=started,
                finished_at=datetime.now(UTC),
            )
        )
        session.commit()
        return expired
    except Exception as exc:
        session.rollback()
        session.add(
            InventoryMaintenanceRun(
                worker_id=worker_id[:64],
                outcome="failed",
                expired_count=0,
                error_message=str(exc)[:500],
                started_at=started,
                finished_at=datetime.now(UTC),
            )
        )
        session.commit()
        raise


def reservation_maintenance_status(session: Session) -> ReservationMaintenanceStatus:
    now = datetime.now(UTC)
    overdue_filter = (
        InventoryReservation.status == InventoryReservationStatus.HELD.value,
        InventoryReservation.expires_at.is_not(None),
        InventoryReservation.expires_at <= now,
    )
    overdue = session.scalar(
        select(func.count()).select_from(InventoryReservation).where(*overdue_filter)
    )
    oldest = session.scalar(
        select(func.min(InventoryReservation.expires_at)).where(*overdue_filter)
    )
    last = session.scalar(
        select(InventoryMaintenanceRun).order_by(InventoryMaintenanceRun.finished_at.desc()).limit(1)
    )
    return ReservationMaintenanceStatus(
        overdue_held_count=int(overdue or 0),
        oldest_overdue_expires_at=oldest,
        last_run_finished_at=None if last is None else last.finished_at,
        last_run_outcome=None if last is None else last.outcome,
        last_expired_count=None if last is None else last.expired_count,
        last_error_message=None if last is None else last.error_message,
    )

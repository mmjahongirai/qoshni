"""Order reject and cancel races (Phase 18 lifecycle).

Each test lets a late request (or reservation sweep) read the order before a
competing transition commits, then finishes the late request. This is the READ COMMITTED order a
PostgreSQL request sees without a row lock. These SQLite tests do not verify
PostgreSQL locking.
"""

from __future__ import annotations

import threading
import uuid
from collections.abc import Generator
from datetime import UTC, datetime, timedelta
from pathlib import Path

import pytest
from sqlalchemy import create_engine, select
from sqlalchemy.engine import Engine
from sqlalchemy.exc import OperationalError
from sqlalchemy.orm import Session

import app.db.models  # noqa: F401
from app.db.base import Base
from app.db.models.consumer_catalog import ConsumerCatalogInventory
from app.db.models.consumer_orders import ConsumerOrder, ConsumerOrderStatusEvent, InventoryReservation
from app.domain.inventory_reservation import InventoryReservationStatus
from app.domain.order_lifecycle import ConsumerOrderStatus
from app.services.checkout.sql_inventory import reserve_catalog_quantity
from app.services.checkout.sql_order_repository import OrderRejectionOutcome, SqlOrderLifecycleService
from tests.test_business_catalog_inventory_wp3 import _pending_hold


@pytest.fixture
def engine(tmp_path: Path) -> Generator[Engine, None, None]:
    database = create_engine(
        f"sqlite:///{(tmp_path / 'lifecycle.db').as_posix()}",
        connect_args={"check_same_thread": False, "timeout": 30},
    )
    Base.metadata.create_all(database)
    yield database
    database.dispose()


def _seed(engine: Engine, *, other_order_reserved: int = 0) -> tuple[uuid.UUID, uuid.UUID, uuid.UUID, uuid.UUID]:
    with Session(engine) as session:
        application_id, owner_id, order_id = _pending_hold(
            session,
            status=ConsumerOrderStatus.PENDING_ACCEPTANCE,
        )
        if other_order_reserved:
            balance = session.scalars(select(ConsumerCatalogInventory)).one()
            assert reserve_catalog_quantity(
                session,
                catalog_item_id=balance.catalog_item_id,
                quantity=other_order_reserved,
            )
        buyer_id = session.get(ConsumerOrder, order_id).buyer_user_id
        session.commit()
    return application_id, owner_id, buyer_id, order_id


def _reject(session: Session, application_id: uuid.UUID, owner_id: uuid.UUID, order_id: uuid.UUID) -> str:
    result = SqlOrderLifecycleService(session).reject_order(
        owner_user_id=owner_id,
        business_application_id=application_id,
        order_id=order_id,
    )
    if result.outcome in {OrderRejectionOutcome.REJECTED, OrderRejectionOutcome.REPLAY}:
        session.commit()
    else:
        session.rollback()
    return result.outcome.value


def _cancel(session: Session, buyer_id: uuid.UUID, order_id: uuid.UUID) -> str | None:
    record = SqlOrderLifecycleService(session).cancel_order(buyer_user_id=buyer_id, order_id=order_id)
    if record is None:
        session.rollback()
        return None
    session.commit()
    return record.status.value


def _state(engine: Engine, order_id: uuid.UUID) -> tuple[str, list[str], int]:
    with Session(engine) as session:
        order = session.get(ConsumerOrder, order_id)
        assert order is not None
        events = list(
            session.scalars(
                select(ConsumerOrderStatusEvent.to_status).where(ConsumerOrderStatusEvent.order_id == order_id)
            )
        )
        reservation = session.scalars(
            select(InventoryReservation).where(InventoryReservation.order_id == order_id)
        ).one()
        assert reservation.status == InventoryReservationStatus.RELEASED.value
        balance = session.scalars(select(ConsumerCatalogInventory)).one()
        assert balance.quantity_on_hand == 5
        return order.status, events, balance.reserved_quantity


def _read_like_service(session: Session, order_id: uuid.UUID, *, reservations: bool) -> ConsumerOrder:
    """Load what the service reads first. The caller must keep the returned object.

    The identity map holds rows weakly; a dropped object would be reloaded fresh
    and hide the stale read this test needs.
    """
    order = session.get(ConsumerOrder, order_id)
    assert order is not None
    _ = list(order.items)
    if reservations:
        _ = list(order.reservations)
    return order


def test_late_reject_after_reject_replays(engine: Engine) -> None:
    application_id, owner_id, _buyer_id, order_id = _seed(engine)
    with Session(engine) as late:
        stale = _read_like_service(late, order_id, reservations=False)  # noqa: F841 — keep the stale row loaded
        with Session(engine) as first:
            assert _reject(first, application_id, owner_id, order_id) == "rejected"
        assert _reject(late, application_id, owner_id, order_id) == "replay"
    status, events, reserved = _state(engine, order_id)
    assert status == ConsumerOrderStatus.REJECTED.value
    assert events == [ConsumerOrderStatus.REJECTED.value]
    assert reserved == 0


def test_late_cancel_after_reject_keeps_other_order_stock(engine: Engine) -> None:
    application_id, owner_id, buyer_id, order_id = _seed(engine, other_order_reserved=2)
    with Session(engine) as late:
        stale = _read_like_service(late, order_id, reservations=True)  # noqa: F841 — keep the stale row loaded
        with Session(engine) as first:
            assert _reject(first, application_id, owner_id, order_id) == "rejected"
        assert _cancel(late, buyer_id, order_id) is None
    status, events, reserved = _state(engine, order_id)
    assert status == ConsumerOrderStatus.REJECTED.value
    assert events == [ConsumerOrderStatus.REJECTED.value]
    # The other order's two units stay reserved.
    assert reserved == 2


def test_late_reject_after_cancel_keeps_cancelled(engine: Engine) -> None:
    application_id, owner_id, buyer_id, order_id = _seed(engine)
    with Session(engine) as late:
        stale = _read_like_service(late, order_id, reservations=False)  # noqa: F841 — keep the stale row loaded
        with Session(engine) as first:
            assert _cancel(first, buyer_id, order_id) == ConsumerOrderStatus.CANCELLED.value
        assert _reject(late, application_id, owner_id, order_id) == "invalid_transition"
    status, events, reserved = _state(engine, order_id)
    assert status == ConsumerOrderStatus.CANCELLED.value
    assert events == [ConsumerOrderStatus.CANCELLED.value]
    assert reserved == 0


def test_late_cancel_after_cancel_returns_cancelled_once(engine: Engine) -> None:
    _application_id, _owner_id, buyer_id, order_id = _seed(engine, other_order_reserved=2)
    with Session(engine) as late:
        stale = _read_like_service(late, order_id, reservations=True)  # noqa: F841 — keep the stale row loaded
        with Session(engine) as first:
            assert _cancel(first, buyer_id, order_id) == ConsumerOrderStatus.CANCELLED.value
        assert _cancel(late, buyer_id, order_id) == ConsumerOrderStatus.CANCELLED.value
    status, events, reserved = _state(engine, order_id)
    assert status == ConsumerOrderStatus.CANCELLED.value
    assert events == [ConsumerOrderStatus.CANCELLED.value]
    assert reserved == 2


def test_parallel_reject_and_cancel_apply_one_transition(tmp_path: Path) -> None:
    for round_number in range(5):
        engine = create_engine(
            f"sqlite:///{(tmp_path / f'parallel-{round_number}.db').as_posix()}",
            connect_args={"check_same_thread": False, "timeout": 30},
        )
        Base.metadata.create_all(engine)
        application_id, owner_id, buyer_id, order_id = _seed(engine, other_order_reserved=2)
        outcomes: list[str | None] = []
        barrier = threading.Barrier(2)

        def run(action: str) -> None:
            barrier.wait()
            for _attempt in range(3):
                try:
                    with Session(engine) as session:
                        if action == "reject":
                            outcomes.append(_reject(session, application_id, owner_id, order_id))
                        else:
                            outcomes.append(_cancel(session, buyer_id, order_id))
                        return
                except OperationalError:
                    continue
            raise AssertionError("transition stayed locked")

        threads = [threading.Thread(target=run, args=(action,)) for action in ("reject", "cancel")]
        for thread in threads:
            thread.start()
        for thread in threads:
            thread.join()

        status, events, reserved = _state(engine, order_id)
        engine.dispose()
        assert len(events) == 1, (outcomes, events)
        assert status == events[0]
        assert status in {ConsumerOrderStatus.REJECTED.value, ConsumerOrderStatus.CANCELLED.value}
        # Only this order's two units are released; the other order keeps two.
        assert reserved == 2, outcomes


def _seed_expired_holds(engine: Engine, *, second_hold: bool, other_order_reserved: int = 0) -> tuple[
    uuid.UUID, uuid.UUID, uuid.UUID, list[uuid.UUID]
]:
    """Pending order with one or two overdue holds; ids are largest hold first."""
    past = datetime.now(UTC) - timedelta(minutes=1)
    with Session(engine) as session:
        application_id, owner_id, order_id = _pending_hold(
            session,
            status=ConsumerOrderStatus.PENDING_ACCEPTANCE,
        )
        first = session.scalars(select(InventoryReservation)).one()
        first.expires_at = past
        balance = session.scalars(select(ConsumerCatalogInventory)).one()
        if second_hold:
            assert reserve_catalog_quantity(session, catalog_item_id=balance.catalog_item_id, quantity=1)
            session.add(
                InventoryReservation(
                    order_id=order_id,
                    business_stable_id=first.business_stable_id,
                    catalog_item_stable_id=first.catalog_item_stable_id,
                    quantity=1,
                    status=InventoryReservationStatus.HELD.value,
                    expires_at=past,
                )
            )
        if other_order_reserved:
            assert reserve_catalog_quantity(
                session,
                catalog_item_id=balance.catalog_item_id,
                quantity=other_order_reserved,
            )
        session.commit()
        hold_ids = list(
            session.scalars(select(InventoryReservation.id).order_by(InventoryReservation.quantity.desc()))
        )
    return application_id, owner_id, order_id, hold_ids


def _read_like_sweep(session: Session, hold_id: uuid.UUID) -> InventoryReservation:
    """Load the hold and its order as the sweep previews them. Keep the result."""
    hold = session.get(InventoryReservation, hold_id)
    assert hold is not None and hold.order is not None
    _ = hold.order.status
    return hold


def _expire(session: Session, hold_id: uuid.UUID) -> bool:
    expired = SqlOrderLifecycleService(session)._expire_one(hold_id, datetime.now(UTC))
    session.commit()
    return expired


def _sweep_state(engine: Engine, order_id: uuid.UUID) -> tuple[str, list[str], list[str], int]:
    with Session(engine) as session:
        order = session.get(ConsumerOrder, order_id)
        assert order is not None
        events = list(
            session.scalars(
                select(ConsumerOrderStatusEvent.to_status).where(ConsumerOrderStatusEvent.order_id == order_id)
            )
        )
        holds = sorted(
            session.scalars(select(InventoryReservation.status).where(InventoryReservation.order_id == order_id))
        )
        balance = session.scalars(select(ConsumerCatalogInventory)).one()
        assert balance.quantity_on_hand == 5
        return order.status, events, holds, balance.reserved_quantity


def test_two_sweeps_over_one_order_write_one_expired_event(engine: Engine) -> None:
    _application_id, _owner_id, order_id, hold_ids = _seed_expired_holds(engine, second_hold=True)
    with Session(engine) as late:
        stale = _read_like_sweep(late, hold_ids[1])  # noqa: F841 — keep the stale order loaded
        with Session(engine) as first:
            assert _expire(first, hold_ids[0]) is True
        assert _expire(late, hold_ids[1]) is True
    status, events, holds, reserved = _sweep_state(engine, order_id)
    assert status == ConsumerOrderStatus.EXPIRED.value
    assert events == [ConsumerOrderStatus.EXPIRED.value]
    assert holds == [InventoryReservationStatus.EXPIRED.value] * 2
    assert reserved == 0


def test_late_sweep_after_reject_changes_nothing(engine: Engine) -> None:
    application_id, owner_id, order_id, hold_ids = _seed_expired_holds(
        engine, second_hold=False, other_order_reserved=2
    )
    with Session(engine) as late:
        stale = _read_like_sweep(late, hold_ids[0])  # noqa: F841 — keep the stale order loaded
        with Session(engine) as first:
            assert _reject(first, application_id, owner_id, order_id) == "rejected"
        assert _expire(late, hold_ids[0]) is False
    status, events, holds, reserved = _sweep_state(engine, order_id)
    assert status == ConsumerOrderStatus.REJECTED.value
    assert events == [ConsumerOrderStatus.REJECTED.value]
    assert holds == [InventoryReservationStatus.RELEASED.value]
    assert reserved == 2


def test_late_cancel_after_sweep_keeps_expired(engine: Engine) -> None:
    _application_id, _owner_id, order_id, hold_ids = _seed_expired_holds(
        engine, second_hold=False, other_order_reserved=2
    )
    with Session(engine) as session:
        buyer_id = session.get(ConsumerOrder, order_id).buyer_user_id
    with Session(engine) as late:
        stale = _read_like_service(late, order_id, reservations=True)  # noqa: F841 — keep the stale row loaded
        with Session(engine) as first:
            assert _expire(first, hold_ids[0]) is True
        assert _cancel(late, buyer_id, order_id) is None
    status, events, holds, reserved = _sweep_state(engine, order_id)
    assert status == ConsumerOrderStatus.EXPIRED.value
    assert events == [ConsumerOrderStatus.EXPIRED.value]
    assert holds == [InventoryReservationStatus.EXPIRED.value]
    # The other order's two units stay reserved.
    assert reserved == 2

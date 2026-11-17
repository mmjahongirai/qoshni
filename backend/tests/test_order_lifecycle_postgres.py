"""PostgreSQL order lifecycle and expiry races. Skipped unless a disposable test URL is set.

Set ``QOSHNI_TEST_POSTGRES_URL`` to a database whose URL contains ``test``.
Do not point this at production: each test drops and recreates every table.

The SQLite lifecycle tests reuse helpers from ``test_order_lifecycle_concurrency``.
Here the same scenarios run against PostgreSQL row locks (READ COMMITTED), plus
true parallel races with no retries. A skipped run is UNVERIFIED.
"""

from __future__ import annotations

import os
import threading
import time
import uuid
from collections.abc import Callable, Generator
from dataclasses import dataclass
from datetime import UTC, datetime
from typing import Any

import pytest
from sqlalchemy import create_engine, event, func, select, text
from sqlalchemy.engine import Engine
from sqlalchemy.orm import Session

import app.db.models  # noqa: F401
from app.db.base import Base
from app.db.models.consumer_orders import ConsumerOrder, ConsumerOrderItem
from app.db.models.payment import Payment, WalletHold
from app.db.models.wallet import Wallet
from app.domain.inventory_reservation import InventoryReservationStatus
from app.domain.order_lifecycle import ConsumerOrderFulfillmentStatus, ConsumerOrderPaymentStatus, ConsumerOrderStatus
from app.domain.payment import PaymentErrorCode, PaymentMethod
from app.services.checkout.sql_order_repository import SqlOrderLifecycleService
from app.services.wallet.payment_service import PaymentError, PaymentResult, create_payment
from tests.test_order_lifecycle_concurrency import (
    _cancel,
    _expire,
    _reject,
    _seed,
    _seed_expired_holds,
    _state,
    _sweep_state,
)
from tests.test_order_lifecycle_concurrency import (
    test_late_cancel_after_cancel_returns_cancelled_once as _late_cancel_after_cancel,
)
from tests.test_order_lifecycle_concurrency import (
    test_late_cancel_after_reject_keeps_other_order_stock as _late_cancel_after_reject,
)
from tests.test_order_lifecycle_concurrency import (
    test_late_cancel_after_sweep_keeps_expired as _late_cancel_after_sweep,
)
from tests.test_order_lifecycle_concurrency import (
    test_late_reject_after_cancel_keeps_cancelled as _late_reject_after_cancel,
)
from tests.test_order_lifecycle_concurrency import (
    test_late_reject_after_reject_replays as _late_reject_after_reject,
)
from tests.test_order_lifecycle_concurrency import (
    test_late_sweep_after_reject_changes_nothing as _late_sweep_after_reject,
)
from tests.test_order_lifecycle_concurrency import (
    test_two_sweeps_over_one_order_write_one_expired_event as _two_sweeps_one_order,
)
from tests.test_payment_postgres import _seed as _seed_payment

_URL = os.environ.get("QOSHNI_TEST_POSTGRES_URL")

pytestmark = pytest.mark.skipif(
    not _URL or "test" not in _URL.lower(),
    reason=(
        "QOSHNI_TEST_POSTGRES_URL is unset or is not a disposable test database. "
        "PostgreSQL order lifecycle locking was not executed."
    ),
)

_ROUNDS = 5
_EXPIRED = ConsumerOrderStatus.EXPIRED.value
_REJECTED = ConsumerOrderStatus.REJECTED.value
_CANCELLED = ConsumerOrderStatus.CANCELLED.value


def _fresh_schema(database: Engine) -> None:
    Base.metadata.drop_all(database)
    Base.metadata.create_all(database)


@pytest.fixture
def engine() -> Generator[Engine, None, None]:
    assert _URL is not None
    database = create_engine(_URL)
    _fresh_schema(database)
    yield database
    Base.metadata.drop_all(database)
    database.dispose()


@dataclass(frozen=True)
class _Raised:
    """An exception from a racing thread, kept so the assertion shows it."""

    error: str


def _race(engine: Engine, *actions: Callable[[Session], Any]) -> list[Any]:
    """Start every action at once, each in its own session. No retries."""
    barrier = threading.Barrier(len(actions), timeout=10)
    results: list[Any] = [None] * len(actions)

    def run(index: int, action: Callable[[Session], Any]) -> None:
        try:
            barrier.wait()
            with Session(engine) as session:
                results[index] = action(session)
        except Exception as exc:  # noqa: BLE001 — reported through the assertion below
            results[index] = _Raised(f"{type(exc).__name__}: {exc}")

    threads = [threading.Thread(target=run, args=(index, action)) for index, action in enumerate(actions)]
    for thread in threads:
        thread.start()
    for thread in threads:
        thread.join(timeout=60)
        assert not thread.is_alive(), "a racing thread did not finish"
    assert not any(isinstance(result, _Raised) for result in results), results
    return results


# --- Stale reads: the late request read the order before the first one committed. ---


def test_pg_late_reject_after_reject_replays(engine: Engine) -> None:
    _late_reject_after_reject(engine)


def test_pg_late_cancel_after_reject_keeps_other_order_stock(engine: Engine) -> None:
    _late_cancel_after_reject(engine)


def test_pg_late_reject_after_cancel_keeps_cancelled(engine: Engine) -> None:
    _late_reject_after_cancel(engine)


def test_pg_late_cancel_after_cancel_returns_cancelled_once(engine: Engine) -> None:
    _late_cancel_after_cancel(engine)


def test_pg_two_sweeps_over_one_order_write_one_expired_event(engine: Engine) -> None:
    _two_sweeps_one_order(engine)


def test_pg_late_sweep_after_reject_changes_nothing(engine: Engine) -> None:
    _late_sweep_after_reject(engine)


def test_pg_late_cancel_after_sweep_keeps_expired(engine: Engine) -> None:
    _late_cancel_after_sweep(engine)


# --- Parallel races with no retries. ---


def test_pg_parallel_reject_and_cancel_apply_one_transition(engine: Engine) -> None:
    for round_number in range(_ROUNDS):
        if round_number:
            _fresh_schema(engine)
        application_id, owner_id, buyer_id, order_id = _seed(engine, other_order_reserved=2)
        outcomes = _race(
            engine,
            lambda session: _reject(session, application_id, owner_id, order_id),
            lambda session: _cancel(session, buyer_id, order_id),
        )
        status, events, reserved = _state(engine, order_id)
        assert len(events) == 1, (outcomes, events)
        assert status == events[0]
        if status == _REJECTED:
            assert outcomes == ["rejected", None], outcomes
        else:
            assert status == _CANCELLED
            assert outcomes == ["invalid_transition", _CANCELLED], outcomes
        # Only this order's two units are released; the other order keeps two.
        assert reserved == 2, outcomes


def test_pg_parallel_sweeps_over_one_hold_expire_it_once(engine: Engine) -> None:
    for round_number in range(_ROUNDS):
        if round_number:
            _fresh_schema(engine)
        _application_id, _owner_id, order_id, hold_ids = _seed_expired_holds(engine, second_hold=False)
        outcomes = _race(
            engine,
            lambda session: _expire(session, hold_ids[0]),
            lambda session: _expire(session, hold_ids[0]),
        )
        assert sorted(outcomes) == [False, True], outcomes
        status, events, holds, reserved = _sweep_state(engine, order_id)
        assert status == _EXPIRED
        assert events == [_EXPIRED]
        assert holds == [InventoryReservationStatus.EXPIRED.value]
        assert reserved == 0


def test_pg_parallel_sweeps_over_two_holds_write_one_expired_event(engine: Engine) -> None:
    for round_number in range(_ROUNDS):
        if round_number:
            _fresh_schema(engine)
        _application_id, _owner_id, order_id, hold_ids = _seed_expired_holds(engine, second_hold=True)
        outcomes = _race(
            engine,
            lambda session: _expire(session, hold_ids[0]),
            lambda session: _expire(session, hold_ids[1]),
        )
        # Each sweep expires its own hold; only one of them moves the order.
        assert outcomes == [True, True], outcomes
        status, events, holds, reserved = _sweep_state(engine, order_id)
        assert status == _EXPIRED
        assert events == [_EXPIRED]
        assert holds == [InventoryReservationStatus.EXPIRED.value] * 2
        assert reserved == 0


def test_pg_parallel_sweep_and_reject_apply_one_transition(engine: Engine) -> None:
    for round_number in range(_ROUNDS):
        if round_number:
            _fresh_schema(engine)
        application_id, owner_id, order_id, hold_ids = _seed_expired_holds(
            engine, second_hold=False, other_order_reserved=2
        )
        swept, rejected = _race(
            engine,
            lambda session: _expire(session, hold_ids[0]),
            lambda session: _reject(session, application_id, owner_id, order_id),
        )
        status, events, holds, reserved = _sweep_state(engine, order_id)
        assert len(events) == 1, (swept, rejected, events)
        assert status == events[0]
        if status == _EXPIRED:
            assert (swept, rejected) == (True, "invalid_transition")
            assert holds == [InventoryReservationStatus.EXPIRED.value]
        else:
            assert status == _REJECTED
            assert (swept, rejected) == (False, "rejected")
            assert holds == [InventoryReservationStatus.RELEASED.value]
        # The other order's two units stay reserved.
        assert reserved == 2, (swept, rejected)


def test_pg_parallel_sweep_and_cancel_apply_one_transition(engine: Engine) -> None:
    for round_number in range(_ROUNDS):
        if round_number:
            _fresh_schema(engine)
        _application_id, _owner_id, order_id, hold_ids = _seed_expired_holds(
            engine, second_hold=False, other_order_reserved=2
        )
        with Session(engine) as session:
            buyer_id = session.get(ConsumerOrder, order_id).buyer_user_id
        swept, cancelled = _race(
            engine,
            lambda session: _expire(session, hold_ids[0]),
            lambda session: _cancel(session, buyer_id, order_id),
        )
        status, events, holds, reserved = _sweep_state(engine, order_id)
        assert len(events) == 1, (swept, cancelled, events)
        assert status == events[0]
        if status == _EXPIRED:
            assert (swept, cancelled) == (True, None)
            assert holds == [InventoryReservationStatus.EXPIRED.value]
        else:
            assert status == _CANCELLED
            assert (swept, cancelled) == (False, _CANCELLED)
            assert holds == [InventoryReservationStatus.RELEASED.value]
        assert reserved == 2, (swept, cancelled)


# --- Lock order of one sweep, and a second sweep waiting on that lock. ---


def _waiting_on_lock(engine: Engine) -> list[str]:
    with engine.connect() as connection:
        return list(
            connection.scalars(
                text(
                    "SELECT query FROM pg_stat_activity "
                    "WHERE datname = current_database() AND wait_event_type = 'Lock'"
                )
            )
        )


def test_pg_sweep_locks_order_first_and_a_second_sweep_waits(engine: Engine) -> None:
    """Sweep A locks the order, claims the hold, and stops before commit.

    Sweep B must block on the order row lock (seen in ``pg_stat_activity``),
    then find the hold already claimed and change nothing.
    """
    _application_id, _owner_id, order_id, hold_ids = _seed_expired_holds(engine, second_hold=False)
    statements: dict[str, list[str]] = {"sweep-a": [], "sweep-b": []}
    a_claimed = threading.Event()
    a_may_commit = threading.Event()

    @event.listens_for(engine, "before_cursor_execute")
    def _record(conn, cursor, statement, parameters, context, executemany):  # noqa: ANN001, ARG001
        name = threading.current_thread().name
        if name in statements:
            statements[name].append(" ".join(statement.split()))

    @event.listens_for(engine, "after_cursor_execute")
    def _pause_after_claim(conn, cursor, statement, parameters, context, executemany):  # noqa: ANN001, ARG001
        if threading.current_thread().name == "sweep-a" and statement.lstrip().upper().startswith(
            "UPDATE INVENTORY_RESERVATIONS"
        ):
            a_claimed.set()
            assert a_may_commit.wait(timeout=20), "sweep A was never released"

    outcomes: dict[str, Any] = {}

    def sweep() -> None:
        name = threading.current_thread().name
        try:
            with Session(engine) as session:
                expired = SqlOrderLifecycleService(session)._expire_one(hold_ids[0], datetime.now(UTC))
                session.commit()
                outcomes[name] = expired
        except Exception as exc:  # noqa: BLE001 — reported through the assertion below
            outcomes[name] = _Raised(f"{type(exc).__name__}: {exc}")

    first = threading.Thread(target=sweep, name="sweep-a")
    second = threading.Thread(target=sweep, name="sweep-b")
    try:
        first.start()
        assert a_claimed.wait(timeout=20), "sweep A never claimed the hold"
        second.start()
        deadline = time.monotonic() + 10
        blocked: list[str] = []
        while time.monotonic() < deadline and not blocked:
            blocked = [query for query in _waiting_on_lock(engine) if "consumer_orders" in query]
            if not blocked:
                time.sleep(0.05)
        assert second.is_alive()
        assert blocked, "sweep B did not wait on the order row lock"
        assert "FOR UPDATE" in blocked[0].upper()
    finally:
        a_may_commit.set()
        first.join(timeout=30)
        second.join(timeout=30)
        event.remove(engine, "before_cursor_execute", _record)
        event.remove(engine, "after_cursor_execute", _pause_after_claim)

    assert outcomes == {"sweep-a": True, "sweep-b": False}, outcomes

    def position(name: str, predicate: Callable[[str], bool]) -> int:
        return next(index for index, sql in enumerate(statements[name]) if predicate(sql.upper()))

    lock_order = position("sweep-a", lambda sql: "FROM CONSUMER_ORDERS" in sql and "FOR UPDATE" in sql)
    claim = position("sweep-a", lambda sql: sql.startswith("UPDATE INVENTORY_RESERVATIONS"))
    release = position("sweep-a", lambda sql: sql.startswith("UPDATE CONSUMER_CATALOG_INVENTORY"))
    transition = position("sweep-a", lambda sql: sql.startswith("UPDATE CONSUMER_ORDERS"))
    assert lock_order < claim < release < transition, statements["sweep-a"]

    status, events, holds, reserved = _sweep_state(engine, order_id)
    assert status == _EXPIRED
    assert events == [_EXPIRED]
    assert holds == [InventoryReservationStatus.EXPIRED.value]
    assert reserved == 0


# --- Payments: one wallet, two orders. ---


def test_pg_parallel_payments_for_two_orders_cannot_overdraw_one_wallet(engine: Engine) -> None:
    """The wallet holds 100; each order costs 100. Exactly one payment may succeed."""
    buyer_id, first_order_id, wallet_id = _seed_payment(engine)
    with Session(engine) as session:
        first = session.get(ConsumerOrder, first_order_id)
        assert first is not None
        line = first.items[0]
        second = ConsumerOrder(
            buyer_user_id=buyer_id,
            status=ConsumerOrderStatus.PENDING_ACCEPTANCE.value,
            payment_status=ConsumerOrderPaymentStatus.UNPAID.value,
            fulfillment_status=ConsumerOrderFulfillmentStatus.NOT_STARTED.value,
            currency_code="UZS",
            subtotal_minor=100,
            total_minor=100,
            checkout_correlation_id="pg-pay-second",
            idempotency_key=f"pg-{uuid.uuid4().hex}",
        )
        session.add(second)
        session.flush()
        session.add(
            ConsumerOrderItem(
                order_id=second.id,
                business_stable_id=line.business_stable_id,
                catalog_item_stable_id=line.catalog_item_stable_id,
                title_snapshot=line.title_snapshot,
                quantity=1,
                unit_price_minor=100,
                line_subtotal_minor=100,
                currency_code="UZS",
            )
        )
        session.commit()
        second_order_id = second.id

    def pay(order_id: uuid.UUID, key: str) -> Callable[[Session], str]:
        def action(session: Session) -> str:
            outcome = create_payment(
                session,
                buyer_user_id=buyer_id,
                order_id=order_id,
                payment_method=PaymentMethod.WALLET,
                idempotency_key=key,
            )
            if isinstance(outcome, PaymentError):
                session.rollback()
                return outcome.code.value
            assert isinstance(outcome, PaymentResult)
            session.commit()
            return "paid"

        return action

    outcomes = _race(engine, pay(first_order_id, "pg-one"), pay(second_order_id, "pg-two"))
    assert sorted(outcomes) == sorted(["paid", PaymentErrorCode.INSUFFICIENT_BALANCE.value]), outcomes
    with Session(engine) as session:
        wallet = session.get(Wallet, wallet_id)
        assert wallet is not None
        assert wallet.available_minor == 0
        assert wallet.hold_minor == 100
        assert session.scalar(select(func.count()).select_from(Payment)) == 1
        assert session.scalar(select(func.count()).select_from(WalletHold)) == 1

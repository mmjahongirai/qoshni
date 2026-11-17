"""Phase 19 WP2 — payment hold, idempotency, and inventory isolation.

SQLite serializes writers with a conditional order update and the WP1 balance
update. It does not verify PostgreSQL ``SELECT … FOR UPDATE``.
"""

from __future__ import annotations

import uuid
from collections.abc import Generator
from contextlib import contextmanager
from datetime import UTC, datetime
from pathlib import Path

import pytest
from alembic import command
from alembic.config import Config
from fastapi.testclient import TestClient
from sqlalchemy import create_engine, func, inspect, select
from sqlalchemy.engine import Engine
from sqlalchemy.orm import Session, sessionmaker

from app.api.deps.auth import get_otp_delivery_provider
from app.core.config import get_settings
from app.core.database import get_db
from app.db.base import Base
from app.db.models.business_onboarding import BusinessOnboardingApplication
from app.db.models.consumer_catalog import ConsumerCatalogInventory, ConsumerCatalogItem
from app.db.models.consumer_orders import (
    ConsumerOrder,
    ConsumerOrderItem,
    InventoryReservation,
    OrderIdempotencyRecord,
)
from app.db.models.identity import User
from app.db.models.payment import Payment, PaymentIdempotencyRecord, WalletHold
from app.db.models.wallet import LedgerEntry, Wallet
from app.domain.business_onboarding import BusinessServiceCategory, VerificationStatus
from app.domain.consumer_catalog import ConsumerCatalogOfferingKind
from app.domain.identity import AccountStatus
from app.domain.inventory_reservation import InventoryReservationStatus
from app.domain.order_lifecycle import (
    ConsumerOrderFulfillmentStatus,
    ConsumerOrderPaymentStatus,
    ConsumerOrderStatus,
)
from app.domain.payment import PaymentErrorCode, PaymentMethod, PaymentStatus, WalletHoldStatus
from app.domain.wallet import AUTHORITATIVE_CURRENCY, LedgerAccountType, LedgerDirection, WalletOwnerType
from app.main import create_app
from app.services.checkout.consumer_catalog_service import upsert_catalog_offering
from app.services.checkout.sql_inventory import open_catalog_inventory, reserve_catalog_quantity
from app.services.search_discovery.stable_ids import stable_id_for_application
from app.services.wallet.ledger_service import LedgerLeg, WalletPostingError, post_balanced_movement
from app.services.wallet.payment_service import PaymentError, PaymentResult, create_payment
from app.services.wallet.wallet_service import ensure_platform_wallet, get_or_create_business_wallet, get_or_create_user_wallet
from tests.support.fake_otp_provider import FakeOtpProvider

import app.db.models  # noqa: F401

_DIGEST_KEY = "t" * 32
BACKEND_ROOT = Path(__file__).resolve().parents[1]


def _phone() -> str:
    return f"+9989016{uuid.uuid4().int % 10000000:07d}"


def _user(session: Session) -> User:
    user = User(phone_e164=_phone(), status=AccountStatus.ACTIVE.value)
    session.add(user)
    session.flush()
    return user


def _business(session: Session, owner: User, *, verified: bool = True) -> BusinessOnboardingApplication:
    application = BusinessOnboardingApplication(
        owner_user_id=owner.id,
        legal_business_name="Baraka LLC",
        trade_display_name="Baraka",
        service_category=BusinessServiceCategory.GROCERIES.value,
        registration_jurisdiction="UZ",
        registration_identifier=f"REG-{uuid.uuid4().hex[:10]}",
        verification_status=VerificationStatus.VERIFIED.value if verified else VerificationStatus.SUBMITTED.value,
        submitted_at=datetime.now(UTC),
    )
    session.add(application)
    session.flush()
    return application


def _fund(session: Session, wallet_id: uuid.UUID, amount: int) -> None:
    posted = post_balanced_movement(
        session,
        currency_code=AUTHORITATIVE_CURRENCY,
        legs=[
            LedgerLeg(wallet_id, LedgerAccountType.AVAILABLE, LedgerDirection.CREDIT, amount),
            LedgerLeg(wallet_id, LedgerAccountType.CLEARING, LedgerDirection.DEBIT, amount),
        ],
    )
    assert not isinstance(posted, WalletPostingError)


def _order(
    session: Session,
    *,
    buyer: User,
    application: BusinessOnboardingApplication,
    total: int = 8000,
    status: ConsumerOrderStatus = ConsumerOrderStatus.PENDING_ACCEPTANCE,
    payment_status: ConsumerOrderPaymentStatus = ConsumerOrderPaymentStatus.UNPAID,
    reserve: bool = True,
) -> ConsumerOrder:
    item_key = f"bread-{uuid.uuid4().hex[:8]}"
    item = upsert_catalog_offering(
        session,
        owner_user_id=application.owner_user_id,
        business_application_id=application.id,
        catalog_item_stable_id=item_key,
        offering_kind=ConsumerCatalogOfferingKind.PRODUCT,
        title="Bread",
        unit_price_minor=total,
    )
    assert isinstance(item, ConsumerCatalogItem)
    open_catalog_inventory(session, catalog_item_id=item.id, quantity_on_hand=5)
    if reserve:
        assert reserve_catalog_quantity(session, catalog_item_id=item.id, quantity=2)
    order = ConsumerOrder(
        buyer_user_id=buyer.id,
        status=status.value,
        payment_status=payment_status.value,
        fulfillment_status=ConsumerOrderFulfillmentStatus.NOT_STARTED.value,
        currency_code="UZS",
        subtotal_minor=total,
        total_minor=total,
        checkout_correlation_id="wp2-pay",
        idempotency_key=f"order-{uuid.uuid4().hex}",
    )
    session.add(order)
    session.flush()
    session.add(
        ConsumerOrderItem(
            order_id=order.id,
            business_stable_id=stable_id_for_application(application.id),
            catalog_item_stable_id=item_key,
            title_snapshot="Bread",
            quantity=2,
            unit_price_minor=total,
            line_subtotal_minor=total,
            currency_code="UZS",
        )
    )
    if reserve:
        session.add(
            InventoryReservation(
                order_id=order.id,
                business_stable_id=stable_id_for_application(application.id),
                catalog_item_stable_id=item_key,
                quantity=2,
                status=InventoryReservationStatus.HELD.value,
            )
        )
    session.flush()
    return order


def _ready(session: Session, *, balance: int = 8000, total: int = 8000):
    owner = _user(session)
    buyer = _user(session)
    application = _business(session, owner)
    business_wallet = get_or_create_business_wallet(
        session,
        owner_user_id=owner.id,
        business_application_id=application.id,
    )
    payer = get_or_create_user_wallet(session, user_id=buyer.id)
    assert isinstance(business_wallet, Wallet) and isinstance(payer, Wallet)
    if balance:
        _fund(session, payer.id, balance)
    order = _order(session, buyer=buyer, application=application, total=total)
    return buyer, application, business_wallet, payer, order


@pytest.fixture
def engine(tmp_path: Path) -> Generator[Engine, None, None]:
    database = create_engine(
        f"sqlite:///{(tmp_path / 'pay.db').as_posix()}",
        connect_args={"check_same_thread": False, "timeout": 30},
    )
    Base.metadata.create_all(database)
    yield database
    database.dispose()


def test_payment_uses_order_total_and_holds_buyer_funds(engine: Engine) -> None:
    with Session(engine) as session:
        buyer, _application, business, payer, order = _ready(session, balance=10000, total=8000)
        platform_before = ensure_platform_wallet(session)
        assert isinstance(platform_before, Wallet)
        reserved_before = session.scalar(select(ConsumerCatalogInventory.reserved_quantity))
        order_idempotency_before = session.scalar(select(func.count()).select_from(OrderIdempotencyRecord))
        result = create_payment(
            session,
            buyer_user_id=buyer.id,
            order_id=order.id,
            payment_method=PaymentMethod.WALLET,
            idempotency_key="pay-1",
        )
        assert isinstance(result, PaymentResult)
        assert result.payment.amount_minor == 8000
        assert result.payment.currency_code == "UZS"
        assert result.payment.status == PaymentStatus.HELD.value
        assert result.hold.status == WalletHoldStatus.ACTIVE.value
        assert result.hold.amount_minor == 8000
        assert result.hold.wallet_id == payer.id
        session.commit()
        session.refresh(payer)
        session.refresh(business)
        session.refresh(order)
        assert payer.available_minor == 2000
        assert payer.hold_minor == 8000
        assert (business.available_minor, business.hold_minor, business.pending_minor) == (0, 0, 0)
        platform = session.get(Wallet, platform_before.id)
        assert platform is not None
        assert (platform.available_minor, platform.hold_minor) == (0, 0)
        assert order.payment_status == ConsumerOrderPaymentStatus.PAYMENT_PENDING.value
        assert order.status == ConsumerOrderStatus.PENDING_ACCEPTANCE.value
        assert session.scalar(select(ConsumerCatalogInventory.reserved_quantity)) == reserved_before
        assert session.scalar(select(InventoryReservation.status)) == InventoryReservationStatus.HELD.value
        assert session.scalar(select(func.count()).select_from(OrderIdempotencyRecord)) == order_idempotency_before
        entries = session.scalars(
            select(LedgerEntry).where(LedgerEntry.wallet_id == payer.id, LedgerEntry.account_type != "clearing")
        ).all()
        payment_entries = [entry for entry in entries if entry.account_type in {"available", "hold"} and entry.amount_minor == 8000]
        debit = sum(entry.amount_minor for entry in payment_entries if entry.direction == "debit")
        credit = sum(entry.amount_minor for entry in payment_entries if entry.direction == "credit")
        assert debit == credit == 8000


def test_same_key_replays_without_a_second_movement(engine: Engine) -> None:
    with Session(engine) as session:
        buyer, _application, _business, payer, order = _ready(session)
        first = create_payment(
            session,
            buyer_user_id=buyer.id,
            order_id=order.id,
            payment_method=PaymentMethod.WALLET,
            idempotency_key="same",
        )
        second = create_payment(
            session,
            buyer_user_id=buyer.id,
            order_id=order.id,
            payment_method=PaymentMethod.WALLET,
            idempotency_key="same",
        )
        assert isinstance(first, PaymentResult) and isinstance(second, PaymentResult)
        assert second.idempotent_replay is True
        assert second.payment.id == first.payment.id
        assert second.hold.id == first.hold.id
        session.commit()
        assert session.scalar(select(func.count()).select_from(Payment)) == 1
        assert session.scalar(select(func.count()).select_from(WalletHold)) == 1
        assert session.scalar(select(func.count()).select_from(PaymentIdempotencyRecord)) == 1
        session.refresh(payer)
        assert payer.available_minor == 0
        assert payer.hold_minor == 8000


def _assert_single_payment(engine: Engine, wallet_id: uuid.UUID) -> None:
    with Session(engine) as session:
        wallet = session.get(Wallet, wallet_id)
        assert wallet is not None
        assert wallet.available_minor == 0
        assert wallet.hold_minor == 8000
        assert session.scalar(select(func.count()).select_from(Payment)) == 1
        assert session.scalar(select(func.count()).select_from(WalletHold)) == 1
        assert session.scalar(select(func.count()).select_from(PaymentIdempotencyRecord)) == 1
        # Funding (2 legs) plus one hold movement (2 legs).
        assert session.scalar(
            select(func.count()).select_from(LedgerEntry).where(LedgerEntry.wallet_id == wallet_id)
        ) == 4


def test_same_key_waiting_request_replays_committed_payment(
    engine: Engine,
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """The second request's first lookup ran before the winner committed.

    This is the PostgreSQL READ COMMITTED order: lookup, wait on the order lock,
    then read the paid order. The request must replay, not report a new conflict.
    """

    from app.services.wallet import payment_service

    with Session(engine) as session:
        _buyer, _application, _business, payer, order = _ready(session, balance=8000)
        session.commit()
        buyer_id, order_id, wallet_id = order.buyer_user_id, order.id, payer.id

    with Session(engine) as session:
        first = create_payment(
            session,
            buyer_user_id=buyer_id,
            order_id=order_id,
            payment_method=PaymentMethod.WALLET,
            idempotency_key="same-race",
        )
        assert isinstance(first, PaymentResult)
        session.commit()
        first_payment_id, first_hold_id = first.payment.id, first.hold.id

    real_lookup = payment_service._find_idempotency
    calls = {"count": 0}

    def lookup_before_winner_commit(session: Session, **kwargs: object):
        calls["count"] += 1
        if calls["count"] == 1:
            return None
        return real_lookup(session, **kwargs)

    monkeypatch.setattr(payment_service, "_find_idempotency", lookup_before_winner_commit)
    with Session(engine) as session:
        second = create_payment(
            session,
            buyer_user_id=buyer_id,
            order_id=order_id,
            payment_method=PaymentMethod.WALLET,
            idempotency_key="same-race",
        )
        assert isinstance(second, PaymentResult), second
        assert second.idempotent_replay is True
        assert second.payment.id == first_payment_id
        assert second.hold.id == first_hold_id
        session.commit()
    assert calls["count"] >= 2
    _assert_single_payment(engine, wallet_id)


def test_same_key_waiting_request_with_other_order_still_conflicts(
    engine: Engine,
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    from app.services.wallet import payment_service

    with Session(engine) as session:
        buyer, application, _business, payer, order = _ready(session, balance=16000)
        other = _order(session, buyer=buyer, application=application, reserve=False)
        other.payment_status = ConsumerOrderPaymentStatus.PAYMENT_PENDING.value
        session.commit()
        buyer_id, order_id, other_id = buyer.id, order.id, other.id

    with Session(engine) as session:
        first = create_payment(
            session,
            buyer_user_id=buyer_id,
            order_id=order_id,
            payment_method=PaymentMethod.WALLET,
            idempotency_key="shared-key",
        )
        assert isinstance(first, PaymentResult)
        session.commit()

    real_lookup = payment_service._find_idempotency
    calls = {"count": 0}

    def lookup_before_winner_commit(session: Session, **kwargs: object):
        calls["count"] += 1
        if calls["count"] == 1:
            return None
        return real_lookup(session, **kwargs)

    monkeypatch.setattr(payment_service, "_find_idempotency", lookup_before_winner_commit)
    with Session(engine) as session:
        second = create_payment(
            session,
            buyer_user_id=buyer_id,
            order_id=other_id,
            payment_method=PaymentMethod.WALLET,
            idempotency_key="shared-key",
        )
        assert isinstance(second, PaymentError)
        assert second.code is PaymentErrorCode.IDEMPOTENCY_CONFLICT


@pytest.mark.parametrize("session_already_open", [False, True])
def test_parallel_same_key_returns_one_payment(engine: Engine, session_already_open: bool) -> None:
    """Two concurrent requests with one key share one result.

    ``session_already_open`` mirrors the HTTP route, where authentication reads
    the database first, so the payment does not start the SQLite transaction.
    """

    import threading

    for _round in range(5):
        with Session(engine) as session:
            _buyer, _application, _business, payer, order = _ready(session, balance=8000)
            session.commit()
            buyer_id, order_id, wallet_id = order.buyer_user_id, order.id, payer.id

        # (payment_id, idempotent_replay) is read before the session closes.
        outcomes: list[tuple[uuid.UUID, bool] | str] = []
        barrier = threading.Barrier(2)

        def pay() -> None:
            with Session(engine) as session:
                if session_already_open:
                    session.execute(select(func.count()).select_from(User))
                barrier.wait()
                result = create_payment(
                    session,
                    buyer_user_id=buyer_id,
                    order_id=order_id,
                    payment_method=PaymentMethod.WALLET,
                    idempotency_key=f"parallel-{wallet_id}",
                )
                if isinstance(result, PaymentResult):
                    seen = (result.payment.id, result.idempotent_replay)
                    session.commit()
                    outcomes.append(seen)
                else:
                    session.rollback()
                    outcomes.append(result.code.value)

        threads = [threading.Thread(target=pay) for _ in range(2)]
        for thread in threads:
            thread.start()
        for thread in threads:
            thread.join()

        assert all(isinstance(outcome, tuple) for outcome in outcomes), outcomes
        results = [outcome for outcome in outcomes if isinstance(outcome, tuple)]
        assert len({payment_id for payment_id, _replay in results}) == 1
        assert sorted(replay for _payment_id, replay in results) == [False, True]

        with Session(engine) as session:
            wallet = session.get(Wallet, wallet_id)
            assert wallet is not None
            assert wallet.available_minor == 0
            assert wallet.hold_minor == 8000
            assert session.scalar(
                select(func.count()).select_from(Payment).where(Payment.order_id == order_id)
            ) == 1
            assert session.scalar(
                select(func.count()).select_from(WalletHold).where(WalletHold.order_id == order_id)
            ) == 1
            assert session.scalar(
                select(func.count()).select_from(LedgerEntry).where(LedgerEntry.wallet_id == wallet_id)
            ) == 4


def test_same_key_different_order_conflicts(engine: Engine) -> None:
    with Session(engine) as session:
        buyer, application, _business, _payer, first_order = _ready(session, balance=20000)
        second_order = _order(session, buyer=buyer, application=application, total=8000, reserve=False)
        first = create_payment(
            session,
            buyer_user_id=buyer.id,
            order_id=first_order.id,
            payment_method=PaymentMethod.WALLET,
            idempotency_key="shared",
        )
        assert isinstance(first, PaymentResult)
        conflict = create_payment(
            session,
            buyer_user_id=buyer.id,
            order_id=second_order.id,
            payment_method=PaymentMethod.WALLET,
            idempotency_key="shared",
        )
        assert isinstance(conflict, PaymentError)
        assert conflict.code.value == "idempotency_conflict"
        assert session.scalar(select(func.count()).select_from(Payment)) == 1


def test_insufficient_balance_leaves_order_unpaid(engine: Engine) -> None:
    with Session(engine) as session:
        buyer, _application, _business, payer, order = _ready(session, balance=1000, total=8000)
        reserved = session.scalar(select(ConsumerCatalogInventory.reserved_quantity))
        failed = create_payment(
            session,
            buyer_user_id=buyer.id,
            order_id=order.id,
            payment_method=PaymentMethod.WALLET,
            idempotency_key="short",
        )
        assert isinstance(failed, PaymentError)
        assert failed.code.value == "insufficient_balance"
        reloaded = session.get(ConsumerOrder, order.id)
        wallet = session.get(Wallet, payer.id)
        assert reloaded is not None and wallet is not None
        assert reloaded.payment_status == ConsumerOrderPaymentStatus.UNPAID.value
        assert wallet.available_minor == 1000
        assert wallet.hold_minor == 0
        assert session.scalar(select(func.count()).select_from(Payment)) == 0
        assert session.scalar(select(func.count()).select_from(WalletHold)) == 0
        assert session.scalar(select(func.count()).select_from(LedgerEntry).where(LedgerEntry.account_type == "hold")) == 0
        assert session.scalar(select(ConsumerCatalogInventory.reserved_quantity)) == reserved


@pytest.mark.parametrize(
    "status",
    [ConsumerOrderStatus.REJECTED, ConsumerOrderStatus.CANCELLED, ConsumerOrderStatus.EXPIRED],
)
def test_terminal_orders_are_not_payable(engine: Engine, status: ConsumerOrderStatus) -> None:
    with Session(engine) as session:
        buyer, application, _business, _payer, payable = _ready(session, balance=8000)
        blocked = _order(session, buyer=buyer, application=application, status=status, reserve=False)
        result = create_payment(
            session,
            buyer_user_id=buyer.id,
            order_id=blocked.id,
            payment_method=PaymentMethod.WALLET,
            idempotency_key=f"term-{status.value}",
        )
        assert isinstance(result, PaymentError)
        assert result.code.value == "order_not_payable"


def test_second_payment_is_rejected(engine: Engine) -> None:
    with Session(engine) as session:
        buyer, _application, _business, _payer, order = _ready(session, balance=20000)
        assert isinstance(
            create_payment(
                session,
                buyer_user_id=buyer.id,
                order_id=order.id,
                payment_method=PaymentMethod.WALLET,
                idempotency_key="one",
            ),
            PaymentResult,
        )
        again = create_payment(
            session,
            buyer_user_id=buyer.id,
            order_id=order.id,
            payment_method=PaymentMethod.WALLET,
            idempotency_key="two",
        )
        assert isinstance(again, PaymentError)
        assert again.code.value == "payment_already_exists"
        assert session.scalar(select(func.count()).select_from(Payment)) == 1


def test_other_buyer_cannot_pay(engine: Engine) -> None:
    with Session(engine) as session:
        _buyer, _application, _business, _payer, order = _ready(session)
        stranger = _user(session)
        hidden = create_payment(
            session,
            buyer_user_id=stranger.id,
            order_id=order.id,
            payment_method=PaymentMethod.WALLET,
            idempotency_key="steal",
        )
        assert isinstance(hidden, PaymentError)
        assert hidden.code.value == "order_not_found"
        assert session.scalar(select(func.count()).select_from(Payment)) == 0


def test_parallel_payments_for_one_order_leave_one_hold(engine: Engine) -> None:
    import threading

    with Session(engine) as session:
        _buyer, _application, _business, payer, order = _ready(session, balance=8000)
        session.commit()
        buyer_id = order.buyer_user_id
        order_id = order.id
        wallet_id = payer.id

    outcomes: list[str] = []

    def pay(key: str) -> None:
        with Session(engine) as session:
            result = create_payment(
                session,
                buyer_user_id=buyer_id,
                order_id=order_id,
                payment_method=PaymentMethod.WALLET,
                idempotency_key=key,
            )
            if isinstance(result, PaymentResult):
                session.commit()
                outcomes.append("ok")
            else:
                session.rollback()
                outcomes.append(result.code.value)

    threads = [threading.Thread(target=pay, args=(key,)) for key in ("a", "b")]
    for thread in threads:
        thread.start()
    for thread in threads:
        thread.join()
    assert outcomes.count("ok") == 1
    with Session(engine) as session:
        wallet = session.get(Wallet, wallet_id)
        assert wallet is not None
        assert wallet.available_minor == 0
        assert wallet.hold_minor == 8000
        assert session.scalar(select(func.count()).select_from(Payment)) == 1
        assert session.scalar(
            select(func.count()).select_from(WalletHold).where(WalletHold.status == "active")
        ) == 1


def test_parallel_holds_cannot_overdraw_one_wallet(engine: Engine) -> None:
    import threading

    with Session(engine) as session:
        buyer, application, _business, payer, first = _ready(session, balance=8000, total=8000)
        second = _order(session, buyer=buyer, application=application, total=8000)
        session.commit()
        buyer_id = buyer.id
        order_ids = (first.id, second.id)
        assert first.id != second.id
        wallet_id = payer.id

    outcomes: list[str] = []

    def pay(order_id: uuid.UUID, key: str) -> None:
        with Session(engine) as session:
            result = create_payment(
                session,
                buyer_user_id=buyer_id,
                order_id=order_id,
                payment_method=PaymentMethod.WALLET,
                idempotency_key=key,
            )
            if isinstance(result, PaymentResult):
                session.commit()
                outcomes.append("ok")
            else:
                session.rollback()
                outcomes.append(result.code.value)

    threads = [
        threading.Thread(target=pay, args=(order_ids[0], "race-a")),
        threading.Thread(target=pay, args=(order_ids[1], "race-b")),
    ]
    for thread in threads:
        thread.start()
    for thread in threads:
        thread.join()
    assert sorted(outcomes) == ["insufficient_balance", "ok"]
    with Session(engine) as session:
        wallet = session.get(Wallet, wallet_id)
        assert wallet is not None
        assert wallet.available_minor == 0
        assert wallet.hold_minor == 8000
        assert session.scalar(select(func.count()).select_from(Payment)) == 1
        assert session.scalar(
            select(func.count()).select_from(WalletHold).where(WalletHold.status == "active")
        ) == 1
        unpaid = session.scalar(
            select(func.count()).select_from(ConsumerOrder).where(
                ConsumerOrder.payment_status == ConsumerOrderPaymentStatus.UNPAID.value
            )
        )
        assert unpaid == 1


def test_missing_business_wallet_does_not_move_funds(engine: Engine) -> None:
    with Session(engine) as session:
        owner = _user(session)
        buyer = _user(session)
        application = _business(session, owner)
        payer = get_or_create_user_wallet(session, user_id=buyer.id)
        assert isinstance(payer, Wallet)
        _fund(session, payer.id, 8000)
        order = _order(session, buyer=buyer, application=application)
        failed = create_payment(
            session,
            buyer_user_id=buyer.id,
            order_id=order.id,
            payment_method=PaymentMethod.WALLET,
            idempotency_key="no-business-wallet",
        )
        assert isinstance(failed, PaymentError)
        assert failed.code.value == "business_wallet_unavailable"
        session.refresh(payer)
        assert payer.available_minor == 8000
        assert payer.hold_minor == 0


@pytest.fixture
def api_engine(tmp_path: Path, monkeypatch: pytest.MonkeyPatch) -> Generator[Engine, None, None]:
    url = f"sqlite:///{(tmp_path / 'pay_api.db').as_posix()}"
    monkeypatch.setenv("QOSHNI_DATABASE_URL", url)
    monkeypatch.setenv("QOSHNI_AUTH_SECRET_DIGEST_KEY", _DIGEST_KEY)
    monkeypatch.delenv("QOSHNI_CONSUMER_CATALOG_ENABLED", raising=False)
    get_settings.cache_clear()
    database = create_engine(url, connect_args={"check_same_thread": False, "timeout": 30})
    Base.metadata.create_all(database)
    yield database
    database.dispose()
    get_settings.cache_clear()


@contextmanager
def _client(engine: Engine, provider: FakeOtpProvider) -> Generator[TestClient, None, None]:
    factory = sessionmaker(bind=engine, autoflush=False, autocommit=False, expire_on_commit=False)

    def override_db() -> Generator[Session, None, None]:
        db = factory()
        try:
            yield db
        finally:
            db.close()

    app = create_app()
    app.dependency_overrides[get_db] = override_db
    app.dependency_overrides[get_otp_delivery_provider] = lambda: provider
    with TestClient(app) as client:
        yield client
    app.dependency_overrides.clear()


def _sign_in(client: TestClient, provider: FakeOtpProvider, phone: str) -> str:
    challenge = client.post("/api/v1/auth/otp/challenges", json={"phone": phone})
    assert challenge.status_code == 202, challenge.text
    verified = client.post(
        "/api/v1/auth/otp/verify",
        json={"challenge_id": challenge.json()["challenge_id"], "code": provider.last_code},
    )
    assert verified.status_code == 200, verified.text
    return str(verified.json()["access_token"])


def test_payment_http_authorization_and_amount(api_engine: Engine) -> None:
    provider = FakeOtpProvider()
    buyer_phone = _phone()
    stranger_phone = _phone()
    owner_phone = _phone()
    with _client(api_engine, provider) as client:
        assert client.post("/api/v1/payments", json={"order_id": str(uuid.uuid4()), "payment_method": "wallet"}).status_code == 401
        buyer_token = _sign_in(client, provider, buyer_phone)
        stranger_token = _sign_in(client, provider, stranger_phone)
        owner_token = _sign_in(client, provider, owner_phone)
        with Session(api_engine) as session:
            owner = session.scalar(select(User).where(User.phone_e164 == owner_phone))
            buyer = session.scalar(select(User).where(User.phone_e164 == buyer_phone))
            assert owner is not None and buyer is not None
            application = _business(session, owner)
            business = get_or_create_business_wallet(
                session,
                owner_user_id=owner.id,
                business_application_id=application.id,
            )
            payer = get_or_create_user_wallet(session, user_id=buyer.id)
            assert isinstance(business, Wallet) and isinstance(payer, Wallet)
            _fund(session, payer.id, 9000)
            order = _order(session, buyer=buyer, application=application, total=8000)
            session.commit()
            order_id = order.id
        rejected_amount = client.post(
            "/api/v1/payments",
            headers={"Authorization": f"Bearer {buyer_token}", "Idempotency-Key": "amt"},
            json={"order_id": str(order_id), "payment_method": "wallet", "amount_minor": 1},
        )
        assert rejected_amount.status_code == 422
        created = client.post(
            "/api/v1/payments",
            headers={"Authorization": f"Bearer {buyer_token}", "Idempotency-Key": "http-1"},
            json={"order_id": str(order_id), "payment_method": "wallet"},
        )
        assert created.status_code == 201, created.text
        body = created.json()
        assert body["amount_minor"] == 8000
        assert body["currency_code"] == "UZS"
        assert body["status"] == "held"
        replay = client.post(
            "/api/v1/payments",
            headers={"Authorization": f"Bearer {buyer_token}", "Idempotency-Key": "http-1"},
            json={"order_id": str(order_id), "payment_method": "wallet"},
        )
        assert replay.status_code == 201
        assert replay.json()["payment_id"] == body["payment_id"]
        assert replay.json()["idempotent_replay"] is True
        hidden = client.get(
            f"/api/v1/payments/{body['payment_id']}",
            headers={"Authorization": f"Bearer {stranger_token}"},
        )
        assert hidden.status_code == 404
        assert hidden.json()["detail"]["code"] == "payment_not_found"
        visible = client.get(
            f"/api/v1/payments/{body['payment_id']}",
            headers={"Authorization": f"Bearer {owner_token}"},
        )
        assert visible.status_code == 200
        holds = client.get(
            f"/api/v1/payments/{body['payment_id']}/holds",
            headers={"Authorization": f"Bearer {buyer_token}"},
        )
        assert holds.status_code == 200
        assert holds.json()["holds"][0]["amount_minor"] == 8000
        stolen = client.post(
            "/api/v1/payments",
            headers={"Authorization": f"Bearer {stranger_token}", "Idempotency-Key": "steal"},
            json={"order_id": str(order_id), "payment_method": "wallet"},
        )
        assert stolen.status_code == 404
        assert stolen.json()["detail"]["code"] == "order_not_found"
        assert get_settings().consumer_catalog_enabled is False


def test_payment_routes_have_no_release_or_refund() -> None:
    app = create_app()
    for route in app.routes:
        path = getattr(route, "path", "")
        methods = set(getattr(route, "methods", set()) or set())
        assert "refund" not in path
        assert "settlement" not in path
        if path.endswith("/payments") or "/payments/" in path:
            assert methods.isdisjoint({"PUT", "PATCH", "DELETE"})


@pytest.fixture
def alembic_engine(tmp_path: Path, monkeypatch: pytest.MonkeyPatch) -> Generator[tuple[Config, Engine], None, None]:
    url = f"sqlite:///{(tmp_path / 'pay_migration.db').as_posix()}"
    monkeypatch.setenv("QOSHNI_DATABASE_URL", url)
    get_settings.cache_clear()
    config = Config()
    config.set_main_option("script_location", str(BACKEND_ROOT / "alembic"))
    database = create_engine(url)
    yield config, database
    database.dispose()
    get_settings.cache_clear()


def test_payment_migration_round_trip(alembic_engine: tuple[Config, Engine]) -> None:
    config, database = alembic_engine
    command.upgrade(config, "head")
    names = set(inspect(database).get_table_names())
    assert {"payments", "wallet_holds", "payment_idempotency_records"}.issubset(names)
    command.downgrade(config, "b0a1f0190001")
    names = set(inspect(database).get_table_names())
    assert "payments" not in names
    assert "wallets" in names
    command.upgrade(config, "head")
    assert "payments" in inspect(database).get_table_names()

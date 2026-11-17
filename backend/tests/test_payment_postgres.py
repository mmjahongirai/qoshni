"""PostgreSQL payment races. Skipped unless a disposable test URL is set.

SQLite tests do not replace this check. A skipped run is UNVERIFIED.
"""

from __future__ import annotations

import os
import threading
import uuid
from datetime import UTC, datetime

import pytest
from sqlalchemy import create_engine, func, select
from sqlalchemy.orm import Session

from app.db.base import Base
from app.db.models.business_onboarding import BusinessOnboardingApplication
from app.db.models.consumer_orders import ConsumerOrder, ConsumerOrderItem
from app.db.models.identity import User
from app.db.models.payment import Payment, WalletHold
from app.db.models.wallet import LedgerEntry, Wallet
from app.domain.business_onboarding import BusinessServiceCategory, VerificationStatus
from app.domain.identity import AccountStatus
from app.domain.order_lifecycle import ConsumerOrderFulfillmentStatus, ConsumerOrderPaymentStatus, ConsumerOrderStatus
from app.domain.payment import PaymentMethod
from app.domain.wallet import LedgerAccountType, LedgerDirection
from app.services.search_discovery.stable_ids import stable_id_for_application
from app.services.wallet.ledger_service import LedgerLeg, WalletPostingError, post_balanced_movement
from app.services.wallet.payment_service import PaymentError, PaymentResult, create_payment
from app.services.wallet.wallet_service import get_or_create_business_wallet, get_or_create_user_wallet

import app.db.models  # noqa: F401

_URL = os.environ.get("QOSHNI_TEST_POSTGRES_URL")

pytestmark = pytest.mark.skipif(
    not _URL or "test" not in _URL.lower(),
    reason=(
        "QOSHNI_TEST_POSTGRES_URL is unset or is not a disposable test database. "
        "PostgreSQL payment locking was not executed."
    ),
)


@pytest.fixture
def engine():
    assert _URL is not None
    database = create_engine(_URL)
    Base.metadata.drop_all(database)
    Base.metadata.create_all(database)
    yield database
    Base.metadata.drop_all(database)
    database.dispose()


def _seed(engine) -> tuple[uuid.UUID, uuid.UUID, uuid.UUID]:
    with Session(engine) as session:
        owner = User(phone_e164=f"+9989017{uuid.uuid4().int % 10000000:07d}", status=AccountStatus.ACTIVE.value)
        buyer = User(phone_e164=f"+9989017{uuid.uuid4().int % 10000000:07d}", status=AccountStatus.ACTIVE.value)
        session.add_all([owner, buyer])
        session.flush()
        application = BusinessOnboardingApplication(
            owner_user_id=owner.id,
            legal_business_name="Baraka LLC",
            trade_display_name="Baraka",
            service_category=BusinessServiceCategory.GROCERIES.value,
            registration_jurisdiction="UZ",
            registration_identifier=f"REG-{uuid.uuid4().hex[:10]}",
            verification_status=VerificationStatus.VERIFIED.value,
            submitted_at=datetime.now(UTC),
        )
        session.add(application)
        session.flush()
        business = get_or_create_business_wallet(
            session,
            owner_user_id=owner.id,
            business_application_id=application.id,
        )
        payer = get_or_create_user_wallet(session, user_id=buyer.id)
        assert isinstance(business, Wallet) and isinstance(payer, Wallet)
        funded = post_balanced_movement(
            session,
            currency_code="UZS",
            legs=[
                LedgerLeg(payer.id, LedgerAccountType.AVAILABLE, LedgerDirection.CREDIT, 100),
                LedgerLeg(payer.id, LedgerAccountType.CLEARING, LedgerDirection.DEBIT, 100),
            ],
        )
        assert not isinstance(funded, WalletPostingError)
        order = ConsumerOrder(
            buyer_user_id=buyer.id,
            status=ConsumerOrderStatus.PENDING_ACCEPTANCE.value,
            payment_status=ConsumerOrderPaymentStatus.UNPAID.value,
            fulfillment_status=ConsumerOrderFulfillmentStatus.NOT_STARTED.value,
            currency_code="UZS",
            subtotal_minor=100,
            total_minor=100,
            checkout_correlation_id="pg-pay",
            idempotency_key=f"pg-{uuid.uuid4().hex}",
        )
        session.add(order)
        session.flush()
        session.add(
            ConsumerOrderItem(
                order_id=order.id,
                business_stable_id=stable_id_for_application(application.id),
                catalog_item_stable_id="bread",
                title_snapshot="Bread",
                quantity=1,
                unit_price_minor=100,
                line_subtotal_minor=100,
                currency_code="UZS",
            )
        )
        session.commit()
        return buyer.id, order.id, payer.id


def test_parallel_payments_one_order(engine) -> None:
    buyer_id, order_id, wallet_id = _seed(engine)

    results: list[bool] = []
    barrier = threading.Barrier(2)

    def pay(key: str) -> None:
        barrier.wait()
        with Session(engine) as session:
            outcome = create_payment(
                session,
                buyer_user_id=buyer_id,
                order_id=order_id,
                payment_method=PaymentMethod.WALLET,
                idempotency_key=key,
            )
            if isinstance(outcome, PaymentError):
                session.rollback()
                results.append(False)
                return
            assert isinstance(outcome, PaymentResult)
            session.commit()
            results.append(True)

    threads = [threading.Thread(target=pay, args=(key,)) for key in ("pg-a", "pg-b")]
    for thread in threads:
        thread.start()
    for thread in threads:
        thread.join()
    assert results.count(True) == 1
    with Session(engine) as session:
        wallet = session.get(Wallet, wallet_id)
        assert wallet is not None
        assert wallet.available_minor == 0
        assert wallet.hold_minor == 100
        assert session.scalar(select(func.count()).select_from(Payment)) == 1


def test_parallel_same_key_returns_one_payment(engine) -> None:
    """Same buyer, key, and order: the request that waited on the order lock replays."""

    buyer_id, order_id, wallet_id = _seed(engine)
    # (payment_id, idempotent_replay) is read before the session closes.
    outcomes: list[tuple[uuid.UUID, bool] | str] = []
    barrier = threading.Barrier(2)

    def pay() -> None:
        with Session(engine) as session:
            # The HTTP route has already read the session during authentication.
            session.execute(select(func.count()).select_from(User))
            barrier.wait()
            outcome = create_payment(
                session,
                buyer_user_id=buyer_id,
                order_id=order_id,
                payment_method=PaymentMethod.WALLET,
                idempotency_key="pg-same",
            )
            if isinstance(outcome, PaymentResult):
                seen = (outcome.payment.id, outcome.idempotent_replay)
                session.commit()
                outcomes.append(seen)
            else:
                session.rollback()
                outcomes.append(outcome.code.value)

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
        assert wallet.hold_minor == 100
        assert session.scalar(select(func.count()).select_from(Payment)) == 1
        assert session.scalar(select(func.count()).select_from(WalletHold)) == 1
        assert session.scalar(
            select(func.count()).select_from(LedgerEntry).where(LedgerEntry.wallet_id == wallet_id)
        ) == 4

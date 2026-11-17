"""PostgreSQL wallet locking. Skipped unless a disposable test URL is set.

Set ``QOSHNI_TEST_POSTGRES_URL`` to a database whose URL contains ``test``.
SQLite tests do not replace this check. A skipped run is UNVERIFIED.
"""

from __future__ import annotations

import os
import threading
import uuid

import pytest
from sqlalchemy import create_engine, func, select
from sqlalchemy.orm import Session

from app.db.base import Base
from app.db.models.identity import User
from app.db.models.wallet import LedgerTransaction, Wallet
from app.domain.identity import AccountStatus
from app.domain.wallet import LedgerAccountType, LedgerDirection
from app.services.wallet.ledger_service import LedgerLeg, WalletPostingError, post_balanced_movement
from app.services.wallet.wallet_service import get_or_create_user_wallet

import app.db.models  # noqa: F401

_URL = os.environ.get("QOSHNI_TEST_POSTGRES_URL")

pytestmark = pytest.mark.skipif(
    not _URL or "test" not in _URL.lower(),
    reason=(
        "QOSHNI_TEST_POSTGRES_URL is unset or is not a disposable test database. "
        "PostgreSQL wallet locking was not executed."
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


def test_parallel_debits_cannot_both_succeed(engine) -> None:
    with Session(engine) as session:
        user = User(phone_e164=f"+9989015{uuid.uuid4().int % 10000000:07d}", status=AccountStatus.ACTIVE.value)
        session.add(user)
        session.flush()
        wallet = get_or_create_user_wallet(session, user_id=user.id)
        assert isinstance(wallet, Wallet)
        funded = post_balanced_movement(
            session,
            currency_code="UZS",
            legs=[
                LedgerLeg(wallet.id, LedgerAccountType.AVAILABLE, LedgerDirection.CREDIT, 100),
                LedgerLeg(wallet.id, LedgerAccountType.CLEARING, LedgerDirection.DEBIT, 100),
            ],
        )
        assert not isinstance(funded, WalletPostingError)
        session.commit()
        wallet_id = wallet.id

    results: list[bool] = []
    barrier = threading.Barrier(2)

    def debit(amount: int) -> None:
        barrier.wait()
        with Session(engine) as session:
            outcome = post_balanced_movement(
                session,
                currency_code="UZS",
                legs=[
                    LedgerLeg(wallet_id, LedgerAccountType.AVAILABLE, LedgerDirection.DEBIT, amount),
                    LedgerLeg(wallet_id, LedgerAccountType.CLEARING, LedgerDirection.CREDIT, amount),
                ],
            )
            if isinstance(outcome, WalletPostingError):
                session.rollback()
                results.append(False)
                return
            session.commit()
            results.append(True)

    threads = [threading.Thread(target=debit, args=(amount,)) for amount in (70, 50)]
    for thread in threads:
        thread.start()
    for thread in threads:
        thread.join()

    assert results.count(True) == 1
    with Session(engine) as session:
        wallet = session.get(Wallet, wallet_id)
        assert wallet is not None
        assert wallet.available_minor in {30, 50}
        assert wallet.available_minor >= 0
        assert session.scalar(select(func.count()).select_from(LedgerTransaction)) == 2

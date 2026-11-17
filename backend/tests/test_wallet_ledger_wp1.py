"""Phase 19 WP1 — wallet, immutable ledger, balances, and read APIs.

SQLite checks the conditional balance update. It does not verify PostgreSQL
``SELECT … FOR UPDATE`` concurrency.
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
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session, sessionmaker

from app.api.deps.auth import get_otp_delivery_provider
from app.core.config import get_settings
from app.core.database import get_db
from app.db.base import Base
from app.db.models.business_onboarding import BusinessOnboardingApplication
from app.db.models.identity import User
from app.db.models.wallet import LedgerEntry, LedgerTransaction, Wallet
from app.domain.business_onboarding import BusinessServiceCategory, VerificationStatus
from app.domain.identity import AccountStatus
from app.domain.wallet import (
    AUTHORITATIVE_CURRENCY,
    PLATFORM_WALLET_ID,
    PLATFORM_WALLET_OWNER_ID,
    LedgerAccountType,
    LedgerDirection,
    LedgerImmutableError,
    WalletOwnerType,
)
from app.main import create_app
from app.services.wallet.ledger_service import (
    LedgerLeg,
    WalletPostingError,
    WalletPostingErrorCode,
    balances_from_ledger,
    post_balanced_movement,
)
from app.services.wallet.wallet_service import (
    WalletAccessError,
    WalletAccessErrorCode,
    ensure_platform_wallet,
    get_or_create_business_wallet,
    get_or_create_user_wallet,
    get_or_create_wallet,
)
from tests.support.fake_otp_provider import FakeOtpProvider

import app.db.models  # noqa: F401

_DIGEST_KEY = "t" * 32
BACKEND_ROOT = Path(__file__).resolve().parents[1]


def _phone() -> str:
    return f"+9989014{uuid.uuid4().int % 10000000:07d}"


def _user(session: Session) -> User:
    user = User(phone_e164=_phone(), status=AccountStatus.ACTIVE.value)
    session.add(user)
    session.flush()
    return user


def _business(
    session: Session,
    *,
    owner: User,
    status: VerificationStatus = VerificationStatus.VERIFIED,
) -> BusinessOnboardingApplication:
    application = BusinessOnboardingApplication(
        owner_user_id=owner.id,
        legal_business_name="Baraka LLC",
        trade_display_name="Baraka",
        service_category=BusinessServiceCategory.GROCERIES.value,
        registration_jurisdiction="UZ",
        registration_identifier=f"REG-{uuid.uuid4().hex[:10]}",
        verification_status=status.value,
        rejection_reason_code="other" if status == VerificationStatus.REJECTED else None,
        submitted_at=None if status == VerificationStatus.DRAFT else datetime.now(UTC),
    )
    session.add(application)
    session.flush()
    return application


def _credit_available(session: Session, wallet_id: uuid.UUID, amount: int) -> None:
    result = post_balanced_movement(
        session,
        currency_code=AUTHORITATIVE_CURRENCY,
        legs=[
            LedgerLeg(wallet_id, LedgerAccountType.AVAILABLE, LedgerDirection.CREDIT, amount),
            LedgerLeg(wallet_id, LedgerAccountType.CLEARING, LedgerDirection.DEBIT, amount),
        ],
    )
    assert not isinstance(result, WalletPostingError), result


@pytest.fixture
def engine(tmp_path: Path) -> Generator[Engine, None, None]:
    database = create_engine(
        f"sqlite:///{(tmp_path / 'wallet.db').as_posix()}",
        connect_args={"check_same_thread": False},
    )
    Base.metadata.create_all(database)
    yield database
    database.dispose()


def test_user_wallet_get_or_create_is_idempotent(engine: Engine) -> None:
    with Session(engine) as session:
        user = _user(session)
        first = get_or_create_user_wallet(session, user_id=user.id)
        second = get_or_create_user_wallet(session, user_id=user.id)
        assert isinstance(first, Wallet)
        assert isinstance(second, Wallet)
        assert first.id == second.id
        assert first.owner_type == WalletOwnerType.USER.value
        assert first.owner_id == user.id
        assert first.currency_code == "UZS"
        assert (first.available_minor, first.hold_minor, first.pending_minor) == (0, 0, 0)
        session.commit()
        assert session.scalar(select(func.count()).select_from(Wallet)) == 1


def test_business_wallet_uses_onboarding_application_uuid(engine: Engine) -> None:
    with Session(engine) as session:
        owner = _user(session)
        application = _business(session, owner=owner)
        opened = get_or_create_business_wallet(
            session,
            owner_user_id=owner.id,
            business_application_id=application.id,
        )
        assert isinstance(opened, Wallet)
        assert opened.owner_type == WalletOwnerType.BUSINESS_APPLICATION.value
        assert opened.owner_id == application.id
        session.commit()


def test_business_wallet_rejects_other_owner_and_unverified(engine: Engine) -> None:
    with Session(engine) as session:
        owner = _user(session)
        stranger = _user(session)
        application = _business(session, owner=owner, status=VerificationStatus.SUBMITTED)
        unverified = get_or_create_business_wallet(
            session,
            owner_user_id=owner.id,
            business_application_id=application.id,
        )
        assert isinstance(unverified, WalletAccessError)
        assert unverified.code is WalletAccessErrorCode.BUSINESS_NOT_VERIFIED
        application.verification_status = VerificationStatus.VERIFIED.value
        hidden = get_or_create_business_wallet(
            session,
            owner_user_id=stranger.id,
            business_application_id=application.id,
        )
        assert isinstance(hidden, WalletAccessError)
        assert hidden.code is WalletAccessErrorCode.BUSINESS_NOT_FOUND
        assert session.scalar(select(func.count()).select_from(Wallet)) == 0


def test_platform_wallet_is_single(engine: Engine) -> None:
    with Session(engine) as session:
        first = ensure_platform_wallet(session)
        second = ensure_platform_wallet(session)
        assert isinstance(first, Wallet) and isinstance(second, Wallet)
        assert first.id == second.id == PLATFORM_WALLET_ID
        assert first.owner_id == PLATFORM_WALLET_OWNER_ID
        duplicate = Wallet(
            owner_type=WalletOwnerType.PLATFORM.value,
            owner_id=uuid.uuid4(),
            currency_code="UZS",
            available_minor=0,
            hold_minor=0,
            pending_minor=0,
            status="active",
        )
        session.add(duplicate)
        with pytest.raises(IntegrityError):
            session.flush()


def test_non_authoritative_currency_is_rejected(engine: Engine) -> None:
    with Session(engine) as session:
        user = _user(session)
        rejected = get_or_create_wallet(
            session,
            owner_type=WalletOwnerType.USER,
            owner_id=user.id,
            currency_code="USD",
        )
        assert isinstance(rejected, WalletAccessError)
        assert rejected.code is WalletAccessErrorCode.CURRENCY_MISMATCH
        wallet = get_or_create_user_wallet(session, user_id=user.id)
        assert isinstance(wallet, Wallet)
        _credit_available(session, wallet.id, 40)
        mismatch = post_balanced_movement(
            session,
            currency_code="USD",
            legs=[
                LedgerLeg(wallet.id, LedgerAccountType.AVAILABLE, LedgerDirection.DEBIT, 10),
                LedgerLeg(wallet.id, LedgerAccountType.CLEARING, LedgerDirection.CREDIT, 10),
            ],
        )
        assert isinstance(mismatch, WalletPostingError)
        assert mismatch.code is WalletPostingErrorCode.CURRENCY_MISMATCH
        session.refresh(wallet)
        assert wallet.available_minor == 40
        assert session.scalar(select(func.count()).select_from(LedgerEntry)) == 2


def test_balance_limits_and_zero(engine: Engine) -> None:
    with Session(engine) as session:
        user = _user(session)
        wallet = get_or_create_user_wallet(session, user_id=user.id)
        assert isinstance(wallet, Wallet)
        _credit_available(session, wallet.id, 100)
        over = post_balanced_movement(
            session,
            currency_code="UZS",
            legs=[
                LedgerLeg(wallet.id, LedgerAccountType.AVAILABLE, LedgerDirection.DEBIT, 101),
                LedgerLeg(wallet.id, LedgerAccountType.CLEARING, LedgerDirection.CREDIT, 101),
            ],
        )
        hold = post_balanced_movement(
            session,
            currency_code="UZS",
            legs=[
                LedgerLeg(wallet.id, LedgerAccountType.HOLD, LedgerDirection.DEBIT, 1),
                LedgerLeg(wallet.id, LedgerAccountType.CLEARING, LedgerDirection.CREDIT, 1),
            ],
        )
        pending = post_balanced_movement(
            session,
            currency_code="UZS",
            legs=[
                LedgerLeg(wallet.id, LedgerAccountType.PENDING, LedgerDirection.DEBIT, 1),
                LedgerLeg(wallet.id, LedgerAccountType.CLEARING, LedgerDirection.CREDIT, 1),
            ],
        )
        assert isinstance(over, WalletPostingError)
        assert over.code is WalletPostingErrorCode.INSUFFICIENT_BALANCE
        assert isinstance(hold, WalletPostingError)
        assert isinstance(pending, WalletPostingError)
        exact = post_balanced_movement(
            session,
            currency_code="UZS",
            legs=[
                LedgerLeg(wallet.id, LedgerAccountType.AVAILABLE, LedgerDirection.DEBIT, 100),
                LedgerLeg(wallet.id, LedgerAccountType.CLEARING, LedgerDirection.CREDIT, 100),
            ],
        )
        assert not isinstance(exact, WalletPostingError)
        session.refresh(wallet)
        assert wallet.available_minor == 0
        assert wallet.hold_minor == 0
        assert wallet.pending_minor == 0


def test_ledger_is_balanced_reconcilable_and_immutable(engine: Engine) -> None:
    with Session(engine) as session:
        user = _user(session)
        wallet = get_or_create_user_wallet(session, user_id=user.id)
        assert isinstance(wallet, Wallet)
        _credit_available(session, wallet.id, 80)
        posted = post_balanced_movement(
            session,
            currency_code="UZS",
            legs=[
                LedgerLeg(wallet.id, LedgerAccountType.AVAILABLE, LedgerDirection.DEBIT, 30),
                LedgerLeg(wallet.id, LedgerAccountType.HOLD, LedgerDirection.CREDIT, 30),
            ],
        )
        assert isinstance(posted, LedgerTransaction)
        entries = session.scalars(
            select(LedgerEntry).where(LedgerEntry.ledger_transaction_id == posted.id)
        ).all()
        debit = sum(entry.amount_minor for entry in entries if entry.direction == "debit")
        credit = sum(entry.amount_minor for entry in entries if entry.direction == "credit")
        assert debit == credit == 30
        session.refresh(wallet)
        rebuilt = balances_from_ledger(session, wallet.id)
        assert (rebuilt.available_minor, rebuilt.hold_minor, rebuilt.pending_minor) == (
            wallet.available_minor,
            wallet.hold_minor,
            wallet.pending_minor,
        )
        assert wallet.available_minor == 50
        assert wallet.hold_minor == 30
        session.commit()

    with Session(engine) as session:
        entry = session.scalars(select(LedgerEntry)).first()
        assert entry is not None
        entry.amount_minor = 1
        with pytest.raises(LedgerImmutableError):
            session.flush()
        session.rollback()

    with Session(engine) as session:
        entry = session.scalars(select(LedgerEntry)).first()
        assert entry is not None
        session.delete(entry)
        with pytest.raises(LedgerImmutableError):
            session.flush()


def test_failed_posting_leaves_no_partial_rows(engine: Engine) -> None:
    with Session(engine) as session:
        user = _user(session)
        other = _user(session)
        funded = get_or_create_user_wallet(session, user_id=user.id)
        empty = get_or_create_user_wallet(session, user_id=other.id)
        assert isinstance(funded, Wallet) and isinstance(empty, Wallet)
        _credit_available(session, funded.id, 100)
        before = session.scalar(select(func.count()).select_from(LedgerEntry))
        failed = post_balanced_movement(
            session,
            currency_code="UZS",
            legs=[
                LedgerLeg(funded.id, LedgerAccountType.AVAILABLE, LedgerDirection.DEBIT, 40),
                LedgerLeg(empty.id, LedgerAccountType.AVAILABLE, LedgerDirection.DEBIT, 10),
                LedgerLeg(funded.id, LedgerAccountType.CLEARING, LedgerDirection.CREDIT, 50),
            ],
        )
        assert isinstance(failed, WalletPostingError)
        assert failed.code is WalletPostingErrorCode.INSUFFICIENT_BALANCE
        session.refresh(funded)
        session.refresh(empty)
        assert funded.available_minor == 100
        assert empty.available_minor == 0
        assert session.scalar(select(func.count()).select_from(LedgerEntry)) == before
        unbalanced = post_balanced_movement(
            session,
            currency_code="UZS",
            legs=[
                LedgerLeg(funded.id, LedgerAccountType.AVAILABLE, LedgerDirection.DEBIT, 10),
                LedgerLeg(funded.id, LedgerAccountType.CLEARING, LedgerDirection.CREDIT, 9),
            ],
        )
        assert isinstance(unbalanced, WalletPostingError)
        assert unbalanced.code is WalletPostingErrorCode.UNBALANCED_LEDGER
        assert session.scalar(select(func.count()).select_from(LedgerEntry)) == before


def test_sqlite_second_debit_cannot_overdraw(engine: Engine) -> None:
    """Sequential SQLite guard. This is not a PostgreSQL lock verification."""

    with Session(engine) as session:
        user = _user(session)
        wallet = get_or_create_user_wallet(session, user_id=user.id)
        assert isinstance(wallet, Wallet)
        _credit_available(session, wallet.id, 100)
        first = post_balanced_movement(
            session,
            currency_code="UZS",
            legs=[
                LedgerLeg(wallet.id, LedgerAccountType.AVAILABLE, LedgerDirection.DEBIT, 70),
                LedgerLeg(wallet.id, LedgerAccountType.CLEARING, LedgerDirection.CREDIT, 70),
            ],
        )
        second = post_balanced_movement(
            session,
            currency_code="UZS",
            legs=[
                LedgerLeg(wallet.id, LedgerAccountType.AVAILABLE, LedgerDirection.DEBIT, 50),
                LedgerLeg(wallet.id, LedgerAccountType.CLEARING, LedgerDirection.CREDIT, 50),
            ],
        )
        assert not isinstance(first, WalletPostingError)
        assert isinstance(second, WalletPostingError)
        session.refresh(wallet)
        assert wallet.available_minor == 30


def test_public_api_has_no_ledger_mutation() -> None:
    app = create_app()
    for route in app.routes:
        path = getattr(route, "path", "")
        methods = set(getattr(route, "methods", set()) or set())
        assert "ledger" not in path
        if path.endswith("/wallets/me") or path.endswith("/wallet"):
            assert methods.isdisjoint({"POST", "PUT", "PATCH", "DELETE"})


@pytest.fixture
def api_engine(tmp_path: Path, monkeypatch: pytest.MonkeyPatch) -> Generator[Engine, None, None]:
    url = f"sqlite:///{(tmp_path / 'wallet_api.db').as_posix()}"
    monkeypatch.delenv("DATABASE_URL", raising=False)
    monkeypatch.setenv("QOSHNI_DATABASE_URL", url)
    monkeypatch.setenv("QOSHNI_AUTH_SECRET_DIGEST_KEY", _DIGEST_KEY)
    monkeypatch.delenv("QOSHNI_CONSUMER_CATALOG_ENABLED", raising=False)
    get_settings.cache_clear()
    database = create_engine(url, connect_args={"check_same_thread": False})
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
    verify = client.post(
        "/api/v1/auth/otp/verify",
        json={"challenge_id": challenge.json()["challenge_id"], "code": provider.last_code},
    )
    assert verify.status_code == 200, verify.text
    return str(verify.json()["access_token"])


def test_wallet_http_auth_and_ownership(api_engine: Engine) -> None:
    provider = FakeOtpProvider()
    owner_phone = _phone()
    other_phone = _phone()
    with _client(api_engine, provider) as client:
        missing = client.get("/api/v1/wallets/me")
        assert missing.status_code == 401
        owner_token = _sign_in(client, provider, owner_phone)
        other_token = _sign_in(client, provider, other_phone)
        with Session(api_engine) as session:
            owner = session.scalar(select(User).where(User.phone_e164 == owner_phone))
            assert owner is not None
            application = _business(session, owner=owner, status=VerificationStatus.SUBMITTED)
            session.commit()
            application_id = application.id
            owner_id = owner.id

        denied = client.get(
            f"/api/v1/business/onboarding/applications/{application_id}/wallet",
            headers={"Authorization": f"Bearer {owner_token}"},
        )
        assert denied.status_code == 403
        assert denied.json()["detail"]["code"] == "business_not_verified"
        profile_shaped = client.get(
            "/api/v1/business/onboarding/applications/sample-rental-tools/wallet",
            headers={"Authorization": f"Bearer {owner_token}"},
        )
        assert profile_shaped.status_code == 422

        with Session(api_engine) as session:
            application = session.get(BusinessOnboardingApplication, application_id)
            assert application is not None
            application.verification_status = VerificationStatus.VERIFIED.value
            session.commit()

        opened = client.get(
            f"/api/v1/business/onboarding/applications/{application_id}/wallet",
            headers={"Authorization": f"Bearer {owner_token}"},
        )
        assert opened.status_code == 200, opened.text
        body = opened.json()
        assert body["owner_type"] == "business_application"
        assert body["owner_id"] == str(application_id)
        assert body["available_minor"] == 0
        again = client.get(
            f"/api/v1/business/onboarding/applications/{application_id}/wallet",
            headers={"Authorization": f"Bearer {owner_token}"},
        )
        assert again.json()["wallet_id"] == body["wallet_id"]
        hidden = client.get(
            f"/api/v1/business/onboarding/applications/{application_id}/wallet",
            headers={"Authorization": f"Bearer {other_token}"},
        )
        assert hidden.status_code == 404
        assert hidden.json()["detail"]["code"] == "business_not_found"

        mine = client.get("/api/v1/wallets/me", headers={"Authorization": f"Bearer {owner_token}"})
        theirs = client.get("/api/v1/wallets/me", headers={"Authorization": f"Bearer {other_token}"})
        assert mine.status_code == 200
        assert theirs.status_code == 200
        assert mine.json()["owner_id"] == str(owner_id)
        assert mine.json()["wallet_id"] != theirs.json()["wallet_id"]
        assert "sample-rental-tools" not in mine.text


@pytest.fixture
def alembic_engine(tmp_path: Path, monkeypatch: pytest.MonkeyPatch) -> Generator[tuple[Config, Engine], None, None]:
    url = f"sqlite:///{(tmp_path / 'wallet_migration.db').as_posix()}"
    monkeypatch.delenv("DATABASE_URL", raising=False)
    monkeypatch.setenv("QOSHNI_DATABASE_URL", url)
    get_settings.cache_clear()
    config = Config()
    config.set_main_option("script_location", str(BACKEND_ROOT / "alembic"))
    database = create_engine(url)
    yield config, database
    database.dispose()
    get_settings.cache_clear()


def test_migration_chain_and_platform_wallet(alembic_engine: tuple[Config, Engine]) -> None:
    config, database = alembic_engine
    command.upgrade(config, "head")
    inspector = inspect(database)
    assert inspector.get_table_names()
    assert "wallets" in inspector.get_table_names()
    assert "ledger_entries" in inspector.get_table_names()
    with Session(database) as session:
        platform = session.get(Wallet, PLATFORM_WALLET_ID)
        assert platform is not None
        assert platform.owner_id == PLATFORM_WALLET_OWNER_ID
        assert platform.currency_code == "UZS"
        assert session.scalar(
            select(func.count()).select_from(Wallet).where(Wallet.owner_type == "platform")
        ) == 1
    command.downgrade(config, "b0a1f0180004")
    names = set(inspect(database).get_table_names())
    assert "wallets" not in names
    assert "ledger_entries" not in names
    assert "ledger_transactions" not in names
    command.upgrade(config, "head")
    assert "wallets" in inspect(database).get_table_names()


def test_catalog_flag_stays_off_by_default(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.delenv("QOSHNI_CONSUMER_CATALOG_ENABLED", raising=False)
    get_settings.cache_clear()
    assert get_settings().consumer_catalog_enabled is False

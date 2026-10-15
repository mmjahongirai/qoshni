"""Database-enforced active registration duplicate protection."""

from __future__ import annotations

import uuid
from collections.abc import Generator
from datetime import UTC, datetime
from unittest.mock import patch

import pytest
from sqlalchemy import create_engine, event, inspect, select, text
from sqlalchemy.engine import Engine
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session, sessionmaker

from alembic import command
from alembic.config import Config
from pathlib import Path

from app.db.base import Base
from app.db.models import User
from app.db.models.business_onboarding import (
    BusinessOnboardingApplication,
    BusinessOnboardingAuditEvent,
)
from app.domain.business_onboarding import (
    ACTIVE_REGISTRATION_UNIQUE_INDEX,
    OnboardingAuditEventType,
    VerificationStatus,
)
from app.services.business_onboarding.onboarding_service import (
    OnboardingServiceErrorCode,
    submit_application,
)

BACKEND_ROOT = Path(__file__).resolve().parents[1]


@pytest.fixture
def engine() -> Generator[Engine, None, None]:
    sqlite_engine = create_engine("sqlite://")

    @event.listens_for(sqlite_engine, "connect")
    def _enable_foreign_keys(dbapi_connection, _record) -> None:
        dbapi_connection.execute("PRAGMA foreign_keys=ON")

    Base.metadata.create_all(sqlite_engine)
    yield sqlite_engine
    sqlite_engine.dispose()


@pytest.fixture
def session(engine: Engine) -> Generator[Session, None, None]:
    with Session(engine) as db_session:
        yield db_session


def _owner(session: Session, phone: str) -> uuid.UUID:
    user = User(phone_e164=phone)
    session.add(user)
    session.flush()
    return user.id


def test_two_drafts_same_registration_identifier_allowed(session: Session) -> None:
    owner = _owner(session, "+998901111111")
    session.add_all(
        [
            BusinessOnboardingApplication(
                owner_user_id=owner,
                registration_identifier="DUP-DRAFT",
            ),
            BusinessOnboardingApplication(
                owner_user_id=owner,
                registration_identifier="DUP-DRAFT",
            ),
        ],
    )
    session.commit()
    assert len(session.scalars(select(BusinessOnboardingApplication)).all()) == 2


def test_active_partial_unique_index_blocks_second_submitted_row(session: Session) -> None:
    owner_a = _owner(session, "+998902222222")
    owner_b = _owner(session, "+998903333333")
    now = datetime.now(UTC)
    session.add(
        BusinessOnboardingApplication(
            owner_user_id=owner_a,
            registration_jurisdiction="UZ",
            registration_identifier="REG-ACTIVE",
            verification_status=VerificationStatus.SUBMITTED.value,
            submitted_at=now,
            legal_business_name="First",
            service_category="shops",
        ),
    )
    session.commit()

    session.add(
        BusinessOnboardingApplication(
            owner_user_id=owner_b,
            registration_jurisdiction="UZ",
            registration_identifier="REG-ACTIVE",
            verification_status=VerificationStatus.SUBMITTED.value,
            submitted_at=now,
            legal_business_name="Second",
            service_category="shops",
        ),
    )
    with pytest.raises(IntegrityError):
        session.commit()


def test_rejected_record_does_not_block_active_uniqueness(session: Session) -> None:
    owner = _owner(session, "+998904444444")
    now = datetime.now(UTC)
    session.add(
        BusinessOnboardingApplication(
            owner_user_id=owner,
            registration_jurisdiction="UZ",
            registration_identifier="REG-REJ",
            verification_status=VerificationStatus.REJECTED.value,
            rejection_reason_code="other",
            submitted_at=now,
            legal_business_name="Rejected",
            service_category="shops",
        ),
    )
    session.commit()

    session.add(
        BusinessOnboardingApplication(
            owner_user_id=owner,
            registration_identifier="REG-REJ",
            verification_status=VerificationStatus.SUBMITTED.value,
            submitted_at=now,
            legal_business_name="New submit",
            service_category="shops",
        ),
    )
    session.commit()


def test_jurisdiction_is_part_of_uniqueness(session: Session) -> None:
    owner = _owner(session, "+998905555555")
    now = datetime.now(UTC)
    session.add(
        BusinessOnboardingApplication(
            owner_user_id=owner,
            registration_jurisdiction="UZ",
            registration_identifier="REG-JUR",
            verification_status=VerificationStatus.SUBMITTED.value,
            submitted_at=now,
            legal_business_name="UZ Co",
            service_category="shops",
        ),
    )
    session.add(
        BusinessOnboardingApplication(
            owner_user_id=owner,
            registration_jurisdiction="KZ",
            registration_identifier="REG-JUR",
            verification_status=VerificationStatus.SUBMITTED.value,
            submitted_at=now,
            legal_business_name="KZ Co",
            service_category="shops",
        ),
    )
    session.commit()


def test_trimmed_registration_identifier_required(session: Session) -> None:
    owner = _owner(session, "+998906666666")
    session.add(
        BusinessOnboardingApplication(
            owner_user_id=owner,
            registration_identifier="  spaced  ",
        ),
    )
    with pytest.raises(IntegrityError):
        session.commit()


def test_submit_normalizes_whitespace_before_uniqueness(session: Session) -> None:
    from app.api.schemas.business_onboarding import OnboardingApplicationDraftUpdateRequest
    from app.services.business_onboarding.onboarding_service import update_draft_application

    owner_a = _owner(session, "+998907777777")
    owner_b = _owner(session, "+998908888888")
    app_a = BusinessOnboardingApplication(
        owner_user_id=owner_a,
        legal_business_name="A",
        service_category="shops",
    )
    app_b = BusinessOnboardingApplication(
        owner_user_id=owner_b,
        legal_business_name="B",
        service_category="shops",
        registration_identifier="WS-1",
    )
    session.add_all([app_a, app_b])
    session.commit()
    update_draft_application(
        session,
        owner_user_id=owner_a,
        application_id=app_a.id,
        payload=OnboardingApplicationDraftUpdateRequest(
            registration_identifier="  WS-1  ",
        ),
    )
    session.commit()

    first = submit_application(session, owner_user_id=owner_a, application_id=app_a.id)
    assert isinstance(first, BusinessOnboardingApplication)
    session.commit()

    with patch(
        "app.services.business_onboarding.onboarding_service._find_registration_conflict",
        return_value=False,
    ):
        result = submit_application(
            session,
            owner_user_id=owner_b,
            application_id=app_b.id,
        )
    from app.services.business_onboarding.onboarding_service import OnboardingServiceError

    assert isinstance(result, OnboardingServiceError)
    assert result.code == OnboardingServiceErrorCode.VALIDATION_FAILED


def test_unique_violation_does_not_persist_failed_submit_audit(session: Session) -> None:
    owner_a = _owner(session, "+998909999999")
    owner_b = _owner(session, "+998900000001")
    app_a = BusinessOnboardingApplication(
        owner_user_id=owner_a,
        legal_business_name="A",
        service_category="shops",
        registration_identifier="AUD-1",
    )
    app_b = BusinessOnboardingApplication(
        owner_user_id=owner_b,
        legal_business_name="B",
        service_category="shops",
        registration_identifier="AUD-1",
    )
    session.add_all([app_a, app_b])
    session.commit()

    submit_application(session, owner_user_id=owner_a, application_id=app_a.id)
    session.commit()

    factory = sessionmaker(bind=session.get_bind(), autoflush=False, autocommit=False)
    with Session(bind=session.get_bind()) as session_b:
        with patch(
            "app.services.business_onboarding.onboarding_service._find_registration_conflict",
            return_value=False,
        ):
            result = submit_application(
                session_b,
                owner_user_id=owner_b,
                application_id=app_b.id,
            )
        from app.services.business_onboarding.onboarding_service import OnboardingServiceError

        assert isinstance(result, OnboardingServiceError)
        assert result.code == OnboardingServiceErrorCode.VALIDATION_FAILED
        session_b.commit()

    with Session(bind=session.get_bind()) as verify:
        assert (
            verify.scalar(
                select(BusinessOnboardingApplication).where(
                    BusinessOnboardingApplication.id == app_b.id,
                ),
            ).verification_status
            == VerificationStatus.DRAFT.value
        )
        submit_audits = verify.scalars(
            select(BusinessOnboardingAuditEvent).where(
                BusinessOnboardingAuditEvent.application_id == app_b.id,
                BusinessOnboardingAuditEvent.event_type == OnboardingAuditEventType.SUBMITTED.value,
            ),
        ).all()
        assert submit_audits == []


def test_migration_creates_partial_unique_index(tmp_path: Path, monkeypatch: pytest.MonkeyPatch) -> None:
    from app.core.config import get_settings

    url = f"sqlite:///{(tmp_path / 'uniq_migration.db').as_posix()}"
    monkeypatch.delenv("DATABASE_URL", raising=False)
    monkeypatch.setenv("QOSHNI_DATABASE_URL", url)
    get_settings.cache_clear()

    config = Config()
    config.set_main_option("script_location", str(BACKEND_ROOT / "alembic"))
    command.upgrade(config, "head")

    engine = create_engine(url)
    inspector = inspect(engine)
    indexes = inspector.get_indexes("business_onboarding_applications")
    assert any(index["name"] == ACTIVE_REGISTRATION_UNIQUE_INDEX for index in indexes)
    engine.dispose()
    get_settings.cache_clear()

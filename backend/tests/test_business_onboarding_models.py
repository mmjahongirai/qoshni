"""Business onboarding application and audit model constraints."""

import uuid
from collections.abc import Generator
from datetime import UTC, datetime

import pytest
from sqlalchemy import create_engine, event, select
from sqlalchemy.engine import Engine
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from app.db.base import Base
from app.db.models import BusinessOnboardingApplication, BusinessOnboardingAuditEvent, User
from app.domain.business_onboarding import (
    BusinessServiceCategory,
    OnboardingAuditActorRole,
    OnboardingAuditEventType,
    OnboardingRejectionReasonCode,
    VerificationStatus,
)


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


def _user(phone: str = "+998901234567") -> User:
    return User(phone_e164=phone)


def test_application_defaults_to_draft(session: Session) -> None:
    user = _user()
    session.add(user)
    session.flush()
    application = BusinessOnboardingApplication(owner_user_id=user.id)
    session.add(application)
    session.commit()

    assert application.verification_status == VerificationStatus.DRAFT.value
    assert application.registration_jurisdiction == "UZ"
    assert application.submitted_at is None
    assert application.rejection_reason_code is None
    assert isinstance(application.created_at, datetime)


def test_owner_may_have_multiple_applications(session: Session) -> None:
    user = _user()
    session.add(user)
    session.flush()
    session.add_all(
        [
            BusinessOnboardingApplication(
                owner_user_id=user.id,
                legal_business_name="Alpha LLC",
            ),
            BusinessOnboardingApplication(
                owner_user_id=user.id,
                legal_business_name="Beta LLC",
            ),
        ],
    )
    session.commit()

    assert len(session.scalars(select(BusinessOnboardingApplication)).all()) == 2


def test_invalid_service_category_rejected(session: Session) -> None:
    user = _user()
    session.add(user)
    session.flush()
    session.add(
        BusinessOnboardingApplication(
            owner_user_id=user.id,
            service_category="invalid",
        ),
    )

    with pytest.raises(IntegrityError):
        session.commit()


def test_rejected_status_requires_reason_code(session: Session) -> None:
    user = _user()
    session.add(user)
    session.flush()
    session.add(
        BusinessOnboardingApplication(
            owner_user_id=user.id,
            verification_status=VerificationStatus.REJECTED.value,
            submitted_at=datetime.now(UTC),
        ),
    )

    with pytest.raises(IntegrityError):
        session.commit()


def test_reason_code_only_when_rejected(session: Session) -> None:
    user = _user()
    session.add(user)
    session.flush()
    session.add(
        BusinessOnboardingApplication(
            owner_user_id=user.id,
            verification_status=VerificationStatus.DRAFT.value,
            rejection_reason_code=OnboardingRejectionReasonCode.OTHER.value,
        ),
    )

    with pytest.raises(IntegrityError):
        session.commit()


def test_non_draft_requires_submitted_timestamp(session: Session) -> None:
    user = _user()
    session.add(user)
    session.flush()
    session.add(
        BusinessOnboardingApplication(
            owner_user_id=user.id,
            verification_status=VerificationStatus.SUBMITTED.value,
        ),
    )

    with pytest.raises(IntegrityError):
        session.commit()


def test_application_requires_existing_owner(session: Session) -> None:
    session.add(BusinessOnboardingApplication(owner_user_id=uuid.uuid4()))

    with pytest.raises(IntegrityError):
        session.commit()


def test_duplicate_registration_identifier_allowed_across_owners(session: Session) -> None:
    owner_a = _user("+998901111111")
    owner_b = _user("+998902222222")
    session.add_all([owner_a, owner_b])
    session.flush()
    session.add_all(
        [
            BusinessOnboardingApplication(
                owner_user_id=owner_a.id,
                legal_business_name="Shop A",
                registration_identifier="12345",
                submitted_at=datetime.now(UTC),
                verification_status=VerificationStatus.SUBMITTED.value,
            ),
            BusinessOnboardingApplication(
                owner_user_id=owner_b.id,
                legal_business_name="Shop B",
                registration_identifier="12345",
                submitted_at=datetime.now(UTC),
                verification_status=VerificationStatus.SUBMITTED.value,
            ),
        ],
    )
    session.commit()

    assert len(session.scalars(select(BusinessOnboardingApplication)).all()) == 2


def test_audit_event_links_to_application(session: Session) -> None:
    user = _user()
    session.add(user)
    session.flush()
    application = BusinessOnboardingApplication(owner_user_id=user.id)
    session.add(application)
    session.flush()
    session.add(
        BusinessOnboardingAuditEvent(
            application_id=application.id,
            event_type=OnboardingAuditEventType.APPLICATION_CREATED.value,
            actor_role=OnboardingAuditActorRole.OWNER.value,
            actor_user_id=user.id,
        ),
    )
    session.commit()

    event = session.scalars(select(BusinessOnboardingAuditEvent)).one()
    assert event.application_id == application.id


def test_audit_table_excludes_tax_and_document_columns() -> None:
    forbidden = {
        "tax_identifier",
        "registration_identifier",
        "document",
        "file",
        "otp",
        "access_token",
    }
    columns = set(BusinessOnboardingAuditEvent.__table__.columns.keys())
    assert not forbidden & columns


def test_repr_omits_business_names_and_tax_identifiers(session: Session) -> None:
    user = _user()
    session.add(user)
    session.flush()
    application = BusinessOnboardingApplication(
        owner_user_id=user.id,
        legal_business_name="Secret LLC",
        tax_identifier="TAX-999",
        service_category=BusinessServiceCategory.SHOPS.value,
    )
    session.add(application)
    session.commit()

    text = repr(application)
    assert "Secret LLC" not in text
    assert "TAX-999" not in text

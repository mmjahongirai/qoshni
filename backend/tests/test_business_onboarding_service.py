"""Unit tests for onboarding service transitions and duplicate policy."""

from __future__ import annotations

import uuid
from collections.abc import Generator
from datetime import UTC, datetime

import pytest
from sqlalchemy import create_engine, event, select
from sqlalchemy.engine import Engine
from sqlalchemy.orm import Session

from app.api.schemas.business_onboarding import OnboardingApplicationDraftUpdateRequest
from app.db.base import Base
from app.db.models import User
from app.db.models.business_onboarding import BusinessOnboardingApplication, BusinessOnboardingAuditEvent
from app.domain.business_onboarding import OnboardingAuditEventType, VerificationStatus
from app.services.business_onboarding.onboarding_service import (
    OnboardingServiceErrorCode,
    submit_application,
    update_draft_application,
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


def _owner(session: Session, phone: str = "+998901234567") -> uuid.UUID:
    user = User(phone_e164=phone)
    session.add(user)
    session.flush()
    return user.id


def test_owner_cannot_transition_to_verified_via_submit(session: Session) -> None:
    owner_id = _owner(session)
    application = BusinessOnboardingApplication(
        owner_user_id=owner_id,
        verification_status=VerificationStatus.UNDER_REVIEW.value,
        legal_business_name="Ada LLC",
        service_category="shops",
        submitted_at=datetime.now(UTC),
    )
    session.add(application)
    session.commit()

    from app.services.business_onboarding.onboarding_service import OnboardingServiceError

    result = submit_application(
        session,
        owner_user_id=owner_id,
        application_id=application.id,
    )
    assert isinstance(result, OnboardingServiceError)
    assert result.code == OnboardingServiceErrorCode.INVALID_STATUS_TRANSITION


def test_submit_idempotent_without_duplicate_audit(session: Session) -> None:
    owner_id = _owner(session)
    application = BusinessOnboardingApplication(
        owner_user_id=owner_id,
        legal_business_name="Ada LLC",
        service_category="shops",
    )
    session.add(application)
    session.commit()

    first = submit_application(session, owner_user_id=owner_id, application_id=application.id)
    assert not hasattr(first, "code")
    session.commit()

    second = submit_application(session, owner_user_id=owner_id, application_id=application.id)
    assert second.verification_status == VerificationStatus.SUBMITTED.value

    events = session.scalars(
        select(BusinessOnboardingAuditEvent).where(
            BusinessOnboardingAuditEvent.application_id == application.id,
            BusinessOnboardingAuditEvent.event_type == OnboardingAuditEventType.SUBMITTED.value,
        ),
    ).all()
    assert len(events) == 1


def test_update_rejects_non_draft_status(session: Session) -> None:
    owner_id = _owner(session)
    application = BusinessOnboardingApplication(
        owner_user_id=owner_id,
        verification_status=VerificationStatus.SUBMITTED.value,
        legal_business_name="Ada LLC",
        service_category="shops",
        submitted_at=datetime.now(UTC),
    )
    session.add(application)
    session.commit()

    from app.services.business_onboarding.onboarding_service import OnboardingServiceError

    result = update_draft_application(
        session,
        owner_user_id=owner_id,
        application_id=application.id,
        payload=OnboardingApplicationDraftUpdateRequest(legal_business_name="Changed"),
    )
    assert isinstance(result, OnboardingServiceError)
    assert result.code == OnboardingServiceErrorCode.INVALID_STATUS_TRANSITION

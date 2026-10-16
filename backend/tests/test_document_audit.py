"""Document audit helper tests."""

from __future__ import annotations

import uuid

import pytest
from sqlalchemy import create_engine, select
from sqlalchemy.orm import Session

from app.db.base import Base
from app.db.models.business_onboarding import BusinessOnboardingAuditEvent
from app.domain.business_onboarding import OnboardingAuditActorRole, OnboardingAuditEventType
from app.services.business_onboarding.document_audit import (
    DocumentAuditError,
    document_upload_completed_exists,
    record_document_audit,
)


def test_record_document_audit_rejects_forbidden_details() -> None:
    engine = create_engine("sqlite://")
    Base.metadata.create_all(engine)
    with Session(engine) as session:
        with pytest.raises(DocumentAuditError):
            record_document_audit(
                session,
                application_id=uuid.uuid4(),
                event_type=OnboardingAuditEventType.DOCUMENT_REGISTERED,
                actor_role=OnboardingAuditActorRole.OWNER,
                actor_user_id=uuid.uuid4(),
                details={"document_id": str(uuid.uuid4()), "storage_object_key": "private/x"},
            )


def test_document_upload_completed_exists_detects_prior_event() -> None:
    engine = create_engine("sqlite://")
    Base.metadata.create_all(engine)
    application_id = uuid.uuid4()
    document_id = uuid.uuid4()
    with Session(engine) as session:
        record_document_audit(
            session,
            application_id=application_id,
            event_type=OnboardingAuditEventType.DOCUMENT_UPLOAD_COMPLETED,
            actor_role=OnboardingAuditActorRole.OWNER,
            actor_user_id=uuid.uuid4(),
            details={"document_id": str(document_id)},
        )
        session.commit()
        assert document_upload_completed_exists(
            session,
            application_id=application_id,
            document_id=document_id,
        )


def test_document_registered_event_type_allowed_by_check_constraint() -> None:
    engine = create_engine("sqlite://")
    Base.metadata.create_all(engine)
    with Session(engine) as session:
        record_document_audit(
            session,
            application_id=uuid.uuid4(),
            event_type=OnboardingAuditEventType.DOCUMENT_REGISTERED,
            actor_role=OnboardingAuditActorRole.OWNER,
            actor_user_id=uuid.uuid4(),
            details={"document_id": str(uuid.uuid4())},
        )
        session.commit()
        assert session.scalars(select(BusinessOnboardingAuditEvent)).one()

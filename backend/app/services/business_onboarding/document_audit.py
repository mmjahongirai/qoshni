"""Append-only audit helpers for private onboarding documents."""

from __future__ import annotations

import uuid
from typing import Any

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.db.models.business_onboarding import BusinessOnboardingAuditEvent
from app.domain.business_onboarding import OnboardingAuditActorRole, OnboardingAuditEventType
from app.domain.business_onboarding_documents import BusinessOnboardingDocumentLifecycle


class DocumentAuditError(Exception):
    """Invalid document audit payload or persistence failure."""


_ALLOWED_DETAIL_KEYS = frozenset(
    {
        "document_id",
        "from_document_lifecycle",
        "to_document_lifecycle",
        "failure_code",
        "reconciliation_kind",
        "reconciliation_run_id",
        "dry_run",
    },
)

_FORBIDDEN_DETAIL_SUBSTRINGS = (
    "storage_object_key",
    "checksum",
    "tax_",
    "otp",
    "token",
    "secret",
)


def _validate_details(details: dict[str, Any] | None) -> dict[str, Any] | None:
    if details is None:
        return None
    if not isinstance(details, dict):
        raise DocumentAuditError("Audit details must be a mapping.")
    unknown = set(details.keys()) - _ALLOWED_DETAIL_KEYS
    if unknown:
        raise DocumentAuditError("Audit details contain forbidden fields.")
    encoded = str(details).lower()
    for forbidden in _FORBIDDEN_DETAIL_SUBSTRINGS:
        if forbidden in encoded:
            raise DocumentAuditError("Audit details contain forbidden content.")
    if "document_id" in details:
        try:
            uuid.UUID(str(details["document_id"]))
        except ValueError as error:
            raise DocumentAuditError("Audit document_id must be a UUID.") from error
    return details


def record_document_audit(
    session: Session,
    *,
    application_id: uuid.UUID,
    event_type: OnboardingAuditEventType,
    actor_role: OnboardingAuditActorRole,
    actor_user_id: uuid.UUID | None = None,
    details: dict[str, Any] | None = None,
    correlation_id: str | None = None,
) -> None:
    """Append one document audit row to the current session (no commit)."""

    session.add(
        BusinessOnboardingAuditEvent(
            application_id=application_id,
            event_type=event_type.value,
            actor_role=actor_role.value,
            actor_user_id=actor_user_id,
            correlation_id=correlation_id,
            details=_validate_details(details),
        ),
    )


def document_upload_completed_exists(
    session: Session,
    *,
    application_id: uuid.UUID,
    document_id: uuid.UUID,
) -> bool:
    document_key = str(document_id)
    events = session.scalars(
        select(BusinessOnboardingAuditEvent).where(
            BusinessOnboardingAuditEvent.application_id == application_id,
            BusinessOnboardingAuditEvent.event_type
            == OnboardingAuditEventType.DOCUMENT_UPLOAD_COMPLETED.value,
        ),
    ).all()
    return any(
        event.details is not None and str(event.details.get("document_id")) == document_key
        for event in events
    )


def document_upload_failed_exists_for_correlation(
    session: Session,
    *,
    application_id: uuid.UUID,
    correlation_id: str,
) -> bool:
    return (
        session.scalar(
            select(BusinessOnboardingAuditEvent.id).where(
                BusinessOnboardingAuditEvent.application_id == application_id,
                BusinessOnboardingAuditEvent.event_type
                == OnboardingAuditEventType.DOCUMENT_UPLOAD_FAILED.value,
                BusinessOnboardingAuditEvent.correlation_id == correlation_id,
            ),
        )
        is not None
    )


def try_record_document_upload_failed(
    session: Session,
    *,
    application_id: uuid.UUID,
    document_id: uuid.UUID,
    actor_user_id: uuid.UUID,
    failure_code: str,
    correlation_id: str,
) -> None:
    """Best-effort failed-upload audit in a separate commit; never raises."""

    try:
        if document_upload_failed_exists_for_correlation(
            session,
            application_id=application_id,
            correlation_id=correlation_id,
        ):
            return
        record_document_audit(
            session,
            application_id=application_id,
            event_type=OnboardingAuditEventType.DOCUMENT_UPLOAD_FAILED,
            actor_role=OnboardingAuditActorRole.OWNER,
            actor_user_id=actor_user_id,
            correlation_id=correlation_id,
            details={
                "document_id": str(document_id),
                "failure_code": failure_code,
            },
        )
        session.commit()
    except Exception:
        session.rollback()


def lifecycle_detail(value: BusinessOnboardingDocumentLifecycle) -> str:
    return value.value

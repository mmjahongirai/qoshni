"""Owner-scoped business onboarding application workflows."""

from __future__ import annotations

import uuid
from dataclasses import dataclass
from enum import StrEnum

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.api.schemas.business_onboarding import (
    OnboardingApplicationCreateRequest,
    OnboardingApplicationDraftUpdateRequest,
)
from app.db.models.business_onboarding import (
    BusinessOnboardingApplication,
    BusinessOnboardingAuditEvent,
)
from app.domain.business_onboarding import (
    DEFAULT_REGISTRATION_JURISDICTION,
    OnboardingAuditActorRole,
    OnboardingAuditEventType,
    VerificationStatus,
    is_status_transition_permitted,
    owner_may_edit_draft_fields,
)
from app.services.auth.time_utils import utc_now

_ACTIVE_DUPLICATE_STATUSES: tuple[str, ...] = (
    VerificationStatus.SUBMITTED.value,
    VerificationStatus.UNDER_REVIEW.value,
    VerificationStatus.VERIFIED.value,
    VerificationStatus.SUSPENDED.value,
)


class OnboardingServiceErrorCode(StrEnum):
    APPLICATION_NOT_FOUND = "application_not_found"
    FORBIDDEN = "forbidden"
    INVALID_STATUS_TRANSITION = "invalid_status_transition"
    VALIDATION_FAILED = "validation_failed"
    SUSPENDED = "suspended"


@dataclass(frozen=True, slots=True)
class OnboardingServiceError:
    code: OnboardingServiceErrorCode
    message: str


def _normalize_jurisdiction(raw: str | None) -> str:
    if raw is None or not raw.strip():
        return DEFAULT_REGISTRATION_JURISDICTION
    return raw.strip().upper()


def _record_audit(
    session: Session,
    *,
    application_id: uuid.UUID,
    event_type: OnboardingAuditEventType,
    actor_user_id: uuid.UUID,
    actor_role: OnboardingAuditActorRole,
    from_status: VerificationStatus | None = None,
    to_status: VerificationStatus | None = None,
) -> None:
    session.add(
        BusinessOnboardingAuditEvent(
            application_id=application_id,
            event_type=event_type.value,
            from_status=from_status.value if from_status else None,
            to_status=to_status.value if to_status else None,
            actor_role=actor_role.value,
            actor_user_id=actor_user_id,
        ),
    )


def _get_owned_application(
    session: Session,
    *,
    application_id: uuid.UUID,
    owner_user_id: uuid.UUID,
    for_update: bool = False,
) -> BusinessOnboardingApplication | OnboardingServiceError:
    stmt = select(BusinessOnboardingApplication).where(
        BusinessOnboardingApplication.id == application_id,
    )
    if for_update:
        stmt = stmt.with_for_update()
    application = session.scalar(stmt)
    if application is None or application.owner_user_id != owner_user_id:
        return OnboardingServiceError(
            code=OnboardingServiceErrorCode.APPLICATION_NOT_FOUND,
            message="Application not found.",
        )
    return application


def _find_registration_conflict(
    session: Session,
    *,
    jurisdiction: str,
    registration_identifier: str | None,
    exclude_application_id: uuid.UUID,
) -> bool:
    if registration_identifier is None or not registration_identifier.strip():
        return False
    normalized = registration_identifier.strip()
    existing = session.scalar(
        select(BusinessOnboardingApplication.id).where(
            BusinessOnboardingApplication.registration_jurisdiction == jurisdiction,
            BusinessOnboardingApplication.registration_identifier == normalized,
            BusinessOnboardingApplication.verification_status.in_(_ACTIVE_DUPLICATE_STATUSES),
            BusinessOnboardingApplication.id != exclude_application_id,
        ),
    )
    return existing is not None


def create_application(
    session: Session,
    *,
    owner_user_id: uuid.UUID,
    payload: OnboardingApplicationCreateRequest,
) -> BusinessOnboardingApplication | OnboardingServiceError:
    jurisdiction = _normalize_jurisdiction(payload.registration_jurisdiction)
    application = BusinessOnboardingApplication(
        owner_user_id=owner_user_id,
        legal_business_name=payload.legal_business_name,
        trade_display_name=payload.trade_display_name,
        service_category=payload.service_category.value if payload.service_category else None,
        registration_jurisdiction=jurisdiction,
        verification_status=VerificationStatus.DRAFT.value,
    )
    session.add(application)
    session.flush()
    _record_audit(
        session,
        application_id=application.id,
        event_type=OnboardingAuditEventType.APPLICATION_CREATED,
        actor_user_id=owner_user_id,
        actor_role=OnboardingAuditActorRole.OWNER,
        to_status=VerificationStatus.DRAFT,
    )
    session.flush()
    return application


def list_owner_applications(
    session: Session,
    *,
    owner_user_id: uuid.UUID,
) -> list[BusinessOnboardingApplication]:
    return list(
        session.scalars(
            select(BusinessOnboardingApplication)
            .where(BusinessOnboardingApplication.owner_user_id == owner_user_id)
            .order_by(BusinessOnboardingApplication.created_at.desc()),
        ).all(),
    )


def get_owner_application(
    session: Session,
    *,
    owner_user_id: uuid.UUID,
    application_id: uuid.UUID,
) -> BusinessOnboardingApplication | OnboardingServiceError:
    return _get_owned_application(
        session,
        application_id=application_id,
        owner_user_id=owner_user_id,
    )


def update_draft_application(
    session: Session,
    *,
    owner_user_id: uuid.UUID,
    application_id: uuid.UUID,
    payload: OnboardingApplicationDraftUpdateRequest,
) -> BusinessOnboardingApplication | OnboardingServiceError:
    application = _get_owned_application(
        session,
        application_id=application_id,
        owner_user_id=owner_user_id,
        for_update=True,
    )
    if isinstance(application, OnboardingServiceError):
        return application

    status = VerificationStatus(application.verification_status)
    if status == VerificationStatus.SUSPENDED:
        return OnboardingServiceError(
            code=OnboardingServiceErrorCode.SUSPENDED,
            message="Application is suspended.",
        )
    if not owner_may_edit_draft_fields(status):
        return OnboardingServiceError(
            code=OnboardingServiceErrorCode.INVALID_STATUS_TRANSITION,
            message="Application cannot be edited in its current status.",
        )

    fields_set = payload.model_fields_set

    if payload.clear_legal_business_name:
        application.legal_business_name = None
    elif "legal_business_name" in fields_set:
        application.legal_business_name = payload.legal_business_name

    if payload.clear_trade_display_name:
        application.trade_display_name = None
    elif "trade_display_name" in fields_set:
        application.trade_display_name = payload.trade_display_name

    if "service_category" in fields_set:
        application.service_category = (
            payload.service_category.value if payload.service_category else None
        )

    if "registration_jurisdiction" in fields_set and payload.registration_jurisdiction is not None:
        application.registration_jurisdiction = _normalize_jurisdiction(
            payload.registration_jurisdiction,
        )

    if payload.clear_registration_identifier:
        application.registration_identifier = None
    elif "registration_identifier" in fields_set:
        application.registration_identifier = payload.registration_identifier

    if payload.clear_tax_identifier:
        application.tax_identifier = None
    elif "tax_identifier" in fields_set:
        application.tax_identifier = payload.tax_identifier

    if payload.clear_business_contact_email:
        application.business_contact_email = None
    elif "business_contact_email" in fields_set:
        application.business_contact_email = payload.business_contact_email

    _record_audit(
        session,
        application_id=application.id,
        event_type=OnboardingAuditEventType.DRAFT_UPDATED,
        actor_user_id=owner_user_id,
        actor_role=OnboardingAuditActorRole.OWNER,
        from_status=status,
        to_status=status,
    )
    session.flush()
    return application


def _validate_ready_for_submit(application: BusinessOnboardingApplication) -> OnboardingServiceError | None:
    if not application.legal_business_name or not application.legal_business_name.strip():
        return OnboardingServiceError(
            code=OnboardingServiceErrorCode.VALIDATION_FAILED,
            message="Legal business name is required before submission.",
        )
    if not application.service_category:
        return OnboardingServiceError(
            code=OnboardingServiceErrorCode.VALIDATION_FAILED,
            message="Service category is required before submission.",
        )
    return None


def submit_application(
    session: Session,
    *,
    owner_user_id: uuid.UUID,
    application_id: uuid.UUID,
) -> BusinessOnboardingApplication | OnboardingServiceError:
    application = _get_owned_application(
        session,
        application_id=application_id,
        owner_user_id=owner_user_id,
        for_update=True,
    )
    if isinstance(application, OnboardingServiceError):
        return application

    current = VerificationStatus(application.verification_status)

    if current == VerificationStatus.SUBMITTED:
        return application

    if current == VerificationStatus.SUSPENDED:
        return OnboardingServiceError(
            code=OnboardingServiceErrorCode.SUSPENDED,
            message="Application is suspended.",
        )

    if not is_status_transition_permitted(
        from_status=current,
        to_status=VerificationStatus.SUBMITTED,
        actor_role=OnboardingAuditActorRole.OWNER,
    ):
        return OnboardingServiceError(
            code=OnboardingServiceErrorCode.INVALID_STATUS_TRANSITION,
            message="Application cannot be submitted in its current status.",
        )

    validation_error = _validate_ready_for_submit(application)
    if validation_error is not None:
        return validation_error

    if _find_registration_conflict(
        session,
        jurisdiction=application.registration_jurisdiction,
        registration_identifier=application.registration_identifier,
        exclude_application_id=application.id,
    ):
        return OnboardingServiceError(
            code=OnboardingServiceErrorCode.VALIDATION_FAILED,
            message="An application with this registration identifier is already in review.",
        )

    now = utc_now()
    application.verification_status = VerificationStatus.SUBMITTED.value
    application.submitted_at = now

    _record_audit(
        session,
        application_id=application.id,
        event_type=OnboardingAuditEventType.SUBMITTED,
        actor_user_id=owner_user_id,
        actor_role=OnboardingAuditActorRole.OWNER,
        from_status=current,
        to_status=VerificationStatus.SUBMITTED,
    )
    session.flush()
    return application

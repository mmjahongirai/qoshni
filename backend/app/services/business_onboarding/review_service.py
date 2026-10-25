"""Privileged business onboarding review workflows (Phase 07 Part 5)."""

from __future__ import annotations

import uuid

from sqlalchemy import select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from app.api.schemas.business_onboarding import PrivilegedRejectRequest
from app.db.models.business_onboarding import BusinessOnboardingApplication
from app.domain.business_onboarding import (
    OnboardingAuditActorRole,
    OnboardingAuditEventType,
    OnboardingRejectionReasonCode,
    VerificationStatus,
    is_status_transition_permitted,
    normalize_registration_identifier,
)
from app.services.auth.time_utils import utc_now
from app.services.business_onboarding.onboarding_service import (
    OnboardingServiceError,
    OnboardingServiceErrorCode,
    _duplicate_registration_error,
    _find_registration_conflict,
    _is_active_registration_unique_violation,
    _record_audit,
)
from app.services.search_discovery.sync import sync_search_index_for_application
from app.services.business_onboarding.review_authorization import (
    ReviewAuthorizationError,
    assert_reviewer_not_application_owner,
)

REVIEWER_QUEUE_STATUSES: tuple[str, ...] = (
    VerificationStatus.SUBMITTED.value,
    VerificationStatus.UNDER_REVIEW.value,
    VerificationStatus.VERIFIED.value,
    VerificationStatus.SUSPENDED.value,
)

REVIEWER_READABLE_STATUSES: tuple[str, ...] = (
    *REVIEWER_QUEUE_STATUSES,
    VerificationStatus.REJECTED.value,
)


def _forbidden_from_review_guard(error: ReviewAuthorizationError) -> OnboardingServiceError:
    return OnboardingServiceError(
        code=OnboardingServiceErrorCode.FORBIDDEN,
        message=error.message,
    )


def _get_review_application(
    session: Session,
    *,
    application_id: uuid.UUID,
    for_update: bool = False,
) -> BusinessOnboardingApplication | OnboardingServiceError:
    stmt = select(BusinessOnboardingApplication).where(
        BusinessOnboardingApplication.id == application_id,
    )
    if for_update:
        stmt = stmt.with_for_update()
    application = session.scalar(stmt)
    if application is None:
        return OnboardingServiceError(
            code=OnboardingServiceErrorCode.APPLICATION_NOT_FOUND,
            message="Application not found.",
        )
    return application


def _guard_self_review(
    *,
    reviewer_user_id: uuid.UUID,
    application: BusinessOnboardingApplication,
) -> OnboardingServiceError | None:
    try:
        assert_reviewer_not_application_owner(
            reviewer_user_id=reviewer_user_id,
            owner_user_id=application.owner_user_id,
        )
    except ReviewAuthorizationError as error:
        return _forbidden_from_review_guard(error)
    return None


def list_review_queue(
    session: Session,
    *,
    reviewer_user_id: uuid.UUID,
) -> list[BusinessOnboardingApplication]:
    rows = session.scalars(
        select(BusinessOnboardingApplication)
        .where(
            BusinessOnboardingApplication.verification_status.in_(REVIEWER_QUEUE_STATUSES),
            BusinessOnboardingApplication.owner_user_id != reviewer_user_id,
        )
        .order_by(
            BusinessOnboardingApplication.submitted_at.desc().nulls_last(),
            BusinessOnboardingApplication.updated_at.desc(),
        ),
    ).all()
    return list(rows)


def get_review_application(
    session: Session,
    *,
    application_id: uuid.UUID,
    reviewer_user_id: uuid.UUID,
) -> BusinessOnboardingApplication | OnboardingServiceError:
    application = _get_review_application(session, application_id=application_id)
    if isinstance(application, OnboardingServiceError):
        return application
    if application.verification_status not in REVIEWER_READABLE_STATUSES:
        return OnboardingServiceError(
            code=OnboardingServiceErrorCode.APPLICATION_NOT_FOUND,
            message="Application not found.",
        )
    guard = _guard_self_review(reviewer_user_id=reviewer_user_id, application=application)
    if guard is not None:
        return guard
    return application


def _transition_status(
    session: Session,
    *,
    application_id: uuid.UUID,
    reviewer_user_id: uuid.UUID,
    target_status: VerificationStatus,
    rejection_reason_code: OnboardingRejectionReasonCode | None = None,
    idempotent_target: VerificationStatus | None = None,
) -> BusinessOnboardingApplication | OnboardingServiceError:
    application = _get_review_application(
        session,
        application_id=application_id,
        for_update=True,
    )
    if isinstance(application, OnboardingServiceError):
        return application

    guard = _guard_self_review(reviewer_user_id=reviewer_user_id, application=application)
    if guard is not None:
        return guard

    current = VerificationStatus(application.verification_status)
    if idempotent_target is not None and current == idempotent_target:
        return application

    if not is_status_transition_permitted(
        from_status=current,
        to_status=target_status,
        actor_role=OnboardingAuditActorRole.REVIEWER,
    ):
        return OnboardingServiceError(
            code=OnboardingServiceErrorCode.INVALID_STATUS_TRANSITION,
            message="Application status cannot be changed as requested.",
        )

    if target_status == VerificationStatus.REJECTED:
        if rejection_reason_code is None:
            return OnboardingServiceError(
                code=OnboardingServiceErrorCode.VALIDATION_FAILED,
                message="Rejection reason code is required.",
            )
        application.rejection_reason_code = rejection_reason_code.value
    elif target_status == VerificationStatus.VERIFIED:
        application.rejection_reason_code = None

    application.registration_identifier = normalize_registration_identifier(
        application.registration_identifier,
    )

    if target_status in {
        VerificationStatus.SUBMITTED,
        VerificationStatus.UNDER_REVIEW,
        VerificationStatus.VERIFIED,
        VerificationStatus.SUSPENDED,
    } and _find_registration_conflict(
        session,
        jurisdiction=application.registration_jurisdiction,
        registration_identifier=application.registration_identifier,
        exclude_application_id=application.id,
    ):
        return _duplicate_registration_error()

    now = utc_now()
    application.verification_status = target_status.value
    if target_status in {
        VerificationStatus.VERIFIED,
        VerificationStatus.REJECTED,
        VerificationStatus.SUSPENDED,
    }:
        application.reviewed_at = now

    _record_audit(
        session,
        application_id=application.id,
        event_type=OnboardingAuditEventType.STATUS_CHANGED,
        actor_user_id=reviewer_user_id,
        actor_role=OnboardingAuditActorRole.REVIEWER,
        from_status=current,
        to_status=target_status,
    )
    try:
        session.flush()
    except IntegrityError as error:
        session.rollback()
        if _is_active_registration_unique_violation(error):
            return _duplicate_registration_error()
        raise
    sync_search_index_for_application(session, application)
    return application


def begin_review(
    session: Session,
    *,
    application_id: uuid.UUID,
    reviewer_user_id: uuid.UUID,
) -> BusinessOnboardingApplication | OnboardingServiceError:
    return _transition_status(
        session,
        application_id=application_id,
        reviewer_user_id=reviewer_user_id,
        target_status=VerificationStatus.UNDER_REVIEW,
        idempotent_target=VerificationStatus.UNDER_REVIEW,
    )


def verify_application(
    session: Session,
    *,
    application_id: uuid.UUID,
    reviewer_user_id: uuid.UUID,
) -> BusinessOnboardingApplication | OnboardingServiceError:
    return _transition_status(
        session,
        application_id=application_id,
        reviewer_user_id=reviewer_user_id,
        target_status=VerificationStatus.VERIFIED,
        idempotent_target=VerificationStatus.VERIFIED,
    )


def reject_application(
    session: Session,
    *,
    application_id: uuid.UUID,
    reviewer_user_id: uuid.UUID,
    payload: PrivilegedRejectRequest,
) -> BusinessOnboardingApplication | OnboardingServiceError:
    application = _get_review_application(
        session,
        application_id=application_id,
        for_update=True,
    )
    if isinstance(application, OnboardingServiceError):
        return application

    guard = _guard_self_review(reviewer_user_id=reviewer_user_id, application=application)
    if guard is not None:
        return guard

    current = VerificationStatus(application.verification_status)
    requested_code = payload.rejection_reason_code.value
    if current == VerificationStatus.REJECTED:
        if application.rejection_reason_code == requested_code:
            return application
        return OnboardingServiceError(
            code=OnboardingServiceErrorCode.INVALID_STATUS_TRANSITION,
            message="Application status cannot be changed as requested.",
        )

    return _transition_status(
        session,
        application_id=application_id,
        reviewer_user_id=reviewer_user_id,
        target_status=VerificationStatus.REJECTED,
        rejection_reason_code=payload.rejection_reason_code,
    )


def suspend_application(
    session: Session,
    *,
    application_id: uuid.UUID,
    reviewer_user_id: uuid.UUID,
) -> BusinessOnboardingApplication | OnboardingServiceError:
    return _transition_status(
        session,
        application_id=application_id,
        reviewer_user_id=reviewer_user_id,
        target_status=VerificationStatus.SUSPENDED,
        idempotent_target=VerificationStatus.SUSPENDED,
    )


def reinstate_application(
    session: Session,
    *,
    application_id: uuid.UUID,
    reviewer_user_id: uuid.UUID,
) -> BusinessOnboardingApplication | OnboardingServiceError:
    return _transition_status(
        session,
        application_id=application_id,
        reviewer_user_id=reviewer_user_id,
        target_status=VerificationStatus.UNDER_REVIEW,
    )

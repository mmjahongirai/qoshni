"""Owner propose / reviewer verify branch coordinates."""

from __future__ import annotations

import uuid
from dataclasses import dataclass
from enum import StrEnum

from sqlalchemy.orm import Session

from app.db.models.branch_coordinates import BusinessOnboardingBranchCoordinate
from app.db.models.business_onboarding import BusinessOnboardingApplication
from app.domain.branch_coordinates import (
    BranchCoordinateSource,
    BranchCoordinateVerificationStatus,
    validate_branch_coordinates,
)
from app.domain.business_onboarding import VerificationStatus
from app.services.auth.time_utils import utc_now
from app.services.business_onboarding.onboarding_service import (
    OnboardingServiceError,
    OnboardingServiceErrorCode,
    get_owner_application,
)
from app.services.search_discovery.branch_coordinate_projection import (
    sync_branch_coordinates_to_search_index,
)


class BranchCoordinateErrorCode(StrEnum):
    NOT_FOUND = "not_found"
    FORBIDDEN = "forbidden"
    VALIDATION_FAILED = "validation_failed"
    STALE_REVISION = "stale_revision"
    INVALID_STATE = "invalid_state"


@dataclass(frozen=True, slots=True)
class BranchCoordinateServiceError:
    code: BranchCoordinateErrorCode
    message: str


def _get_coordinate_row(
    session: Session,
    application_id: uuid.UUID,
) -> BusinessOnboardingBranchCoordinate | None:
    return session.get(BusinessOnboardingBranchCoordinate, application_id)


def propose_branch_coordinates(
    session: Session,
    *,
    owner_user_id: uuid.UUID,
    application_id: uuid.UUID,
    latitude: float,
    longitude: float,
    source: BranchCoordinateSource,
    expected_revision: int | None = None,
) -> BusinessOnboardingBranchCoordinate | BranchCoordinateServiceError:
    application = get_owner_application(
        session,
        owner_user_id=owner_user_id,
        application_id=application_id,
    )
    if isinstance(application, OnboardingServiceError):
        return BranchCoordinateServiceError(
            code=BranchCoordinateErrorCode.FORBIDDEN,
            message="Application not found.",
        )

    validation = validate_branch_coordinates(latitude, longitude)
    if validation is not None:
        return BranchCoordinateServiceError(
            code=BranchCoordinateErrorCode.VALIDATION_FAILED,
            message=validation,
        )

    status = VerificationStatus(application.verification_status)
    if status not in {VerificationStatus.VERIFIED, VerificationStatus.SUSPENDED, VerificationStatus.SUBMITTED, VerificationStatus.UNDER_REVIEW}:
        return BranchCoordinateServiceError(
            code=BranchCoordinateErrorCode.INVALID_STATE,
            message="Coordinates cannot be proposed for this application state.",
        )

    row = _get_coordinate_row(session, application_id)
    now = utc_now()
    if row is None:
        row = BusinessOnboardingBranchCoordinate(
            application_id=application_id,
            latitude=latitude,
            longitude=longitude,
            coordinate_source=source.value,
            verification_status=BranchCoordinateVerificationStatus.PROPOSED.value,
            revision=1,
            proposed_at=now,
        )
        session.add(row)
    else:
        if expected_revision is not None and expected_revision != row.revision:
            return BranchCoordinateServiceError(
                code=BranchCoordinateErrorCode.STALE_REVISION,
                message="Coordinate revision is stale.",
            )
        row.latitude = latitude
        row.longitude = longitude
        row.coordinate_source = source.value
        row.verification_status = BranchCoordinateVerificationStatus.PROPOSED.value
        row.revision = row.revision + 1
        row.verified_revision = None
        row.verified_by_user_id = None
        row.verified_at = None
        row.updated_at = now

    session.flush()
    sync_branch_coordinates_to_search_index(session, application_id)
    return row


def verify_branch_coordinates(
    session: Session,
    *,
    reviewer_user_id: uuid.UUID,
    application_id: uuid.UUID,
) -> BusinessOnboardingBranchCoordinate | BranchCoordinateServiceError:
    application = session.get(BusinessOnboardingApplication, application_id)
    if application is None:
        return BranchCoordinateServiceError(
            code=BranchCoordinateErrorCode.NOT_FOUND,
            message="Application not found.",
        )
    if application.owner_user_id == reviewer_user_id:
        return BranchCoordinateServiceError(
            code=BranchCoordinateErrorCode.FORBIDDEN,
            message="Reviewer cannot verify own application coordinates.",
        )

    row = _get_coordinate_row(session, application_id)
    if row is None or row.verification_status != BranchCoordinateVerificationStatus.PROPOSED.value:
        return BranchCoordinateServiceError(
            code=BranchCoordinateErrorCode.INVALID_STATE,
            message="No proposed coordinates to verify.",
        )

    if VerificationStatus(application.verification_status) != VerificationStatus.VERIFIED:
        return BranchCoordinateServiceError(
            code=BranchCoordinateErrorCode.INVALID_STATE,
            message="Business must be verified before coordinates can be published.",
        )

    now = utc_now()
    row.verification_status = BranchCoordinateVerificationStatus.VERIFIED.value
    row.verified_revision = row.revision
    row.verified_by_user_id = reviewer_user_id
    row.verified_at = now
    row.updated_at = now
    session.flush()
    sync_branch_coordinates_to_search_index(session, application_id)
    return row


def reject_branch_coordinates(
    session: Session,
    *,
    reviewer_user_id: uuid.UUID,
    application_id: uuid.UUID,
) -> BusinessOnboardingBranchCoordinate | BranchCoordinateServiceError:
    application = session.get(BusinessOnboardingApplication, application_id)
    if application is None:
        return BranchCoordinateServiceError(
            code=BranchCoordinateErrorCode.NOT_FOUND,
            message="Application not found.",
        )
    if application.owner_user_id == reviewer_user_id:
        return BranchCoordinateServiceError(
            code=BranchCoordinateErrorCode.FORBIDDEN,
            message="Reviewer cannot reject own application coordinates.",
        )

    row = _get_coordinate_row(session, application_id)
    if row is None:
        return BranchCoordinateServiceError(
            code=BranchCoordinateErrorCode.NOT_FOUND,
            message="No coordinates to reject.",
        )

    now = utc_now()
    row.verification_status = BranchCoordinateVerificationStatus.REJECTED.value
    row.verified_revision = None
    row.verified_by_user_id = None
    row.verified_at = None
    row.updated_at = now
    session.flush()
    sync_branch_coordinates_to_search_index(session, application_id)
    return row


def get_branch_coordinates_view(
    session: Session,
    application_id: uuid.UUID,
) -> BusinessOnboardingBranchCoordinate | None:
    return _get_coordinate_row(session, application_id)

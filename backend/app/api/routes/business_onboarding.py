"""Owner-facing business onboarding endpoints."""

from __future__ import annotations

import uuid

from fastapi import APIRouter, Depends
from fastapi.responses import JSONResponse
from sqlalchemy.orm import Session

from app.api.deps.access import get_current_principal
from app.api.onboarding_responses import onboarding_error_response
from app.api.schemas.business_onboarding import (
    OnboardingApplicationCreateRequest,
    OnboardingApplicationDraftUpdateRequest,
    OnboardingApplicationSubmitRequest,
    OnboardingErrorResponse,
    OnboardingVerificationStatusView,
    OwnerOnboardingApplicationListResponse,
    OwnerOnboardingApplicationView,
    ReviewerOnboardingApplicationView,
)
from app.core.database import get_db
from app.db.models.business_onboarding import BusinessOnboardingApplication
from app.domain.business_onboarding import (
    BusinessServiceCategory,
    OnboardingRejectionReasonCode,
    VerificationStatus,
)
from app.services.auth.principal import AuthenticatedPrincipal
from app.api.branch_coordinate_responses import (
    branch_coordinate_error_response,
    branch_coordinate_view,
)
from app.api.schemas.branch_coordinates import (
    BranchCoordinateProposeRequest,
    BranchCoordinateView,
)
from app.services.business_onboarding.branch_coordinate_service import (
    BranchCoordinateErrorCode,
    BranchCoordinateServiceError,
    get_branch_coordinates_view,
    propose_branch_coordinates,
)
from app.services.business_onboarding.onboarding_service import (
    OnboardingServiceError,
    create_application,
    get_owner_application,
    list_owner_applications,
    submit_application,
    update_draft_application,
)

router = APIRouter(prefix="/business/onboarding", tags=["business-onboarding"])


def _verification_application_fields(
    row: BusinessOnboardingApplication,
) -> dict[str, object]:
    category = (
        BusinessServiceCategory(row.service_category)
        if row.service_category is not None
        else None
    )
    rejection = (
        OnboardingRejectionReasonCode(row.rejection_reason_code)
        if row.rejection_reason_code is not None
        else None
    )
    return {
        "application_id": row.id,
        "legal_business_name": row.legal_business_name,
        "trade_display_name": row.trade_display_name,
        "service_category": category,
        "registration_jurisdiction": row.registration_jurisdiction,
        "registration_identifier": row.registration_identifier,
        "tax_identifier": row.tax_identifier,
        "business_contact_email": row.business_contact_email,
        "verification_status": VerificationStatus(row.verification_status),
        "rejection_reason_code": rejection,
        "submitted_at": row.submitted_at,
        "reviewed_at": row.reviewed_at,
        "created_at": row.created_at,
        "updated_at": row.updated_at,
    }


def _owner_view(row: BusinessOnboardingApplication) -> OwnerOnboardingApplicationView:
    return OwnerOnboardingApplicationView(**_verification_application_fields(row))


def _reviewer_view(row: BusinessOnboardingApplication) -> ReviewerOnboardingApplicationView:
    return ReviewerOnboardingApplicationView(**_verification_application_fields(row))


def _status_view(row: BusinessOnboardingApplication) -> OnboardingVerificationStatusView:
    rejection = (
        OnboardingRejectionReasonCode(row.rejection_reason_code)
        if row.rejection_reason_code is not None
        else None
    )
    return OnboardingVerificationStatusView(
        application_id=row.id,
        verification_status=VerificationStatus(row.verification_status),
        rejection_reason_code=rejection,
        submitted_at=row.submitted_at,
        reviewed_at=row.reviewed_at,
        updated_at=row.updated_at,
    )


@router.post(
    "/applications",
    status_code=201,
    response_model=OwnerOnboardingApplicationView,
    responses={422: {"model": OnboardingErrorResponse}},
)
def start_application(
    payload: OnboardingApplicationCreateRequest,
    db: Session = Depends(get_db),
    principal: AuthenticatedPrincipal = Depends(get_current_principal),
) -> OwnerOnboardingApplicationView | JSONResponse:
    result = create_application(db, owner_user_id=principal.user_id, payload=payload)
    if isinstance(result, OnboardingServiceError):
        return onboarding_error_response(result)
    db.commit()
    return _owner_view(result)


@router.get(
    "/applications",
    response_model=OwnerOnboardingApplicationListResponse,
    responses={404: {"model": OnboardingErrorResponse}},
)
def list_applications(
    db: Session = Depends(get_db),
    principal: AuthenticatedPrincipal = Depends(get_current_principal),
) -> OwnerOnboardingApplicationListResponse:
    rows = list_owner_applications(db, owner_user_id=principal.user_id)
    return OwnerOnboardingApplicationListResponse(applications=[_owner_view(row) for row in rows])


@router.get(
    "/applications/{application_id}",
    response_model=OwnerOnboardingApplicationView,
    responses={404: {"model": OnboardingErrorResponse}},
)
def get_application(
    application_id: uuid.UUID,
    db: Session = Depends(get_db),
    principal: AuthenticatedPrincipal = Depends(get_current_principal),
) -> OwnerOnboardingApplicationView | JSONResponse:
    result = get_owner_application(
        db,
        owner_user_id=principal.user_id,
        application_id=application_id,
    )
    if isinstance(result, OnboardingServiceError):
        return onboarding_error_response(result)
    return _owner_view(result)


@router.patch(
    "/applications/{application_id}",
    response_model=OwnerOnboardingApplicationView,
    responses={
        404: {"model": OnboardingErrorResponse},
        409: {"model": OnboardingErrorResponse},
        422: {"model": OnboardingErrorResponse},
    },
)
def patch_application(
    application_id: uuid.UUID,
    payload: OnboardingApplicationDraftUpdateRequest,
    db: Session = Depends(get_db),
    principal: AuthenticatedPrincipal = Depends(get_current_principal),
) -> OwnerOnboardingApplicationView | JSONResponse:
    result = update_draft_application(
        db,
        owner_user_id=principal.user_id,
        application_id=application_id,
        payload=payload,
    )
    if isinstance(result, OnboardingServiceError):
        return onboarding_error_response(result)
    db.commit()
    return _owner_view(result)


@router.post(
    "/applications/{application_id}/submit",
    response_model=OwnerOnboardingApplicationView,
    responses={
        404: {"model": OnboardingErrorResponse},
        409: {"model": OnboardingErrorResponse},
        422: {"model": OnboardingErrorResponse},
    },
)
def submit_owner_application(
    application_id: uuid.UUID,
    _payload: OnboardingApplicationSubmitRequest,
    db: Session = Depends(get_db),
    principal: AuthenticatedPrincipal = Depends(get_current_principal),
) -> OwnerOnboardingApplicationView | JSONResponse:
    result = submit_application(
        db,
        owner_user_id=principal.user_id,
        application_id=application_id,
    )
    if isinstance(result, OnboardingServiceError):
        return onboarding_error_response(result)
    db.commit()
    return _owner_view(result)


@router.get(
    "/applications/{application_id}/verification-status",
    response_model=OnboardingVerificationStatusView,
    responses={404: {"model": OnboardingErrorResponse}},
)
def read_verification_status(
    application_id: uuid.UUID,
    db: Session = Depends(get_db),
    principal: AuthenticatedPrincipal = Depends(get_current_principal),
) -> OnboardingVerificationStatusView | JSONResponse:
    result = get_owner_application(
        db,
        owner_user_id=principal.user_id,
        application_id=application_id,
    )
    if isinstance(result, OnboardingServiceError):
        return onboarding_error_response(result)
    return _status_view(result)


def _branch_coordinate_http_error(error: BranchCoordinateServiceError) -> JSONResponse:
    status = 400
    if error.code == BranchCoordinateErrorCode.NOT_FOUND:
        status = 404
    elif error.code in {BranchCoordinateErrorCode.FORBIDDEN}:
        status = 403
    elif error.code == BranchCoordinateErrorCode.STALE_REVISION:
        status = 409
    return branch_coordinate_error_response(error.code.value, error.message, status)


@router.get(
    "/applications/{application_id}/branch-coordinates",
    response_model=BranchCoordinateView,
    responses={404: {"description": "Not found"}},
)
def read_branch_coordinates(
    application_id: uuid.UUID,
    db: Session = Depends(get_db),
    principal: AuthenticatedPrincipal = Depends(get_current_principal),
) -> BranchCoordinateView | JSONResponse:
    owned = get_owner_application(
        db,
        owner_user_id=principal.user_id,
        application_id=application_id,
    )
    if isinstance(owned, OnboardingServiceError):
        return onboarding_error_response(owned)
    row = get_branch_coordinates_view(db, application_id)
    if row is None:
        return branch_coordinate_error_response(
            BranchCoordinateErrorCode.NOT_FOUND.value,
            "Branch coordinates not found.",
            404,
        )
    return branch_coordinate_view(row)


@router.put(
    "/applications/{application_id}/branch-coordinates",
    response_model=BranchCoordinateView,
)
def put_branch_coordinates(
    application_id: uuid.UUID,
    payload: BranchCoordinateProposeRequest,
    db: Session = Depends(get_db),
    principal: AuthenticatedPrincipal = Depends(get_current_principal),
) -> BranchCoordinateView | JSONResponse:
    result = propose_branch_coordinates(
        db,
        owner_user_id=principal.user_id,
        application_id=application_id,
        latitude=payload.latitude,
        longitude=payload.longitude,
        source=payload.coordinate_source,
        expected_revision=payload.expected_revision,
    )
    if isinstance(result, BranchCoordinateServiceError):
        return _branch_coordinate_http_error(result)
    db.commit()
    return branch_coordinate_view(result)

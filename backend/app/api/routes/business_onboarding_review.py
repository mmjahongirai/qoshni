"""Privileged business onboarding review endpoints."""

from __future__ import annotations

import uuid

from fastapi import APIRouter, Depends
from fastapi.responses import JSONResponse
from sqlalchemy.orm import Session

from app.api.deps.reviewer import require_business_onboarding_reviewer
from app.api.onboarding_responses import onboarding_error_response
from app.api.routes.business_onboarding import _reviewer_view
from app.api.schemas.business_onboarding import (
    OnboardingErrorResponse,
    PrivilegedRejectRequest,
    PrivilegedReviewDecisionRequest,
    ReviewerOnboardingApplicationListResponse,
    ReviewerOnboardingApplicationView,
)
from app.core.database import get_db
from app.services.auth.principal import BusinessOnboardingReviewerPrincipal
from app.services.business_onboarding.onboarding_service import OnboardingServiceError
from app.services.business_onboarding.review_service import (
    begin_review,
    get_review_application,
    list_review_queue,
    reinstate_application,
    reject_application,
    suspend_application,
    verify_application,
)

router = APIRouter(prefix="/internal/business/onboarding", tags=["business-onboarding-review"])


@router.get(
    "/applications",
    response_model=ReviewerOnboardingApplicationListResponse,
    responses={403: {"description": "Authorization denied"}},
)
def list_reviewer_applications(
    db: Session = Depends(get_db),
    reviewer: BusinessOnboardingReviewerPrincipal = Depends(require_business_onboarding_reviewer),
) -> ReviewerOnboardingApplicationListResponse:
    rows = list_review_queue(db, reviewer_user_id=reviewer.user_id)
    return ReviewerOnboardingApplicationListResponse(
        applications=[_reviewer_view(row) for row in rows],
    )


@router.get(
    "/applications/{application_id}",
    response_model=ReviewerOnboardingApplicationView,
    responses={
        403: {"description": "Forbidden"},
        404: {"model": OnboardingErrorResponse},
    },
)
def get_reviewer_application(
    application_id: uuid.UUID,
    db: Session = Depends(get_db),
    reviewer: BusinessOnboardingReviewerPrincipal = Depends(require_business_onboarding_reviewer),
) -> ReviewerOnboardingApplicationView | JSONResponse:
    result = get_review_application(
        db,
        application_id=application_id,
        reviewer_user_id=reviewer.user_id,
    )
    if isinstance(result, OnboardingServiceError):
        return onboarding_error_response(result)
    return _reviewer_view(result)


@router.post(
    "/applications/{application_id}/begin-review",
    response_model=ReviewerOnboardingApplicationView,
    responses={
        403: {"description": "Forbidden"},
        404: {"model": OnboardingErrorResponse},
        409: {"model": OnboardingErrorResponse},
    },
)
def post_begin_review(
    application_id: uuid.UUID,
    _payload: PrivilegedReviewDecisionRequest,
    db: Session = Depends(get_db),
    reviewer: BusinessOnboardingReviewerPrincipal = Depends(require_business_onboarding_reviewer),
) -> ReviewerOnboardingApplicationView | JSONResponse:
    result = begin_review(
        db,
        application_id=application_id,
        reviewer_user_id=reviewer.user_id,
    )
    if isinstance(result, OnboardingServiceError):
        return onboarding_error_response(result)
    db.commit()
    return _reviewer_view(result)


@router.post(
    "/applications/{application_id}/verify",
    response_model=ReviewerOnboardingApplicationView,
    responses={
        403: {"description": "Forbidden"},
        404: {"model": OnboardingErrorResponse},
        409: {"model": OnboardingErrorResponse},
        422: {"model": OnboardingErrorResponse},
    },
)
def post_verify_application(
    application_id: uuid.UUID,
    _payload: PrivilegedReviewDecisionRequest,
    db: Session = Depends(get_db),
    reviewer: BusinessOnboardingReviewerPrincipal = Depends(require_business_onboarding_reviewer),
) -> ReviewerOnboardingApplicationView | JSONResponse:
    result = verify_application(
        db,
        application_id=application_id,
        reviewer_user_id=reviewer.user_id,
    )
    if isinstance(result, OnboardingServiceError):
        return onboarding_error_response(result)
    db.commit()
    return _reviewer_view(result)


@router.post(
    "/applications/{application_id}/reject",
    response_model=ReviewerOnboardingApplicationView,
    responses={
        403: {"description": "Forbidden"},
        404: {"model": OnboardingErrorResponse},
        409: {"model": OnboardingErrorResponse},
        422: {"model": OnboardingErrorResponse},
    },
)
def post_reject_application(
    application_id: uuid.UUID,
    payload: PrivilegedRejectRequest,
    db: Session = Depends(get_db),
    reviewer: BusinessOnboardingReviewerPrincipal = Depends(require_business_onboarding_reviewer),
) -> ReviewerOnboardingApplicationView | JSONResponse:
    result = reject_application(
        db,
        application_id=application_id,
        reviewer_user_id=reviewer.user_id,
        payload=payload,
    )
    if isinstance(result, OnboardingServiceError):
        return onboarding_error_response(result)
    db.commit()
    return _reviewer_view(result)


@router.post(
    "/applications/{application_id}/suspend",
    response_model=ReviewerOnboardingApplicationView,
    responses={
        403: {"description": "Forbidden"},
        404: {"model": OnboardingErrorResponse},
        409: {"model": OnboardingErrorResponse},
    },
)
def post_suspend_application(
    application_id: uuid.UUID,
    _payload: PrivilegedReviewDecisionRequest,
    db: Session = Depends(get_db),
    reviewer: BusinessOnboardingReviewerPrincipal = Depends(require_business_onboarding_reviewer),
) -> ReviewerOnboardingApplicationView | JSONResponse:
    result = suspend_application(
        db,
        application_id=application_id,
        reviewer_user_id=reviewer.user_id,
    )
    if isinstance(result, OnboardingServiceError):
        return onboarding_error_response(result)
    db.commit()
    return _reviewer_view(result)


@router.post(
    "/applications/{application_id}/reinstate",
    response_model=ReviewerOnboardingApplicationView,
    responses={
        403: {"description": "Forbidden"},
        404: {"model": OnboardingErrorResponse},
        409: {"model": OnboardingErrorResponse},
    },
)
def post_reinstate_application(
    application_id: uuid.UUID,
    _payload: PrivilegedReviewDecisionRequest,
    db: Session = Depends(get_db),
    reviewer: BusinessOnboardingReviewerPrincipal = Depends(require_business_onboarding_reviewer),
) -> ReviewerOnboardingApplicationView | JSONResponse:
    result = reinstate_application(
        db,
        application_id=application_id,
        reviewer_user_id=reviewer.user_id,
    )
    if isinstance(result, OnboardingServiceError):
        return onboarding_error_response(result)
    db.commit()
    return _reviewer_view(result)

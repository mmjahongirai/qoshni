"""Privileged business onboarding review endpoints."""

from __future__ import annotations

import uuid

from fastapi import APIRouter, Depends
from fastapi.responses import JSONResponse, Response
from sqlalchemy.orm import Session

from app.api.deps.object_storage import get_object_storage
from app.api.deps.reviewer import require_business_onboarding_reviewer
from app.api.schemas.business_onboarding_documents import (
    ReviewerOnboardingDocumentListResponse,
    ReviewerOnboardingDocumentView,
)
from app.domain.business_onboarding_documents import (
    BusinessOnboardingDocumentLifecycle,
    BusinessOnboardingDocumentType,
)
from app.db.models.business_onboarding import BusinessOnboardingDocument
from app.core.config import Settings, get_settings
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
from app.services.business_onboarding.reviewer_document_service import (
    download_reviewer_document,
    list_reviewer_application_documents,
)
from app.services.business_onboarding.review_service import (
    begin_review,
    get_review_application,
    list_review_queue,
    reinstate_application,
    reject_application,
    suspend_application,
    verify_application,
)
from app.services.object_storage.port import StoragePort

router = APIRouter(prefix="/internal/business/onboarding", tags=["business-onboarding-review"])


def _reviewer_document_view(document: BusinessOnboardingDocument) -> ReviewerOnboardingDocumentView:
    return ReviewerOnboardingDocumentView(
        document_id=document.id,
        application_id=document.application_id,
        document_type=BusinessOnboardingDocumentType(document.document_type),
        lifecycle_state=BusinessOnboardingDocumentLifecycle(document.lifecycle_state),
        byte_size=document.byte_size,
        created_at=document.created_at,
        updated_at=document.updated_at,
    )


@router.get(
    "/applications/{application_id}/documents",
    response_model=ReviewerOnboardingDocumentListResponse,
    responses={
        403: {"description": "Forbidden"},
        404: {"model": OnboardingErrorResponse},
    },
)
def list_reviewer_documents(
    application_id: uuid.UUID,
    db: Session = Depends(get_db),
    reviewer: BusinessOnboardingReviewerPrincipal = Depends(require_business_onboarding_reviewer),
) -> ReviewerOnboardingDocumentListResponse | JSONResponse:
    result = list_reviewer_application_documents(
        db,
        application_id=application_id,
        reviewer_user_id=reviewer.user_id,
    )
    if isinstance(result, OnboardingServiceError):
        return onboarding_error_response(result)
    return ReviewerOnboardingDocumentListResponse(
        documents=[_reviewer_document_view(document) for document in result],
    )


@router.get(
    "/applications/{application_id}/documents/{document_id}/download",
    response_model=None,
    responses={
        403: {"description": "Forbidden"},
        404: {"model": OnboardingErrorResponse},
        503: {"model": OnboardingErrorResponse},
    },
)
def download_reviewer_document_bytes(
    application_id: uuid.UUID,
    document_id: uuid.UUID,
    db: Session = Depends(get_db),
    reviewer: BusinessOnboardingReviewerPrincipal = Depends(require_business_onboarding_reviewer),
    storage: StoragePort = Depends(get_object_storage),
    settings: Settings = Depends(get_settings),
) -> Response | JSONResponse:
    result = download_reviewer_document(
        db,
        application_id=application_id,
        document_id=document_id,
        reviewer_user_id=reviewer.user_id,
        storage=storage,
        max_bytes=settings.onboarding_document_max_bytes,
    )
    if isinstance(result, OnboardingServiceError):
        return onboarding_error_response(result)
    return Response(
        content=result.data,
        media_type=result.content_type,
        headers={
            "Content-Disposition": f'attachment; filename="{result.filename}"',
            "X-Content-Type-Options": "nosniff",
        },
    )


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

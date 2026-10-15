"""Owner-facing private onboarding document endpoints."""

from __future__ import annotations

import uuid

from fastapi import APIRouter, Depends, File, UploadFile
from fastapi.responses import JSONResponse
from sqlalchemy.orm import Session

from app.api.deps.access import get_current_principal
from app.api.deps.object_storage import get_object_storage
from app.api.onboarding_responses import onboarding_error_response
from app.api.schemas.business_onboarding import OnboardingErrorResponse
from app.api.schemas.business_onboarding_documents import (
    OwnerOnboardingDocumentListResponse,
    OwnerOnboardingDocumentView,
    RegisterOnboardingDocumentRequest,
)
from app.core.config import Settings, get_settings
from app.core.database import get_db
from app.db.models.business_onboarding import BusinessOnboardingDocument
from app.domain.business_onboarding_documents import (
    BusinessOnboardingDocumentLifecycle,
    BusinessOnboardingDocumentType,
)
from app.services.auth.principal import AuthenticatedPrincipal
from app.services.business_onboarding.document_service import (
    list_owner_documents,
    read_bounded_upload,
    register_owner_document,
    upload_owner_document_bytes,
)
from app.services.business_onboarding.onboarding_service import (
    OnboardingServiceError,
    OnboardingServiceErrorCode,
)
from app.services.object_storage.errors import StorageError
from app.services.object_storage.port import StoragePort

router = APIRouter(prefix="/business/onboarding", tags=["business-onboarding-documents"])


def _commit_document_upload(
    db: Session,
    storage: StoragePort,
    *,
    storage_key: str,
) -> OnboardingServiceError | None:
    """Persist upload metadata or compensate storage after a DB failure."""

    try:
        db.commit()
    except Exception:
        db.rollback()
        try:
            storage.delete(storage_key)
        except StorageError:
            pass
        return OnboardingServiceError(
            code=OnboardingServiceErrorCode.STORAGE_UNAVAILABLE,
            message="Document upload could not be completed.",
        )
    return None


def _owner_document_view(document: BusinessOnboardingDocument) -> OwnerOnboardingDocumentView:
    return OwnerOnboardingDocumentView(
        document_id=document.id,
        application_id=document.application_id,
        document_type=BusinessOnboardingDocumentType(document.document_type),
        lifecycle_state=BusinessOnboardingDocumentLifecycle(document.lifecycle_state),
        created_at=document.created_at,
        updated_at=document.updated_at,
    )


@router.post(
    "/applications/{application_id}/documents",
    status_code=201,
    response_model=OwnerOnboardingDocumentView,
    responses={
        404: {"model": OnboardingErrorResponse},
        409: {"model": OnboardingErrorResponse},
        422: {"model": OnboardingErrorResponse},
    },
)
def register_document(
    application_id: uuid.UUID,
    payload: RegisterOnboardingDocumentRequest,
    db: Session = Depends(get_db),
    principal: AuthenticatedPrincipal = Depends(get_current_principal),
) -> OwnerOnboardingDocumentView | JSONResponse:
    result = register_owner_document(
        db,
        owner_user_id=principal.user_id,
        application_id=application_id,
        payload=payload,
    )
    if isinstance(result, OnboardingServiceError):
        return onboarding_error_response(result)
    db.commit()
    return _owner_document_view(result)


@router.get(
    "/applications/{application_id}/documents",
    response_model=OwnerOnboardingDocumentListResponse,
    responses={404: {"model": OnboardingErrorResponse}},
)
def list_documents(
    application_id: uuid.UUID,
    db: Session = Depends(get_db),
    principal: AuthenticatedPrincipal = Depends(get_current_principal),
) -> OwnerOnboardingDocumentListResponse | JSONResponse:
    result = list_owner_documents(
        db,
        owner_user_id=principal.user_id,
        application_id=application_id,
    )
    if isinstance(result, OnboardingServiceError):
        return onboarding_error_response(result)
    return OwnerOnboardingDocumentListResponse(
        documents=[_owner_document_view(document) for document in result],
    )


@router.post(
    "/applications/{application_id}/documents/{document_id}/upload",
    response_model=OwnerOnboardingDocumentView,
    responses={
        404: {"model": OnboardingErrorResponse},
        409: {"model": OnboardingErrorResponse},
        422: {"model": OnboardingErrorResponse},
        503: {"model": OnboardingErrorResponse},
    },
)
def upload_document(
    application_id: uuid.UUID,
    document_id: uuid.UUID,
    file: UploadFile = File(...),
    db: Session = Depends(get_db),
    principal: AuthenticatedPrincipal = Depends(get_current_principal),
    storage: StoragePort = Depends(get_object_storage),
    settings: Settings = Depends(get_settings),
) -> OwnerOnboardingDocumentView | JSONResponse:
    try:
        bounded = read_bounded_upload(
            file.file,
            max_bytes=settings.onboarding_document_max_bytes,
        )
    finally:
        file.file.close()
    if isinstance(bounded, OnboardingServiceError):
        return onboarding_error_response(bounded)

    result = upload_owner_document_bytes(
        db,
        owner_user_id=principal.user_id,
        application_id=application_id,
        document_id=document_id,
        payload=bounded,
        storage=storage,
        max_bytes=settings.onboarding_document_max_bytes,
    )
    if isinstance(result, OnboardingServiceError):
        db.rollback()
        return onboarding_error_response(result)

    commit_error = _commit_document_upload(
        db,
        storage,
        storage_key=result.storage_object_key,
    )
    if commit_error is not None:
        return onboarding_error_response(commit_error)

    return _owner_document_view(result)

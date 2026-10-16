"""Owner-facing private onboarding document endpoints."""

from __future__ import annotations

import uuid

from fastapi import APIRouter, Depends, File, UploadFile
from fastapi.responses import JSONResponse
from sqlalchemy.orm import Session

from app.api.deps.access import get_current_principal
from app.api.deps.malware_scanner import get_malware_scanner
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
from app.services.business_onboarding.document_audit import (
    document_upload_completed_exists,
    lifecycle_detail,
    record_document_audit,
    try_record_document_upload_failed,
)
from app.domain.business_onboarding import OnboardingAuditActorRole, OnboardingAuditEventType
from app.services.business_onboarding.document_service import (
    DocumentUploadResult,
    list_owner_documents,
    read_bounded_upload,
    register_owner_document,
    upload_owner_document_bytes,
)
from app.services.business_onboarding.onboarding_service import (
    OnboardingServiceError,
    OnboardingServiceErrorCode,
)
from app.services.malware_scanning.port import MalwareScannerPort
from app.services.object_storage.errors import StorageError
from app.services.object_storage.port import StoragePort

router = APIRouter(prefix="/business/onboarding", tags=["business-onboarding-documents"])


def _upload_failure_code(error: OnboardingServiceError) -> str:
    if error.code == OnboardingServiceErrorCode.DOCUMENT_REJECTED:
        return "malware_infected"
    if error.code == OnboardingServiceErrorCode.MALWARE_SCAN_UNAVAILABLE:
        return "malware_scan_unavailable"
    return "storage_or_upload_rejected"


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
    scanner: MalwareScannerPort = Depends(get_malware_scanner),
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

    upload_correlation_id = str(uuid.uuid4())
    result = upload_owner_document_bytes(
        db,
        owner_user_id=principal.user_id,
        application_id=application_id,
        document_id=document_id,
        payload=bounded,
        storage=storage,
        scanner=scanner,
        max_bytes=settings.onboarding_document_max_bytes,
    )
    if isinstance(result, OnboardingServiceError):
        db.rollback()
        try_record_document_upload_failed(
            db,
            application_id=application_id,
            document_id=document_id,
            actor_user_id=principal.user_id,
            failure_code=_upload_failure_code(result),
            correlation_id=upload_correlation_id,
        )
        return onboarding_error_response(result)

    upload_result: DocumentUploadResult = result
    document = upload_result.document
    if upload_result.newly_completed and not document_upload_completed_exists(
        db,
        application_id=application_id,
        document_id=document.id,
    ):
        record_document_audit(
            db,
            application_id=application_id,
            event_type=OnboardingAuditEventType.DOCUMENT_UPLOAD_COMPLETED,
            actor_role=OnboardingAuditActorRole.OWNER,
            actor_user_id=principal.user_id,
            correlation_id=upload_correlation_id,
            details={
                "document_id": str(document.id),
                "from_document_lifecycle": lifecycle_detail(
                    BusinessOnboardingDocumentLifecycle.AWAITING_UPLOAD,
                ),
                "to_document_lifecycle": lifecycle_detail(
                    BusinessOnboardingDocumentLifecycle.UPLOADED_PENDING_VALIDATION,
                ),
            },
        )

    commit_error = _commit_document_upload(
        db,
        storage,
        storage_key=document.storage_object_key,
    )
    if commit_error is not None:
        try_record_document_upload_failed(
            db,
            application_id=application_id,
            document_id=document.id,
            actor_user_id=principal.user_id,
            failure_code="db_commit_failed",
            correlation_id=upload_correlation_id,
        )
        return onboarding_error_response(commit_error)

    return _owner_document_view(document)

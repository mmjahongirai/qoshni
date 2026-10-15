"""Owner-scoped private onboarding document workflows."""

from __future__ import annotations

import hashlib
import uuid
from dataclasses import dataclass
from typing import BinaryIO

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.api.schemas.business_onboarding_documents import RegisterOnboardingDocumentRequest
from app.db.models.business_onboarding import BusinessOnboardingDocument
from app.domain.business_onboarding import (
    OnboardingAuditActorRole,
    OnboardingAuditEventType,
    VerificationStatus,
)
from app.domain.business_onboarding_documents import BusinessOnboardingDocumentLifecycle
from app.services.business_onboarding.document_audit import (
    lifecycle_detail,
    record_document_audit,
)
from app.services.business_onboarding.document_content_validation import (
    detect_onboarding_document_format,
)
from app.services.business_onboarding.onboarding_service import (
    OnboardingServiceError,
    OnboardingServiceErrorCode,
    get_owner_application,
)
from app.services.object_storage.errors import StorageError, StorageObjectNotFoundError
from app.services.object_storage.port import StoragePort


@dataclass(frozen=True, slots=True)
class DocumentUploadResult:
    document: BusinessOnboardingDocument
    newly_completed: bool


def build_storage_object_key(application_id: uuid.UUID, document_id: uuid.UUID) -> str:
    """Opaque private key (server-generated only)."""

    return f"private/onboarding/{application_id}/{document_id}"


def _application_not_found() -> OnboardingServiceError:
    return OnboardingServiceError(
        code=OnboardingServiceErrorCode.APPLICATION_NOT_FOUND,
        message="Application not found.",
    )


def _storage_unavailable() -> OnboardingServiceError:
    return OnboardingServiceError(
        code=OnboardingServiceErrorCode.STORAGE_UNAVAILABLE,
        message="Document upload could not be completed.",
    )


def _require_draft_application(application) -> OnboardingServiceError | None:
    status = VerificationStatus(application.verification_status)
    if status != VerificationStatus.DRAFT:
        return OnboardingServiceError(
            code=OnboardingServiceErrorCode.INVALID_STATUS_TRANSITION,
            message="Documents can only be managed while the application is a draft.",
        )
    return None


def read_bounded_upload(source: BinaryIO, *, max_bytes: int) -> bytes | OnboardingServiceError:
    buffer = bytearray()
    while True:
        chunk = source.read(65536)
        if not chunk:
            break
        if len(buffer) + len(chunk) > max_bytes:
            return OnboardingServiceError(
                code=OnboardingServiceErrorCode.VALIDATION_FAILED,
                message="Document exceeds the maximum allowed size.",
            )
        buffer.extend(chunk)
    if not buffer:
        return OnboardingServiceError(
            code=OnboardingServiceErrorCode.VALIDATION_FAILED,
            message="Document file is empty.",
        )
    return bytes(buffer)


def register_owner_document(
    session: Session,
    *,
    owner_user_id: uuid.UUID,
    application_id: uuid.UUID,
    payload: RegisterOnboardingDocumentRequest,
) -> BusinessOnboardingDocument | OnboardingServiceError:
    application = get_owner_application(
        session,
        owner_user_id=owner_user_id,
        application_id=application_id,
    )
    if isinstance(application, OnboardingServiceError):
        return application
    draft_error = _require_draft_application(application)
    if draft_error is not None:
        return draft_error

    document_id = uuid.uuid4()
    document = BusinessOnboardingDocument(
        id=document_id,
        application_id=application.id,
        uploaded_by_user_id=owner_user_id,
        document_type=payload.document_type.value,
        storage_object_key=build_storage_object_key(application.id, document_id),
        declared_content_type=payload.declared_content_type,
    )
    session.add(document)
    session.flush()
    record_document_audit(
        session,
        application_id=application.id,
        event_type=OnboardingAuditEventType.DOCUMENT_REGISTERED,
        actor_role=OnboardingAuditActorRole.OWNER,
        actor_user_id=owner_user_id,
        details={
            "document_id": str(document.id),
            "to_document_lifecycle": lifecycle_detail(
                BusinessOnboardingDocumentLifecycle.AWAITING_UPLOAD,
            ),
        },
    )
    return document


def list_owner_documents(
    session: Session,
    *,
    owner_user_id: uuid.UUID,
    application_id: uuid.UUID,
) -> list[BusinessOnboardingDocument] | OnboardingServiceError:
    application = get_owner_application(
        session,
        owner_user_id=owner_user_id,
        application_id=application_id,
    )
    if isinstance(application, OnboardingServiceError):
        return application

    stmt = (
        select(BusinessOnboardingDocument)
        .where(BusinessOnboardingDocument.application_id == application.id)
        .order_by(BusinessOnboardingDocument.created_at.asc())
    )
    return list(session.scalars(stmt).all())


def upload_owner_document_bytes(
    session: Session,
    *,
    owner_user_id: uuid.UUID,
    application_id: uuid.UUID,
    document_id: uuid.UUID,
    payload: bytes,
    storage: StoragePort,
    max_bytes: int,
) -> DocumentUploadResult | OnboardingServiceError:
    if len(payload) > max_bytes:
        return OnboardingServiceError(
            code=OnboardingServiceErrorCode.VALIDATION_FAILED,
            message="Document exceeds the maximum allowed size.",
        )

    application = get_owner_application(
        session,
        owner_user_id=owner_user_id,
        application_id=application_id,
    )
    if isinstance(application, OnboardingServiceError):
        return application
    draft_error = _require_draft_application(application)
    if draft_error is not None:
        return draft_error

    document = session.scalar(
        select(BusinessOnboardingDocument)
        .where(
            BusinessOnboardingDocument.id == document_id,
            BusinessOnboardingDocument.application_id == application_id,
        )
        .with_for_update(),
    )
    if document is None:
        return _application_not_found()

    lifecycle = BusinessOnboardingDocumentLifecycle(document.lifecycle_state)
    checksum = hashlib.sha256(payload).hexdigest()
    detected = detect_onboarding_document_format(payload)
    if detected is None:
        return OnboardingServiceError(
            code=OnboardingServiceErrorCode.VALIDATION_FAILED,
            message="Document format is not allowed.",
        )

    if lifecycle == BusinessOnboardingDocumentLifecycle.UPLOADED_PENDING_VALIDATION:
        if document.checksum_sha256 != checksum or document.byte_size != len(payload):
            return OnboardingServiceError(
                code=OnboardingServiceErrorCode.INVALID_STATUS_TRANSITION,
                message="Document upload is not permitted in the current lifecycle state.",
            )
        try:
            head = storage.head(document.storage_object_key)
        except StorageObjectNotFoundError:
            content_type = detected.value
            try:
                storage.put(
                    document.storage_object_key,
                    payload,
                    content_type=content_type,
                    overwrite=True,
                )
            except StorageError:
                return _storage_unavailable()
            return DocumentUploadResult(document, newly_completed=False)
        except StorageError:
            return _storage_unavailable()
        if head.byte_size == len(payload):
            return DocumentUploadResult(document, newly_completed=False)
        return _storage_unavailable()

    if lifecycle != BusinessOnboardingDocumentLifecycle.AWAITING_UPLOAD:
        return OnboardingServiceError(
            code=OnboardingServiceErrorCode.INVALID_STATUS_TRANSITION,
            message="Document upload is not permitted in the current lifecycle state.",
        )

    content_type = detected.value
    storage_key = document.storage_object_key
    try:
        storage.put(storage_key, payload, content_type=content_type, overwrite=False)
    except StorageError:
        return _storage_unavailable()

    document.byte_size = len(payload)
    document.checksum_sha256 = checksum
    document.lifecycle_state = BusinessOnboardingDocumentLifecycle.UPLOADED_PENDING_VALIDATION.value
    session.flush()

    try:
        head = storage.head(storage_key)
    except StorageError:
        document.lifecycle_state = BusinessOnboardingDocumentLifecycle.AWAITING_UPLOAD.value
        document.byte_size = None
        document.checksum_sha256 = None
        session.flush()
        try:
            storage.delete(storage_key)
        except StorageError:
            pass
        return _storage_unavailable()

    if head.byte_size != len(payload):
        document.lifecycle_state = BusinessOnboardingDocumentLifecycle.AWAITING_UPLOAD.value
        document.byte_size = None
        document.checksum_sha256 = None
        session.flush()
        try:
            storage.delete(storage_key)
        except StorageError:
            pass
        return _storage_unavailable()

    return DocumentUploadResult(document, newly_completed=True)

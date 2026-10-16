"""Privileged reviewer access to onboarding document metadata and bytes."""

from __future__ import annotations

import re
import uuid
from dataclasses import dataclass

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.db.models.business_onboarding import BusinessOnboardingDocument
from app.domain.business_onboarding_documents import BusinessOnboardingDocumentLifecycle
from app.domain.malware_scanning import MalwareScanStatus
from app.services.business_onboarding.document_content_validation import detect_onboarding_document_format
from app.services.business_onboarding.onboarding_service import (
    OnboardingServiceError,
    OnboardingServiceErrorCode,
)
from app.services.business_onboarding.review_service import get_review_application
from app.services.object_storage.errors import StorageError, StorageObjectNotFoundError
from app.services.object_storage.port import StoragePort

_REVIEWER_DOWNLOAD_LIFECYCLES = frozenset(
    {
        BusinessOnboardingDocumentLifecycle.UPLOADED_PENDING_VALIDATION.value,
        BusinessOnboardingDocumentLifecycle.ACCEPTED_FOR_REVIEW.value,
    },
)

_FILENAME_SAFE = re.compile(r"[^A-Za-z0-9._-]+")


@dataclass(frozen=True, slots=True)
class ReviewerDocumentDownload:
    data: bytes
    content_type: str
    filename: str


def _document_not_found() -> OnboardingServiceError:
    return OnboardingServiceError(
        code=OnboardingServiceErrorCode.APPLICATION_NOT_FOUND,
        message="Document not found.",
    )


def _storage_unavailable() -> OnboardingServiceError:
    return OnboardingServiceError(
        code=OnboardingServiceErrorCode.STORAGE_UNAVAILABLE,
        message="Document could not be retrieved.",
    )


def _safe_attachment_filename(*, document_type: str, content_type: str) -> str:
    extension_by_type = {
        "application/pdf": "pdf",
        "image/jpeg": "jpg",
        "image/png": "png",
    }
    stem = document_type.strip().lower().replace("_", "-")
    stem = _FILENAME_SAFE.sub("-", stem).strip("-") or "document"
    extension = extension_by_type.get(content_type, "bin")
    return f"{stem}.{extension}"


def list_reviewer_application_documents(
    session: Session,
    *,
    application_id: uuid.UUID,
    reviewer_user_id: uuid.UUID,
) -> list[BusinessOnboardingDocument] | OnboardingServiceError:
    application = get_review_application(
        session,
        application_id=application_id,
        reviewer_user_id=reviewer_user_id,
    )
    if isinstance(application, OnboardingServiceError):
        return application

    stmt = (
        select(BusinessOnboardingDocument)
        .where(BusinessOnboardingDocument.application_id == application.id)
        .order_by(BusinessOnboardingDocument.created_at.asc())
    )
    return list(session.scalars(stmt).all())


def download_reviewer_document(
    session: Session,
    *,
    application_id: uuid.UUID,
    document_id: uuid.UUID,
    reviewer_user_id: uuid.UUID,
    storage: StoragePort,
    max_bytes: int,
) -> ReviewerDocumentDownload | OnboardingServiceError:
    application = get_review_application(
        session,
        application_id=application_id,
        reviewer_user_id=reviewer_user_id,
    )
    if isinstance(application, OnboardingServiceError):
        return application

    document = session.scalar(
        select(BusinessOnboardingDocument).where(
            BusinessOnboardingDocument.id == document_id,
            BusinessOnboardingDocument.application_id == application.id,
        ),
    )
    if document is None:
        return _document_not_found()

    if document.malware_scan_status != MalwareScanStatus.CLEAN.value:
        return _document_not_found()

    if document.lifecycle_state not in _REVIEWER_DOWNLOAD_LIFECYCLES:
        return _document_not_found()

    try:
        payload = storage.read(document.storage_object_key)
    except StorageObjectNotFoundError:
        return _storage_unavailable()
    except StorageError:
        return _storage_unavailable()

    if len(payload) > max_bytes:
        return _storage_unavailable()

    detected = detect_onboarding_document_format(payload)
    if detected is None:
        return _storage_unavailable()

    if document.byte_size is not None and len(payload) != document.byte_size:
        return _storage_unavailable()

    content_type = detected.value
    filename = _safe_attachment_filename(
        document_type=document.document_type,
        content_type=content_type,
    )
    return ReviewerDocumentDownload(
        data=payload,
        content_type=content_type,
        filename=filename,
    )

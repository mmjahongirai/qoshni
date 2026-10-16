"""Private onboarding document API contracts (Phase 07 Part 6B.2 owner routes mounted).

Owner multipart upload uses ``POST .../upload`` (not presigned ``upload-init``).
Reviewer list/download routes are mounted on the internal review router.
"""

from __future__ import annotations

import uuid
from dataclasses import dataclass
from datetime import datetime

from pydantic import BaseModel, ConfigDict, StringConstraints
from typing_extensions import Annotated

from app.api.schemas.business_onboarding import OnboardingEndpointContract
from app.domain.business_onboarding_documents import (
    BusinessOnboardingDocumentLifecycle,
    BusinessOnboardingDocumentType,
)

OWNER_APPLICATION_PREFIX = "/business/onboarding/applications"
INTERNAL_APPLICATION_PREFIX = "/internal/business/onboarding/applications"


class _Response(BaseModel):
    model_config = ConfigDict(extra="forbid")


class _Request(BaseModel):
    model_config = ConfigDict(extra="forbid", str_strip_whitespace=True)


class OwnerOnboardingDocumentView(_Response):
    """Owner-visible document metadata. Excludes private storage keys and bytes."""

    document_id: uuid.UUID
    application_id: uuid.UUID
    document_type: BusinessOnboardingDocumentType
    lifecycle_state: BusinessOnboardingDocumentLifecycle
    created_at: datetime
    updated_at: datetime


class OwnerOnboardingDocumentListResponse(_Response):
    documents: list[OwnerOnboardingDocumentView]


class ReviewerOnboardingDocumentView(_Response):
    """Reviewer-visible metadata (no storage keys, checksums, or paths)."""

    document_id: uuid.UUID
    application_id: uuid.UUID
    document_type: BusinessOnboardingDocumentType
    lifecycle_state: BusinessOnboardingDocumentLifecycle
    byte_size: int | None
    created_at: datetime
    updated_at: datetime


class ReviewerOnboardingDocumentListResponse(_Response):
    documents: list[ReviewerOnboardingDocumentView]


class RegisterOnboardingDocumentRequest(_Request):
    document_type: BusinessOnboardingDocumentType
    declared_content_type: Annotated[str, StringConstraints(max_length=128)] | None = None


class PrivilegedOnboardingDocumentContentView(_Response):
    """Future metadata-only ``/content`` contract (not a binary download)."""

    document_id: uuid.UUID
    application_id: uuid.UUID
    document_type: BusinessOnboardingDocumentType
    lifecycle_state: BusinessOnboardingDocumentLifecycle
    byte_size: int | None
    created_at: datetime
    updated_at: datetime


DOCUMENT_ENDPOINT_CONTRACTS: tuple[OnboardingEndpointContract, ...] = (
    OnboardingEndpointContract(
        "POST",
        f"{OWNER_APPLICATION_PREFIX}/{{application_id}}/documents",
        "Register a private document metadata slot for owner upload.",
        RegisterOnboardingDocumentRequest,
        OwnerOnboardingDocumentView,
        201,
        requires_access_token=True,
        owner_accessible=True,
        implemented=True,
    ),
    OnboardingEndpointContract(
        "GET",
        f"{OWNER_APPLICATION_PREFIX}/{{application_id}}/documents",
        "List owner-visible document metadata for one application.",
        None,
        OwnerOnboardingDocumentListResponse,
        200,
        requires_access_token=True,
        owner_accessible=True,
        implemented=True,
    ),
    OnboardingEndpointContract(
        "POST",
        f"{OWNER_APPLICATION_PREFIX}/{{application_id}}/documents/{{document_id}}/upload",
        "Upload private document bytes via multipart (server-validated).",
        None,
        OwnerOnboardingDocumentView,
        200,
        requires_access_token=True,
        owner_accessible=True,
        implemented=True,
    ),
    OnboardingEndpointContract(
        "POST",
        f"{OWNER_APPLICATION_PREFIX}/{{application_id}}/documents/{{document_id}}/upload-init",
        "Deferred presigned direct-to-storage upload (not implemented).",
        None,
        OwnerOnboardingDocumentView,
        200,
        requires_access_token=True,
        owner_accessible=True,
        implemented=False,
    ),
    OnboardingEndpointContract(
        "GET",
        f"{INTERNAL_APPLICATION_PREFIX}/{{application_id}}/documents",
        "Reviewer document metadata for one application.",
        None,
        ReviewerOnboardingDocumentListResponse,
        200,
        requires_access_token=True,
        owner_accessible=False,
        implemented=True,
    ),
    OnboardingEndpointContract(
        "GET",
        f"{INTERNAL_APPLICATION_PREFIX}/{{application_id}}/documents/{{document_id}}/download",
        "Reviewer download of malware-scanned private document bytes.",
        None,
        None,
        200,
        requires_access_token=True,
        owner_accessible=False,
        implemented=True,
    ),
    OnboardingEndpointContract(
        "GET",
        f"{INTERNAL_APPLICATION_PREFIX}/{{application_id}}/documents/{{document_id}}/content",
        "Privileged document content metadata (not a binary download).",
        None,
        PrivilegedOnboardingDocumentContentView,
        200,
        requires_access_token=True,
        owner_accessible=False,
        implemented=False,
    ),
)

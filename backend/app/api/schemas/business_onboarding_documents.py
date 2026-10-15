"""Private onboarding document API contracts (Phase 07 Part 3 — not mounted).

Owner and privileged document routes remain ``implemented=False`` until upload,
authorization and storage integrations exist.
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


class RegisterOnboardingDocumentRequest(_Request):
    document_type: BusinessOnboardingDocumentType
    declared_content_type: Annotated[str, StringConstraints(max_length=128)] | None = None


class PrivilegedOnboardingDocumentView(_Response):
    """Privileged metadata including storage key — never exposed to owners/public."""

    document_id: uuid.UUID
    application_id: uuid.UUID
    document_type: BusinessOnboardingDocumentType
    lifecycle_state: BusinessOnboardingDocumentLifecycle
    storage_object_key: Annotated[str, StringConstraints(min_length=1, max_length=512)]
    created_at: datetime
    updated_at: datetime


DOCUMENT_ENDPOINT_CONTRACTS: tuple[OnboardingEndpointContract, ...] = (
    OnboardingEndpointContract(
        "POST",
        f"{OWNER_APPLICATION_PREFIX}/{{application_id}}/documents",
        "Register a private document metadata slot for owner upload (future).",
        RegisterOnboardingDocumentRequest,
        OwnerOnboardingDocumentView,
        201,
        requires_access_token=True,
        owner_accessible=True,
        implemented=False,
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
        implemented=False,
    ),
    OnboardingEndpointContract(
        "POST",
        f"{OWNER_APPLICATION_PREFIX}/{{application_id}}/documents/{{document_id}}/upload-init",
        "Begin owner-authorized private upload (future object storage).",
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
        "Privileged document metadata for reviewers (future authorization).",
        None,
        OwnerOnboardingDocumentListResponse,
        200,
        requires_access_token=True,
        owner_accessible=False,
        implemented=False,
    ),
    OnboardingEndpointContract(
        "GET",
        f"{INTERNAL_APPLICATION_PREFIX}/{{application_id}}/documents/{{document_id}}/content",
        "Strictly authorized download of private document bytes (future).",
        None,
        PrivilegedOnboardingDocumentView,
        200,
        requires_access_token=True,
        owner_accessible=False,
        implemented=False,
    ),
)

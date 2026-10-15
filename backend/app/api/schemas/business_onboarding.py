"""Business onboarding API contracts (Phase 07).

Owner routes are implemented in Part 2; privileged review routes remain documented only.
"""

from __future__ import annotations

import uuid
from dataclasses import dataclass
from datetime import datetime
from enum import StrEnum

from pydantic import BaseModel, ConfigDict, StringConstraints
from typing_extensions import Annotated

from app.domain.business_onboarding import (
    BusinessServiceCategory,
    OnboardingRejectionReasonCode,
    VerificationStatus,
)


class _Request(BaseModel):
    model_config = ConfigDict(extra="forbid", str_strip_whitespace=True)


class _Response(BaseModel):
    model_config = ConfigDict(extra="forbid")


LegalBusinessName = Annotated[
    str,
    StringConstraints(min_length=1, max_length=256, strip_whitespace=True),
]
TradeDisplayName = Annotated[
    str,
    StringConstraints(min_length=1, max_length=128, strip_whitespace=True),
]
RegistrationIdentifier = Annotated[
    str,
    StringConstraints(min_length=1, max_length=64, strip_whitespace=True),
]
TaxIdentifier = Annotated[
    str,
    StringConstraints(min_length=1, max_length=64, strip_whitespace=True),
]
BusinessContactEmail = Annotated[
    str,
    StringConstraints(min_length=3, max_length=320, strip_whitespace=True),
]
RegistrationJurisdiction = Annotated[
    str,
    StringConstraints(min_length=2, max_length=2, strip_whitespace=True),
]


class OwnerOnboardingApplicationListResponse(_Response):
    applications: list["OwnerOnboardingApplicationView"]


class OwnerOnboardingApplicationView(_Response):
    """Owner-visible application. Excludes internal reviewer notes."""

    application_id: uuid.UUID
    legal_business_name: str | None = None
    trade_display_name: str | None = None
    service_category: BusinessServiceCategory | None = None
    registration_jurisdiction: RegistrationJurisdiction
    registration_identifier: str | None = None
    tax_identifier: str | None = None
    business_contact_email: BusinessContactEmail | None = None
    verification_status: VerificationStatus
    rejection_reason_code: OnboardingRejectionReasonCode | None = None
    submitted_at: datetime | None = None
    reviewed_at: datetime | None = None
    created_at: datetime
    updated_at: datetime


class OnboardingApplicationCreateRequest(_Request):
    """Optional seed fields when starting an application."""

    legal_business_name: LegalBusinessName | None = None
    trade_display_name: TradeDisplayName | None = None
    service_category: BusinessServiceCategory | None = None
    registration_jurisdiction: RegistrationJurisdiction | None = None


class OnboardingApplicationDraftUpdateRequest(_Request):
    """Editable while status is ``draft`` (server-enforced in Part 2)."""

    legal_business_name: LegalBusinessName | None = None
    trade_display_name: TradeDisplayName | None = None
    service_category: BusinessServiceCategory | None = None
    registration_jurisdiction: RegistrationJurisdiction | None = None
    registration_identifier: RegistrationIdentifier | None = None
    tax_identifier: TaxIdentifier | None = None
    business_contact_email: BusinessContactEmail | None = None
    clear_legal_business_name: bool = False
    clear_trade_display_name: bool = False
    clear_registration_identifier: bool = False
    clear_tax_identifier: bool = False
    clear_business_contact_email: bool = False


class OnboardingApplicationSubmitRequest(_Request):
    """Owner submits draft for review. Status transition is server-owned."""

    pass


class OnboardingVerificationStatusView(_Response):
    application_id: uuid.UUID
    verification_status: VerificationStatus
    rejection_reason_code: OnboardingRejectionReasonCode | None = None
    submitted_at: datetime | None = None
    reviewed_at: datetime | None = None
    updated_at: datetime


class PrivilegedReviewDecisionRequest(_Request):
    """Reviewer-only (Part 2). Owners must not call these routes."""

    internal_note: Annotated[str, StringConstraints(max_length=2000)] | None = None


class PrivilegedRejectRequest(_Request):
    rejection_reason_code: OnboardingRejectionReasonCode
    internal_note: Annotated[str, StringConstraints(max_length=2000)] | None = None


class OnboardingErrorCode(StrEnum):
    APPLICATION_NOT_FOUND = "application_not_found"
    FORBIDDEN = "forbidden"
    INVALID_STATUS_TRANSITION = "invalid_status_transition"
    VALIDATION_FAILED = "validation_failed"
    SUSPENDED = "suspended"


class OnboardingErrorDetail(_Response):
    code: OnboardingErrorCode
    message: str


class OnboardingErrorResponse(_Response):
    error: OnboardingErrorDetail


@dataclass(frozen=True)
class OnboardingEndpointContract:
    method: str
    path: str
    summary: str
    request_model: type[BaseModel] | None
    response_model: type[BaseModel] | None
    success_status: int
    requires_access_token: bool
    owner_accessible: bool
    implemented: bool = False


OWNER_PREFIX = "/business/onboarding/applications"
REVIEW_PREFIX = "/internal/business/onboarding/applications"


ONBOARDING_ENDPOINT_CONTRACTS: tuple[OnboardingEndpointContract, ...] = (
    OnboardingEndpointContract(
        "POST",
        OWNER_PREFIX,
        "Start a new onboarding application for the authenticated owner.",
        OnboardingApplicationCreateRequest,
        OwnerOnboardingApplicationView,
        201,
        requires_access_token=True,
        owner_accessible=True,
        implemented=True,
    ),
    OnboardingEndpointContract(
        "GET",
        f"{OWNER_PREFIX}/{{application_id}}",
        "Return one owner application.",
        None,
        OwnerOnboardingApplicationView,
        200,
        requires_access_token=True,
        owner_accessible=True,
        implemented=True,
    ),
    OnboardingEndpointContract(
        "GET",
        OWNER_PREFIX,
        "List onboarding applications owned by the caller.",
        None,
        OwnerOnboardingApplicationListResponse,
        200,
        requires_access_token=True,
        owner_accessible=True,
        implemented=True,
    ),
    OnboardingEndpointContract(
        "PATCH",
        f"{OWNER_PREFIX}/{{application_id}}",
        "Update permitted draft fields.",
        OnboardingApplicationDraftUpdateRequest,
        OwnerOnboardingApplicationView,
        200,
        requires_access_token=True,
        owner_accessible=True,
        implemented=True,
    ),
    OnboardingEndpointContract(
        "POST",
        f"{OWNER_PREFIX}/{{application_id}}/submit",
        "Submit a draft application for review.",
        OnboardingApplicationSubmitRequest,
        OwnerOnboardingApplicationView,
        200,
        requires_access_token=True,
        owner_accessible=True,
        implemented=True,
    ),
    OnboardingEndpointContract(
        "GET",
        f"{OWNER_PREFIX}/{{application_id}}/verification-status",
        "Read current verification status.",
        None,
        OnboardingVerificationStatusView,
        200,
        requires_access_token=True,
        owner_accessible=True,
        implemented=True,
    ),
    OnboardingEndpointContract(
        "POST",
        f"{REVIEW_PREFIX}/{{application_id}}/begin-review",
        "Move submitted application to under_review (privileged).",
        PrivilegedReviewDecisionRequest,
        OwnerOnboardingApplicationView,
        200,
        requires_access_token=True,
        owner_accessible=False,
        implemented=False,
    ),
    OnboardingEndpointContract(
        "POST",
        f"{REVIEW_PREFIX}/{{application_id}}/verify",
        "Mark application verified after review procedure (privileged).",
        PrivilegedReviewDecisionRequest,
        OwnerOnboardingApplicationView,
        200,
        requires_access_token=True,
        owner_accessible=False,
        implemented=False,
    ),
    OnboardingEndpointContract(
        "POST",
        f"{REVIEW_PREFIX}/{{application_id}}/reject",
        "Reject application with a controlled client-safe reason (privileged).",
        PrivilegedRejectRequest,
        OwnerOnboardingApplicationView,
        200,
        requires_access_token=True,
        owner_accessible=False,
        implemented=False,
    ),
    OnboardingEndpointContract(
        "POST",
        f"{REVIEW_PREFIX}/{{application_id}}/suspend",
        "Suspend a verified business (privileged).",
        PrivilegedReviewDecisionRequest,
        OwnerOnboardingApplicationView,
        200,
        requires_access_token=True,
        owner_accessible=False,
        implemented=False,
    ),
    OnboardingEndpointContract(
        "POST",
        f"{REVIEW_PREFIX}/{{application_id}}/reinstate",
        "Reinstate a suspended business after authorized review (privileged).",
        PrivilegedReviewDecisionRequest,
        OwnerOnboardingApplicationView,
        200,
        requires_access_token=True,
        owner_accessible=False,
        implemented=False,
    ),
)

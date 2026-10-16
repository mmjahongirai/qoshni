"""Onboarding HTTP error responses."""

from __future__ import annotations

from fastapi.responses import JSONResponse

from app.api.schemas.business_onboarding import (
    OnboardingErrorCode,
    OnboardingErrorDetail,
    OnboardingErrorResponse,
)
from app.services.business_onboarding.onboarding_service import (
    OnboardingServiceError,
    OnboardingServiceErrorCode,
)

_ONBOARDING_HTTP_STATUS: dict[OnboardingServiceErrorCode, int] = {
    OnboardingServiceErrorCode.APPLICATION_NOT_FOUND: 404,
    OnboardingServiceErrorCode.FORBIDDEN: 403,
    OnboardingServiceErrorCode.INVALID_STATUS_TRANSITION: 409,
    OnboardingServiceErrorCode.VALIDATION_FAILED: 422,
    OnboardingServiceErrorCode.STORAGE_UNAVAILABLE: 503,
    OnboardingServiceErrorCode.MALWARE_SCAN_UNAVAILABLE: 503,
    OnboardingServiceErrorCode.DOCUMENT_REJECTED: 422,
    OnboardingServiceErrorCode.SUSPENDED: 403,
}

_SERVICE_TO_API: dict[OnboardingServiceErrorCode, OnboardingErrorCode] = {
    OnboardingServiceErrorCode.APPLICATION_NOT_FOUND: OnboardingErrorCode.APPLICATION_NOT_FOUND,
    OnboardingServiceErrorCode.FORBIDDEN: OnboardingErrorCode.FORBIDDEN,
    OnboardingServiceErrorCode.INVALID_STATUS_TRANSITION: OnboardingErrorCode.INVALID_STATUS_TRANSITION,
    OnboardingServiceErrorCode.VALIDATION_FAILED: OnboardingErrorCode.VALIDATION_FAILED,
    OnboardingServiceErrorCode.STORAGE_UNAVAILABLE: OnboardingErrorCode.STORAGE_UNAVAILABLE,
    OnboardingServiceErrorCode.MALWARE_SCAN_UNAVAILABLE: OnboardingErrorCode.MALWARE_SCAN_UNAVAILABLE,
    OnboardingServiceErrorCode.DOCUMENT_REJECTED: OnboardingErrorCode.DOCUMENT_REJECTED,
    OnboardingServiceErrorCode.SUSPENDED: OnboardingErrorCode.SUSPENDED,
}


def onboarding_error_response(error: OnboardingServiceError) -> JSONResponse:
    api_code = _SERVICE_TO_API[error.code]
    body = OnboardingErrorResponse(
        error=OnboardingErrorDetail(code=api_code, message=error.message),
    )
    return JSONResponse(
        status_code=_ONBOARDING_HTTP_STATUS[error.code],
        content=body.model_dump(mode="json"),
    )

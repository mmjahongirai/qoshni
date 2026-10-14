"""Shared authentication HTTP error responses."""

from __future__ import annotations

from fastapi.responses import JSONResponse

from app.api.schemas.auth import (
    AUTH_ERROR_HTTP_STATUS,
    AuthErrorCode,
    AuthErrorDetail,
    AuthErrorResponse,
)
from app.services.auth.errors import AuthServiceError, AuthServiceErrorCode

_SERVICE_TO_API_ERROR: dict[AuthServiceErrorCode, AuthErrorCode] = {
    AuthServiceErrorCode.CHALLENGE_INVALID: AuthErrorCode.CHALLENGE_INVALID,
    AuthServiceErrorCode.CHALLENGE_EXPIRED: AuthErrorCode.CHALLENGE_EXPIRED,
    AuthServiceErrorCode.CHALLENGE_CONSUMED: AuthErrorCode.CHALLENGE_CONSUMED,
    AuthServiceErrorCode.CHALLENGE_LOCKED: AuthErrorCode.CHALLENGE_LOCKED,
    AuthServiceErrorCode.CODE_INCORRECT: AuthErrorCode.CODE_INCORRECT,
    AuthServiceErrorCode.RATE_LIMITED: AuthErrorCode.RATE_LIMITED,
    AuthServiceErrorCode.FEATURE_NOT_AVAILABLE: AuthErrorCode.FEATURE_NOT_AVAILABLE,
    AuthServiceErrorCode.SERVICE_UNAVAILABLE: AuthErrorCode.SERVICE_UNAVAILABLE,
    AuthServiceErrorCode.ACCOUNT_UNAVAILABLE: AuthErrorCode.ACCOUNT_UNAVAILABLE,
    AuthServiceErrorCode.SESSION_INVALID: AuthErrorCode.SESSION_INVALID,
    AuthServiceErrorCode.SESSION_NOT_FOUND: AuthErrorCode.SESSION_NOT_FOUND,
    AuthServiceErrorCode.AUTHENTICATION_REQUIRED: AuthErrorCode.AUTHENTICATION_REQUIRED,
}


def auth_error_response(error: AuthServiceError) -> JSONResponse:
    api_code = _SERVICE_TO_API_ERROR[error.code]
    body = AuthErrorResponse(
        error=AuthErrorDetail(
            code=api_code,
            message=error.message,
            retry_after_seconds=error.retry_after_seconds,
            attempts_remaining=error.attempts_remaining,
        ),
    )
    return JSONResponse(
        status_code=AUTH_ERROR_HTTP_STATUS[api_code],
        content=body.model_dump(mode="json"),
    )

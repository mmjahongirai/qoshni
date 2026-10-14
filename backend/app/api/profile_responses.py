"""Profile HTTP error responses aligned with authentication error envelopes."""

from __future__ import annotations

from fastapi.responses import JSONResponse

from app.api.schemas.profile import ProfileErrorCode, ProfileErrorDetail, ProfileErrorResponse
from app.services.profile.profile_service import ProfileServiceError, ProfileServiceErrorCode

_PROFILE_HTTP_STATUS: dict[ProfileServiceErrorCode, int] = {
    ProfileServiceErrorCode.PROFILE_NOT_FOUND: 404,
    ProfileServiceErrorCode.PREFERENCES_NOT_FOUND: 404,
}

_SERVICE_TO_API: dict[ProfileServiceErrorCode, ProfileErrorCode] = {
    ProfileServiceErrorCode.PROFILE_NOT_FOUND: ProfileErrorCode.PROFILE_NOT_FOUND,
    ProfileServiceErrorCode.PREFERENCES_NOT_FOUND: ProfileErrorCode.PREFERENCES_NOT_FOUND,
}


def profile_error_response(error: ProfileServiceError) -> JSONResponse:
    api_code = _SERVICE_TO_API[error.code]
    body = ProfileErrorResponse(
        error=ProfileErrorDetail(code=api_code, message=error.message),
    )
    return JSONResponse(
        status_code=_PROFILE_HTTP_STATUS[error.code],
        content=body.model_dump(mode="json"),
    )

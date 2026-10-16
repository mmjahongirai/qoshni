"""Authorization HTTP error responses."""

from __future__ import annotations

from fastapi.responses import JSONResponse

from app.api.schemas.authorization import (
    AUTHORIZATION_ERROR_HTTP_STATUS,
    AuthorizationErrorCode,
    AuthorizationErrorDetail,
    AuthorizationErrorResponse,
)
from app.services.authorization.errors import AuthorizationError, AuthorizationErrorCode as ServiceCode

_SERVICE_TO_API: dict[ServiceCode, AuthorizationErrorCode] = {
    ServiceCode.AUTHORIZATION_DENIED: AuthorizationErrorCode.AUTHORIZATION_DENIED,
}


def authorization_error_response(error: AuthorizationError) -> JSONResponse:
    api_code = _SERVICE_TO_API[error.code]
    body = AuthorizationErrorResponse(
        error=AuthorizationErrorDetail(code=api_code, message=error.message),
    )
    return JSONResponse(
        status_code=AUTHORIZATION_ERROR_HTTP_STATUS[api_code],
        content=body.model_dump(mode="json"),
    )

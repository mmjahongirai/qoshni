"""Authorization API error contracts (403 after authentication)."""

from enum import StrEnum

from pydantic import BaseModel, ConfigDict


class AuthorizationErrorCode(StrEnum):
    AUTHORIZATION_DENIED = "authorization_denied"


AUTHORIZATION_ERROR_HTTP_STATUS: dict[AuthorizationErrorCode, int] = {
    AuthorizationErrorCode.AUTHORIZATION_DENIED: 403,
}


class _Response(BaseModel):
    model_config = ConfigDict(extra="forbid")


class AuthorizationErrorDetail(_Response):
    code: AuthorizationErrorCode
    message: str


class AuthorizationErrorResponse(_Response):
    error: AuthorizationErrorDetail

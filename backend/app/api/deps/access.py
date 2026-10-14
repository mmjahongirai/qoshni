"""Access-token authentication dependencies."""

from __future__ import annotations

from fastapi import Depends, Header
from sqlalchemy.orm import Session

from app.core.config import Settings, get_settings
from app.core.database import get_db
from app.services.auth.errors import AuthServiceError, AuthServiceErrorCode
from app.services.auth.principal import AuthenticatedPrincipal
from app.services.auth.session_service import resolve_access_token


class AuthenticationRequired(Exception):
    """Raised when bearer authentication fails; carries a safe service error."""

    def __init__(self, error: AuthServiceError) -> None:
        self.error = error
        super().__init__(error.message)


def _parse_bearer_token(authorization: str | None) -> str | AuthServiceError:
    if authorization is None or not authorization.strip():
        return AuthServiceError(
            code=AuthServiceErrorCode.AUTHENTICATION_REQUIRED,
            message="Authentication required.",
        )
    scheme, _, remainder = authorization.partition(" ")
    if scheme.lower() != "bearer" or not remainder.strip():
        return AuthServiceError(
            code=AuthServiceErrorCode.AUTHENTICATION_REQUIRED,
            message="Authentication required.",
        )
    return remainder.strip()


def get_current_principal(
    db: Session = Depends(get_db),
    settings: Settings = Depends(get_settings),
    authorization: str | None = Header(default=None, alias="Authorization"),
) -> AuthenticatedPrincipal:
    parsed = _parse_bearer_token(authorization)
    if isinstance(parsed, AuthServiceError):
        raise AuthenticationRequired(parsed)

    result = resolve_access_token(db, settings, parsed)
    if isinstance(result, AuthServiceError):
        raise AuthenticationRequired(result)
    return result

"""Authorization outcomes (authenticated but not permitted)."""

from __future__ import annotations

from dataclasses import dataclass
from enum import StrEnum


class AuthorizationErrorCode(StrEnum):
    AUTHORIZATION_DENIED = "authorization_denied"


@dataclass(frozen=True, slots=True)
class AuthorizationError:
    code: AuthorizationErrorCode
    message: str


class AuthorizationDenied(Exception):
    """Raised when the caller is signed in but lacks a required platform role."""

    def __init__(self, error: AuthorizationError | None = None) -> None:
        self.error = error or AuthorizationError(
            code=AuthorizationErrorCode.AUTHORIZATION_DENIED,
            message="You do not have permission to perform this action.",
        )
        super().__init__(self.error.message)

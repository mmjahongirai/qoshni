"""Authentication API contracts for ``/api/v1/auth``.

These shapes are reviewed ahead of implementation; no auth routes are mounted
yet (see ``AUTH_ENDPOINT_CONTRACTS``). Requests forbid unknown fields so
clients cannot submit identity or authorization claims such as ``user_id``.
Stored OTP digests and refresh-token digests have no field in any response.
"""

import re
import uuid
from dataclasses import dataclass
from datetime import UTC, datetime
from enum import StrEnum
from typing import Annotated, Literal

from pydantic import AfterValidator, BaseModel, ConfigDict, Field, StringConstraints

from app.domain.identity import DevicePlatform, OtpPurpose, SessionState

_E164_PATTERN = re.compile(r"^\+[1-9]\d{7,14}$")
_PHONE_SEPARATORS = re.compile(r"[\s\-().]")


def normalize_phone_e164(raw: str) -> str:
    """Normalize a user-entered phone number to E.164 or raise ``ValueError``.

    Accepts common separators and a ``00`` international prefix. National
    formats without a country code are rejected rather than guessed.
    """

    candidate = _PHONE_SEPARATORS.sub("", raw)
    if candidate.startswith("00"):
        candidate = "+" + candidate[2:]
    if not _E164_PATTERN.fullmatch(candidate):
        raise ValueError("Phone number must be in international format, e.g. +998901234567.")
    return candidate


PhoneE164 = Annotated[
    str,
    StringConstraints(strip_whitespace=True, min_length=8, max_length=32),
    AfterValidator(normalize_phone_e164),
]


class _Request(BaseModel):
    model_config = ConfigDict(extra="forbid", str_strip_whitespace=True)


class _Response(BaseModel):
    model_config = ConfigDict(extra="forbid")


class DeviceDescriptor(_Request):
    """Client-reported, untrusted device hints used only for session display."""

    installation_id: Annotated[
        str,
        StringConstraints(min_length=8, max_length=64, pattern=r"^[A-Za-z0-9_-]+$"),
    ] | None = None
    label: Annotated[str, StringConstraints(min_length=1, max_length=64)] | None = None
    platform: DevicePlatform | None = None


class OtpChallengeCreateRequest(_Request):
    phone: PhoneE164
    purpose: OtpPurpose = OtpPurpose.SIGN_IN


class OtpChallengeCreatedResponse(_Response):
    """Identical for registered and unregistered phones to limit enumeration."""

    challenge_id: uuid.UUID
    expires_at: datetime
    code_length: int = Field(ge=4, le=8)


class OtpChallengeVerifyRequest(_Request):
    challenge_id: uuid.UUID
    code: Annotated[str, StringConstraints(pattern=r"^\d{4,8}$")] = Field(repr=False)
    device: DeviceDescriptor | None = None


class SessionView(_Response):
    session_id: uuid.UUID
    state: SessionState
    created_at: datetime
    expires_at: datetime
    last_seen_at: datetime | None = None
    revoked_at: datetime | None = None
    device_label: str | None = None
    device_platform: DevicePlatform | None = None
    is_current: bool = False

    @staticmethod
    def derive_state(
        *,
        expires_at: datetime,
        revoked_at: datetime | None,
        now: datetime,
    ) -> SessionState:
        def _utc(value: datetime) -> datetime:
            if value.tzinfo is None:
                return value.replace(tzinfo=UTC)
            return value.astimezone(UTC)

        if revoked_at is not None:
            return SessionState.REVOKED
        if _utc(expires_at) <= _utc(now):
            return SessionState.EXPIRED
        return SessionState.ACTIVE


class SessionTokensResponse(_Response):
    """Issued on successful verification or refresh.

    ``refresh_token`` is returned once to its owner and only its digest is
    stored. ``repr=False`` keeps raw tokens out of accidental log output.
    """

    token_type: Literal["bearer"] = "bearer"
    access_token: str = Field(repr=False)
    access_token_expires_at: datetime
    refresh_token: str = Field(repr=False)
    refresh_token_expires_at: datetime
    user_id: uuid.UUID
    session: SessionView


class SessionRefreshRequest(_Request):
    refresh_token: Annotated[str, StringConstraints(min_length=32, max_length=512)] = Field(
        repr=False,
    )


class SessionListResponse(_Response):
    sessions: list[SessionView]


class AuthErrorCode(StrEnum):
    CHALLENGE_INVALID = "challenge_invalid"
    CHALLENGE_EXPIRED = "challenge_expired"
    CHALLENGE_CONSUMED = "challenge_consumed"
    CHALLENGE_LOCKED = "challenge_locked"
    CODE_INCORRECT = "code_incorrect"
    RATE_LIMITED = "rate_limited"
    SESSION_INVALID = "session_invalid"
    SESSION_NOT_FOUND = "session_not_found"
    AUTHENTICATION_REQUIRED = "authentication_required"
    FEATURE_NOT_AVAILABLE = "feature_not_available"
    SERVICE_UNAVAILABLE = "service_unavailable"
    ACCOUNT_UNAVAILABLE = "account_unavailable"


AUTH_ERROR_HTTP_STATUS: dict[AuthErrorCode, int] = {
    AuthErrorCode.CHALLENGE_INVALID: 400,
    AuthErrorCode.CHALLENGE_EXPIRED: 410,
    AuthErrorCode.CHALLENGE_CONSUMED: 409,
    AuthErrorCode.CHALLENGE_LOCKED: 429,
    AuthErrorCode.CODE_INCORRECT: 400,
    AuthErrorCode.RATE_LIMITED: 429,
    AuthErrorCode.SESSION_INVALID: 401,
    AuthErrorCode.SESSION_NOT_FOUND: 404,
    AuthErrorCode.AUTHENTICATION_REQUIRED: 401,
    AuthErrorCode.FEATURE_NOT_AVAILABLE: 501,
    AuthErrorCode.SERVICE_UNAVAILABLE: 503,
    AuthErrorCode.ACCOUNT_UNAVAILABLE: 403,
}


class AuthErrorDetail(_Response):
    code: AuthErrorCode
    message: str
    retry_after_seconds: int | None = Field(default=None, ge=0)
    attempts_remaining: int | None = Field(default=None, ge=0)


class AuthErrorResponse(_Response):
    error: AuthErrorDetail


@dataclass(frozen=True)
class AuthEndpointContract:
    method: str
    path: str
    summary: str
    request_model: type[BaseModel] | None
    response_model: type[BaseModel] | None
    success_status: int
    requires_access_token: bool
    implemented: bool = False


AUTH_ENDPOINT_CONTRACTS: tuple[AuthEndpointContract, ...] = (
    AuthEndpointContract(
        "POST",
        "/auth/otp/challenges",
        "Request a phone OTP challenge.",
        OtpChallengeCreateRequest,
        OtpChallengeCreatedResponse,
        202,
        requires_access_token=False,
        implemented=True,
    ),
    AuthEndpointContract(
        "POST",
        "/auth/otp/verify",
        "Verify an OTP challenge and open a session.",
        OtpChallengeVerifyRequest,
        SessionTokensResponse,
        200,
        requires_access_token=False,
        implemented=True,
    ),
    AuthEndpointContract(
        "POST",
        "/auth/sessions/refresh",
        "Rotate the refresh token and issue a new access token.",
        SessionRefreshRequest,
        SessionTokensResponse,
        200,
        requires_access_token=False,
        implemented=True,
    ),
    AuthEndpointContract(
        "GET",
        "/auth/sessions",
        "List the caller's sessions.",
        None,
        SessionListResponse,
        200,
        requires_access_token=True,
        implemented=True,
    ),
    AuthEndpointContract(
        "DELETE",
        "/auth/sessions/current",
        "Log out by revoking the caller's current session.",
        None,
        None,
        204,
        requires_access_token=True,
        implemented=True,
    ),
    AuthEndpointContract(
        "DELETE",
        "/auth/sessions/{session_id}",
        "Revoke one of the caller's own sessions.",
        None,
        None,
        204,
        requires_access_token=True,
        implemented=True,
    ),
)

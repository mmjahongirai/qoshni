"""Authentication API contract shapes (schemas only; no live endpoints)."""

import uuid
from datetime import UTC, datetime, timedelta

import pytest
from fastapi.testclient import TestClient
from pydantic import BaseModel, ValidationError

from app.api.schemas.auth import (
    AUTH_ENDPOINT_CONTRACTS,
    AUTH_ERROR_HTTP_STATUS,
    AuthErrorCode,
    AuthErrorDetail,
    AuthErrorResponse,
    OtpChallengeCreatedResponse,
    OtpChallengeCreateRequest,
    OtpChallengeVerifyRequest,
    SessionListResponse,
    SessionRefreshRequest,
    SessionTokensResponse,
    SessionView,
)
from app.domain.identity import OtpPurpose, SessionState
from app.main import create_app

FORBIDDEN_RESPONSE_FIELDS = {
    "code",
    "code_digest",
    "otp",
    "refresh_token_digest",
    "refresh_token_hash",
    "phone_e164",
}
RESPONSE_MODELS: list[type[BaseModel]] = [
    OtpChallengeCreatedResponse,
    SessionTokensResponse,
    SessionListResponse,
    SessionView,
    AuthErrorResponse,
]


def _all_field_names(model: type[BaseModel], seen: set[type[BaseModel]] | None = None) -> set[str]:
    seen = seen or set()
    if model in seen:
        return set()
    seen.add(model)
    names = set(model.model_fields)
    for field in model.model_fields.values():
        for candidate in (field.annotation, *getattr(field.annotation, "__args__", ())):
            if isinstance(candidate, type) and issubclass(candidate, BaseModel):
                names |= _all_field_names(candidate, seen)
    return names


@pytest.mark.parametrize(
    ("raw", "expected"),
    [
        ("+998901234567", "+998901234567"),
        ("  +998 90 123-45-67 ", "+998901234567"),
        ("+998 (90) 123.45.67", "+998901234567"),
        ("00998901234567", "+998901234567"),
    ],
)
def test_phone_is_normalized_to_e164(raw: str, expected: str) -> None:
    request = OtpChallengeCreateRequest(phone=raw)

    assert request.phone == expected
    assert request.purpose == OtpPurpose.SIGN_IN


@pytest.mark.parametrize(
    "raw",
    ["", "901234567", "+0998901234567", "+99890abc4567", "+1234", "+" + "9" * 20],
)
def test_invalid_phone_is_rejected_at_contract_boundary(raw: str) -> None:
    with pytest.raises(ValidationError):
        OtpChallengeCreateRequest(phone=raw)


def test_unknown_otp_purpose_is_rejected() -> None:
    with pytest.raises(ValidationError):
        OtpChallengeCreateRequest(phone="+998901234567", purpose="password_reset")


@pytest.mark.parametrize(
    "untrusted_field",
    [{"user_id": str(uuid.uuid4())}, {"is_verified": True}, {"role": "admin"}],
)
def test_requests_reject_client_supplied_identity_claims(untrusted_field: dict) -> None:
    with pytest.raises(ValidationError):
        OtpChallengeCreateRequest(phone="+998901234567", **untrusted_field)
    with pytest.raises(ValidationError):
        OtpChallengeVerifyRequest(challenge_id=uuid.uuid4(), code="123456", **untrusted_field)


@pytest.mark.parametrize("code", ["12345a", "123", "123456789", "", "12 34 56"])
def test_verify_rejects_malformed_codes(code: str) -> None:
    with pytest.raises(ValidationError):
        OtpChallengeVerifyRequest(challenge_id=uuid.uuid4(), code=code)


def test_verify_rejects_non_uuid_challenge_id() -> None:
    with pytest.raises(ValidationError):
        OtpChallengeVerifyRequest(challenge_id="+998901234567", code="123456")


def test_verify_request_repr_hides_code() -> None:
    request = OtpChallengeVerifyRequest(challenge_id=uuid.uuid4(), code="482913")

    assert "482913" not in repr(request)


def test_device_descriptor_rejects_oversized_or_unknown_platform() -> None:
    with pytest.raises(ValidationError):
        OtpChallengeVerifyRequest(
            challenge_id=uuid.uuid4(),
            code="123456",
            device={"platform": "symbian"},
        )
    with pytest.raises(ValidationError):
        OtpChallengeVerifyRequest(
            challenge_id=uuid.uuid4(),
            code="123456",
            device={"installation_id": "x" * 65},
        )


@pytest.mark.parametrize("model", RESPONSE_MODELS)
def test_response_contracts_never_expose_secret_digests(model: type[BaseModel]) -> None:
    exposed = _all_field_names(model) & FORBIDDEN_RESPONSE_FIELDS
    if model is AuthErrorResponse:
        assert AuthErrorDetail.model_fields["code"].annotation is AuthErrorCode
        exposed -= {"code"}

    assert not exposed


def test_token_response_repr_hides_raw_tokens() -> None:
    now = datetime.now(UTC)
    response = SessionTokensResponse(
        access_token="access-token-value",
        access_token_expires_at=now + timedelta(minutes=15),
        refresh_token="refresh-token-value",
        refresh_token_expires_at=now + timedelta(days=30),
        user_id=uuid.uuid4(),
        session=SessionView(
            session_id=uuid.uuid4(),
            state=SessionState.ACTIVE,
            created_at=now,
            expires_at=now + timedelta(days=30),
        ),
    )

    text = repr(response)
    assert "access-token-value" not in text
    assert "refresh-token-value" not in text


def test_refresh_request_rejects_short_tokens_and_hides_value() -> None:
    with pytest.raises(ValidationError):
        SessionRefreshRequest(refresh_token="short")

    request = SessionRefreshRequest(refresh_token="r" * 48)
    assert "r" * 48 not in repr(request)


@pytest.mark.parametrize(
    ("expires_in", "revoked", "expected"),
    [
        (timedelta(days=1), False, SessionState.ACTIVE),
        (timedelta(seconds=-1), False, SessionState.EXPIRED),
        (timedelta(days=1), True, SessionState.REVOKED),
        (timedelta(seconds=-1), True, SessionState.REVOKED),
    ],
)
def test_session_state_reflects_revocation_and_expiry(
    expires_in: timedelta,
    revoked: bool,
    expected: SessionState,
) -> None:
    now = datetime.now(UTC)

    state = SessionView.derive_state(
        expires_at=now + expires_in,
        revoked_at=now if revoked else None,
        now=now,
    )

    assert state == expected


def test_every_error_code_has_stable_http_status() -> None:
    assert set(AUTH_ERROR_HTTP_STATUS) == set(AuthErrorCode)
    assert AUTH_ERROR_HTTP_STATUS[AuthErrorCode.CHALLENGE_EXPIRED] == 410
    assert AUTH_ERROR_HTTP_STATUS[AuthErrorCode.CHALLENGE_CONSUMED] == 409
    assert AUTH_ERROR_HTTP_STATUS[AuthErrorCode.RATE_LIMITED] == 429

    body = AuthErrorResponse.model_validate(
        {"error": {"code": "rate_limited", "message": "Try again later.", "retry_after_seconds": 30}},
    )
    assert body.error.code == AuthErrorCode.RATE_LIMITED


def test_endpoint_contracts_mark_all_auth_routes_implemented() -> None:
    paths = {(contract.method, contract.path) for contract in AUTH_ENDPOINT_CONTRACTS}

    assert ("POST", "/auth/otp/challenges") in paths
    assert ("POST", "/auth/otp/verify") in paths
    assert ("POST", "/auth/sessions/refresh") in paths
    assert ("GET", "/auth/sessions") in paths
    assert ("DELETE", "/auth/sessions/current") in paths
    assert ("DELETE", "/auth/sessions/{session_id}") in paths

    assert all(contract.implemented for contract in AUTH_ENDPOINT_CONTRACTS)

"""Unit tests for authentication secret helpers."""

import pytest

from app.core.auth.secrets import (
    AuthSecretConfigurationError,
    compute_secret_digest,
    generate_numeric_otp,
    generate_opaque_token,
    require_digest_key,
    verify_secret_digest,
)
from app.core.config import Settings, get_settings


@pytest.fixture(autouse=True)
def clear_settings_cache() -> None:
    get_settings.cache_clear()
    yield
    get_settings.cache_clear()


def test_require_digest_key_fails_closed_when_missing() -> None:
    with pytest.raises(AuthSecretConfigurationError):
        require_digest_key(Settings())


def test_require_digest_key_rejects_short_keys(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setenv("QOSHNI_AUTH_SECRET_DIGEST_KEY", "too-short")
    with pytest.raises(AuthSecretConfigurationError):
        require_digest_key(Settings())


def test_hmac_digest_verification_uses_constant_time_compare(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    monkeypatch.setenv("QOSHNI_AUTH_SECRET_DIGEST_KEY", "a" * 32)
    key = require_digest_key(Settings())
    digest = compute_secret_digest(key=key, secret="482913", domain="otp")

    assert verify_secret_digest(key=key, secret="482913", domain="otp", expected_digest=digest)
    assert not verify_secret_digest(key=key, secret="000000", domain="otp", expected_digest=digest)


def test_generate_numeric_otp_respects_length() -> None:
    code = generate_numeric_otp(6)
    assert len(code) == 6
    assert code.isdigit()


def test_generate_opaque_token_is_non_empty() -> None:
    assert len(generate_opaque_token()) >= 32


def test_digest_helpers_do_not_embed_secrets_in_repr(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setenv("QOSHNI_AUTH_SECRET_DIGEST_KEY", "super-secret-key-material-32bytes!!")
    settings = Settings()
    key = require_digest_key(settings)
    digest = compute_secret_digest(key=key, secret="123456", domain="otp")

    assert "123456" not in digest
    assert "super-secret-key-material" not in digest
    assert "super-secret-key-material" not in repr(settings)

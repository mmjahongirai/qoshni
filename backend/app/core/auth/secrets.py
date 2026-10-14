"""HMAC digests and cryptographically secure secret generation."""

from __future__ import annotations

import hashlib
import hmac
import secrets
import string
from typing import Final

from app.core.config import Settings

_MIN_DIGEST_KEY_BYTES: Final = 32
_OTP_DIGITS: Final = string.digits


class AuthSecretConfigurationError(RuntimeError):
    """Raised when authentication secrets are missing or unusable."""


def require_digest_key(settings: Settings) -> bytes:
    """Return the configured digest key or fail closed."""

    secret = settings.auth_secret_digest_key
    if secret is None:
        raise AuthSecretConfigurationError("Authentication digest key is not configured.")
    raw = secret.get_secret_value().encode("utf-8")
    if len(raw) < _MIN_DIGEST_KEY_BYTES:
        raise AuthSecretConfigurationError("Authentication digest key is too short.")
    return raw


def compute_secret_digest(*, key: bytes, secret: str, domain: str) -> str:
    """Keyed digest for ``secret`` scoped to ``domain`` (e.g. ``otp``, ``access_token``)."""

    message = f"{domain}:{secret}".encode("utf-8")
    return hmac.new(key, message, hashlib.sha256).hexdigest()


def verify_secret_digest(*, key: bytes, secret: str, domain: str, expected_digest: str) -> bool:
    computed = compute_secret_digest(key=key, secret=secret, domain=domain)
    return hmac.compare_digest(computed, expected_digest)


def generate_numeric_otp(length: int) -> str:
    if length < 4 or length > 8:
        raise ValueError("OTP length must be between 4 and 8 digits.")
    return "".join(secrets.choice(_OTP_DIGITS) for _ in range(length))


def generate_opaque_token() -> str:
    return secrets.token_urlsafe(32)

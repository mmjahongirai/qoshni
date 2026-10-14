"""Identity and authentication vocabulary.

Values are persisted as strings and guarded by database CHECK constraints, so
renaming or removing a member requires a migration.
"""

from enum import StrEnum


class AccountStatus(StrEnum):
    """Lifecycle of a phone identity. Authorization roles live elsewhere."""

    PENDING = "pending"
    ACTIVE = "active"
    SUSPENDED = "suspended"
    DISABLED = "disabled"


class OtpPurpose(StrEnum):
    SIGN_IN = "sign_in"
    ACCOUNT_RECOVERY = "account_recovery"


class DevicePlatform(StrEnum):
    ANDROID = "android"
    IOS = "ios"
    WEB = "web"


class SessionRevocationReason(StrEnum):
    LOGOUT = "logout"
    REVOKED_BY_USER = "revoked_by_user"
    REFRESH_TOKEN_REUSE = "refresh_token_reuse"
    ACCOUNT_STATUS_CHANGE = "account_status_change"
    SECURITY_ACTION = "security_action"


class SessionState(StrEnum):
    """Derived state; not stored."""

    ACTIVE = "active"
    EXPIRED = "expired"
    REVOKED = "revoked"


class AuthAuditEventType(StrEnum):
    OTP_CHALLENGE_REQUESTED = "otp_challenge_requested"
    OTP_VERIFICATION_FAILED = "otp_verification_failed"
    OTP_CHALLENGE_LOCKED = "otp_challenge_locked"
    OTP_CHALLENGE_VERIFIED = "otp_challenge_verified"
    IDENTITY_CREATED = "identity_created"
    SESSION_CREATED = "session_created"
    SESSION_REFRESHED = "session_refreshed"
    SESSION_REVOKED = "session_revoked"
    REFRESH_TOKEN_REUSE_DETECTED = "refresh_token_reuse_detected"

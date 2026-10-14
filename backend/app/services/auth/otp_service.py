"""OTP challenge creation and verification."""

from __future__ import annotations

import uuid
from datetime import UTC, datetime, timedelta

from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.core.auth.secrets import (
    AuthSecretConfigurationError,
    compute_secret_digest,
    generate_numeric_otp,
    generate_opaque_token,
    require_digest_key,
    verify_secret_digest,
)
from app.core.config import Settings
from app.db.models.identity import AuthSession, OtpChallenge, User
from app.domain.identity import AccountStatus, AuthAuditEventType, OtpPurpose
from app.services.auth.audit import record_auth_event
from app.services.auth.errors import AuthServiceError, AuthServiceErrorCode, OtpChallengeCreated, SessionIssued
from app.services.auth.otp_provider import OtpDeliveryProvider
from app.services.profile.provisioning import ensure_user_profile_resources

_DIGEST_DOMAIN_OTP = "otp"
_DIGEST_DOMAIN_ACCESS = "access_token"
_DIGEST_DOMAIN_REFRESH = "refresh_token"


def _utc_now() -> datetime:
    return datetime.now(UTC)


def _as_utc(value: datetime) -> datetime:
    if value.tzinfo is None:
        return value.replace(tzinfo=UTC)
    return value.astimezone(UTC)


def _window_start(now: datetime, window_seconds: int) -> datetime:
    return now - timedelta(seconds=window_seconds)


async def request_otp_challenge(
    session: Session,
    settings: Settings,
    provider: OtpDeliveryProvider,
    *,
    phone_e164: str,
    purpose: OtpPurpose,
    correlation_id: str | None = None,
    now: datetime | None = None,
) -> OtpChallengeCreated | AuthServiceError:
    now = now or _utc_now()

    if purpose != OtpPurpose.SIGN_IN:
        return AuthServiceError(
            code=AuthServiceErrorCode.FEATURE_NOT_AVAILABLE,
            message="This sign-in option is not available yet.",
        )

    try:
        digest_key = require_digest_key(settings)
    except AuthSecretConfigurationError:
        return AuthServiceError(
            code=AuthServiceErrorCode.SERVICE_UNAVAILABLE,
            message="Sign-in is temporarily unavailable.",
        )

    recent_count = session.scalar(
        select(func.count())
        .select_from(OtpChallenge)
        .where(
            OtpChallenge.phone_e164 == phone_e164,
            OtpChallenge.purpose == purpose.value,
            OtpChallenge.created_at >= _as_utc(_window_start(now, settings.auth_otp_request_window_seconds)),
        ),
    )
    if recent_count is not None and recent_count >= settings.auth_otp_request_max_per_window:
        return AuthServiceError(
            code=AuthServiceErrorCode.RATE_LIMITED,
            message="Too many verification requests. Try again later.",
            retry_after_seconds=settings.auth_otp_request_window_seconds,
        )

    code = generate_numeric_otp(settings.auth_otp_code_length)
    code_digest = compute_secret_digest(
        key=digest_key,
        secret=code,
        domain=_DIGEST_DOMAIN_OTP,
    )
    expires_at = now + timedelta(seconds=settings.auth_otp_ttl_seconds)

    challenge = OtpChallenge(
        phone_e164=phone_e164,
        purpose=purpose.value,
        code_digest=code_digest,
        expires_at=expires_at,
        max_attempts=settings.auth_otp_max_attempts,
    )
    session.add(challenge)
    session.flush()

    delivery = await provider.send_otp(
        phone_e164=phone_e164,
        purpose=purpose.value,
        code_length=settings.auth_otp_code_length,
        code=code,
    )

    if not delivery.accepted:
        challenge.consumed_at = now
        record_auth_event(
            session,
            event_type=AuthAuditEventType.OTP_CHALLENGE_REQUESTED,
            target_type="otp_challenge",
            target_id=challenge.id,
            correlation_id=correlation_id,
            details={"delivery": "failed"},
        )
        session.commit()
        return AuthServiceError(
            code=AuthServiceErrorCode.SERVICE_UNAVAILABLE,
            message="Sign-in is temporarily unavailable.",
        )

    record_auth_event(
        session,
        event_type=AuthAuditEventType.OTP_CHALLENGE_REQUESTED,
        target_type="otp_challenge",
        target_id=challenge.id,
        correlation_id=correlation_id,
        details={"delivery": "accepted"},
    )
    session.commit()

    return OtpChallengeCreated(
        challenge_id=challenge.id,
        expires_at=challenge.expires_at,
        code_length=settings.auth_otp_code_length,
    )


def verify_otp_challenge(
    session: Session,
    settings: Settings,
    *,
    challenge_id: uuid.UUID,
    code: str,
    device_label: str | None = None,
    device_platform: str | None = None,
    installation_id: str | None = None,
    correlation_id: str | None = None,
    now: datetime | None = None,
) -> SessionIssued | AuthServiceError:
    now = now or _utc_now()

    try:
        digest_key = require_digest_key(settings)
    except AuthSecretConfigurationError:
        return AuthServiceError(
            code=AuthServiceErrorCode.SERVICE_UNAVAILABLE,
            message="Sign-in is temporarily unavailable.",
        )

    challenge = session.get(OtpChallenge, challenge_id, with_for_update=True)
    if challenge is None or challenge.purpose != OtpPurpose.SIGN_IN.value:
        return AuthServiceError(
            code=AuthServiceErrorCode.CHALLENGE_INVALID,
            message="Verification request is invalid.",
        )

    if challenge.consumed_at is not None:
        return AuthServiceError(
            code=AuthServiceErrorCode.CHALLENGE_CONSUMED,
            message="This verification code was already used.",
        )

    if _as_utc(challenge.expires_at) <= now:
        return AuthServiceError(
            code=AuthServiceErrorCode.CHALLENGE_EXPIRED,
            message="This verification code has expired.",
        )

    if challenge.attempt_count >= challenge.max_attempts:
        return AuthServiceError(
            code=AuthServiceErrorCode.CHALLENGE_LOCKED,
            message="Too many incorrect attempts. Request a new code.",
        )

    if not verify_secret_digest(
        key=digest_key,
        secret=code,
        domain=_DIGEST_DOMAIN_OTP,
        expected_digest=challenge.code_digest,
    ):
        challenge.attempt_count += 1
        remaining = max(0, challenge.max_attempts - challenge.attempt_count)
        record_auth_event(
            session,
            event_type=AuthAuditEventType.OTP_VERIFICATION_FAILED,
            target_type="otp_challenge",
            target_id=challenge.id,
            correlation_id=correlation_id,
            details={"attempts_remaining": remaining},
        )
        if challenge.attempt_count >= challenge.max_attempts:
            record_auth_event(
                session,
                event_type=AuthAuditEventType.OTP_CHALLENGE_LOCKED,
                target_type="otp_challenge",
                target_id=challenge.id,
                correlation_id=correlation_id,
            )
            session.commit()
            return AuthServiceError(
                code=AuthServiceErrorCode.CHALLENGE_LOCKED,
                message="Too many incorrect attempts. Request a new code.",
                attempts_remaining=0,
            )
        session.commit()
        return AuthServiceError(
            code=AuthServiceErrorCode.CODE_INCORRECT,
            message="Incorrect verification code.",
            attempts_remaining=remaining,
        )

    challenge.consumed_at = now
    session.flush()

    user = session.scalar(
        select(User).where(User.phone_e164 == challenge.phone_e164).with_for_update(),
    )
    created_identity = False
    if user is None:
        user = User(
            phone_e164=challenge.phone_e164,
            status=AccountStatus.ACTIVE.value,
            phone_verified_at=now,
        )
        session.add(user)
        session.flush()
        created_identity = True
    elif user.status in (AccountStatus.SUSPENDED.value, AccountStatus.DISABLED.value):
        session.commit()
        return AuthServiceError(
            code=AuthServiceErrorCode.ACCOUNT_UNAVAILABLE,
            message="Sign-in is not available for this account.",
        )
    else:
        if user.status == AccountStatus.PENDING.value:
            user.status = AccountStatus.ACTIVE.value
        user.phone_verified_at = now

    access_token = generate_opaque_token()
    refresh_token = generate_opaque_token()
    access_expires = now + timedelta(seconds=settings.auth_access_token_ttl_seconds)
    refresh_expires = now + timedelta(seconds=settings.auth_refresh_token_ttl_seconds)

    auth_session = AuthSession(
        user_id=user.id,
        access_token_digest=compute_secret_digest(
            key=digest_key,
            secret=access_token,
            domain=_DIGEST_DOMAIN_ACCESS,
        ),
        access_token_expires_at=access_expires,
        refresh_token_digest=compute_secret_digest(
            key=digest_key,
            secret=refresh_token,
            domain=_DIGEST_DOMAIN_REFRESH,
        ),
        expires_at=refresh_expires,
        installation_id=installation_id,
        device_label=device_label,
        device_platform=device_platform,
        last_seen_at=now,
    )
    session.add(auth_session)

    record_auth_event(
        session,
        event_type=AuthAuditEventType.OTP_CHALLENGE_VERIFIED,
        user_id=user.id,
        target_type="otp_challenge",
        target_id=challenge.id,
        correlation_id=correlation_id,
    )
    if created_identity:
        record_auth_event(
            session,
            event_type=AuthAuditEventType.IDENTITY_CREATED,
            user_id=user.id,
            correlation_id=correlation_id,
        )
    record_auth_event(
        session,
        event_type=AuthAuditEventType.SESSION_CREATED,
        user_id=user.id,
        target_type="auth_session",
        target_id=auth_session.id,
        correlation_id=correlation_id,
    )

    try:
        ensure_user_profile_resources(session, user.id)
    except Exception:
        session.rollback()
        return AuthServiceError(
            code=AuthServiceErrorCode.SERVICE_UNAVAILABLE,
            message="Sign-in is temporarily unavailable.",
        )

    session.commit()

    return SessionIssued(
        access_token=access_token,
        access_token_expires_at=access_expires,
        refresh_token=refresh_token,
        refresh_token_expires_at=refresh_expires,
        user_id=user.id,
        session_id=auth_session.id,
        session_created_at=auth_session.created_at,
        session_expires_at=auth_session.expires_at,
        device_label=device_label,
        device_platform=device_platform,
    )

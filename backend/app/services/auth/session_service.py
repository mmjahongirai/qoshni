"""Access-token validation, refresh rotation, listing, and revocation."""

from __future__ import annotations

import uuid
from datetime import datetime, timedelta

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.auth.secrets import (
    AuthSecretConfigurationError,
    compute_secret_digest,
    generate_opaque_token,
    require_digest_key,
)
from app.core.config import Settings
from app.db.models.identity import AuthSession, User
from app.domain.identity import (
    AccountStatus,
    AuthAuditEventType,
    SessionRevocationReason,
    SessionState,
)
from app.services.auth.audit import record_auth_event
from app.services.auth.errors import AuthServiceError, AuthServiceErrorCode, SessionIssued
from app.services.auth.principal import AuthenticatedPrincipal
from app.services.auth.time_utils import as_utc, utc_now

_DIGEST_DOMAIN_ACCESS = "access_token"
_DIGEST_DOMAIN_REFRESH = "refresh_token"
_ALLOWED_ACCOUNT_STATUSES = frozenset({AccountStatus.ACTIVE.value})


def resolve_access_token(
    session: Session,
    settings: Settings,
    access_token: str,
) -> AuthenticatedPrincipal | AuthServiceError:
    try:
        digest_key = require_digest_key(settings)
    except AuthSecretConfigurationError:
        return AuthServiceError(
            code=AuthServiceErrorCode.SERVICE_UNAVAILABLE,
            message="Authentication is temporarily unavailable.",
        )

    digest = compute_secret_digest(
        key=digest_key,
        secret=access_token,
        domain=_DIGEST_DOMAIN_ACCESS,
    )
    auth_session = session.scalar(
        select(AuthSession).where(AuthSession.access_token_digest == digest),
    )
    if auth_session is None:
        return AuthServiceError(
            code=AuthServiceErrorCode.AUTHENTICATION_REQUIRED,
            message="Authentication required.",
        )

    return _validate_session_for_use(session, auth_session)


def refresh_session_tokens(
    session: Session,
    settings: Settings,
    *,
    refresh_token: str,
    correlation_id: str | None = None,
) -> SessionIssued | AuthServiceError:
    try:
        digest_key = require_digest_key(settings)
    except AuthSecretConfigurationError:
        return AuthServiceError(
            code=AuthServiceErrorCode.SERVICE_UNAVAILABLE,
            message="Authentication is temporarily unavailable.",
        )

    digest = compute_secret_digest(
        key=digest_key,
        secret=refresh_token,
        domain=_DIGEST_DOMAIN_REFRESH,
    )
    auth_session = session.scalar(
        select(AuthSession)
        .where(AuthSession.refresh_token_digest == digest)
        .with_for_update(),
    )
    if auth_session is None:
        return AuthServiceError(
            code=AuthServiceErrorCode.SESSION_INVALID,
            message="Session is invalid.",
        )

    validation = _validate_session_for_refresh(session, auth_session)
    if isinstance(validation, AuthServiceError):
        return validation

    now = utc_now()
    new_access = generate_opaque_token()
    new_refresh = generate_opaque_token()
    access_expires = now + timedelta(seconds=settings.auth_access_token_ttl_seconds)
    refresh_expires = now + timedelta(seconds=settings.auth_refresh_token_ttl_seconds)

    auth_session.access_token_digest = compute_secret_digest(
        key=digest_key,
        secret=new_access,
        domain=_DIGEST_DOMAIN_ACCESS,
    )
    auth_session.access_token_expires_at = access_expires
    auth_session.refresh_token_digest = compute_secret_digest(
        key=digest_key,
        secret=new_refresh,
        domain=_DIGEST_DOMAIN_REFRESH,
    )
    auth_session.expires_at = refresh_expires
    auth_session.last_seen_at = now

    record_auth_event(
        session,
        event_type=AuthAuditEventType.SESSION_REFRESHED,
        user_id=auth_session.user_id,
        target_type="auth_session",
        target_id=auth_session.id,
        correlation_id=correlation_id,
    )
    session.commit()

    return SessionIssued(
        access_token=new_access,
        access_token_expires_at=access_expires,
        refresh_token=new_refresh,
        refresh_token_expires_at=refresh_expires,
        user_id=auth_session.user_id,
        session_id=auth_session.id,
        session_created_at=auth_session.created_at,
        session_expires_at=auth_session.expires_at,
        device_label=auth_session.device_label,
        device_platform=auth_session.device_platform,
    )


def list_user_sessions(
    session: Session,
    *,
    user_id: uuid.UUID,
    current_session_id: uuid.UUID,
) -> list[AuthSession]:
    _ = current_session_id
    rows = session.scalars(
        select(AuthSession)
        .where(AuthSession.user_id == user_id)
        .order_by(AuthSession.created_at.desc()),
    ).all()
    return list(rows)


def revoke_session(
    session: Session,
    *,
    user_id: uuid.UUID,
    session_id: uuid.UUID,
    reason: SessionRevocationReason,
    correlation_id: str | None = None,
) -> None | AuthServiceError:
    auth_session = session.scalar(
        select(AuthSession)
        .where(
            AuthSession.id == session_id,
            AuthSession.user_id == user_id,
        )
        .with_for_update(),
    )
    if auth_session is None:
        return AuthServiceError(
            code=AuthServiceErrorCode.SESSION_NOT_FOUND,
            message="Session not found.",
        )

    if auth_session.revoked_at is None:
        now = utc_now()
        auth_session.revoked_at = now
        auth_session.revoked_reason = reason.value
        record_auth_event(
            session,
            event_type=AuthAuditEventType.SESSION_REVOKED,
            user_id=user_id,
            target_type="auth_session",
            target_id=auth_session.id,
            correlation_id=correlation_id,
            details={"reason": reason.value},
        )
    session.commit()
    return None


def _validate_session_for_use(
    session: Session,
    auth_session: AuthSession,
) -> AuthenticatedPrincipal | AuthServiceError:
    now = utc_now()
    if auth_session.revoked_at is not None:
        return AuthServiceError(
            code=AuthServiceErrorCode.SESSION_INVALID,
            message="Session is invalid.",
        )
    if as_utc(auth_session.access_token_expires_at) <= now:
        return AuthServiceError(
            code=AuthServiceErrorCode.SESSION_INVALID,
            message="Session is invalid.",
        )
    if as_utc(auth_session.expires_at) <= now:
        return AuthServiceError(
            code=AuthServiceErrorCode.SESSION_INVALID,
            message="Session is invalid.",
        )

    return _validate_active_user(session, auth_session)


def _validate_session_for_refresh(
    session: Session,
    auth_session: AuthSession,
) -> AuthenticatedPrincipal | AuthServiceError:
    now = utc_now()
    if auth_session.revoked_at is not None:
        return AuthServiceError(
            code=AuthServiceErrorCode.SESSION_INVALID,
            message="Session is invalid.",
        )
    if as_utc(auth_session.expires_at) <= now:
        return AuthServiceError(
            code=AuthServiceErrorCode.SESSION_INVALID,
            message="Session is invalid.",
        )

    return _validate_active_user(session, auth_session)


def _validate_active_user(
    session: Session,
    auth_session: AuthSession,
) -> AuthenticatedPrincipal | AuthServiceError:
    user = session.get(User, auth_session.user_id)
    if user is None or user.status not in _ALLOWED_ACCOUNT_STATUSES:
        return AuthServiceError(
            code=AuthServiceErrorCode.ACCOUNT_UNAVAILABLE,
            message="Sign-in is not available for this account.",
        )

    return AuthenticatedPrincipal(
        user_id=user.id,
        session_id=auth_session.id,
    )


def session_state(auth_session: AuthSession, *, now: datetime | None = None) -> SessionState:
    now = now or utc_now()
    if auth_session.revoked_at is not None:
        return SessionState.REVOKED
    if as_utc(auth_session.expires_at) <= now:
        return SessionState.EXPIRED
    if as_utc(auth_session.access_token_expires_at) <= now:
        return SessionState.EXPIRED
    return SessionState.ACTIVE

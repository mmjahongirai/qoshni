"""Authentication endpoints."""

from __future__ import annotations

import uuid
from datetime import UTC, datetime

from fastapi import APIRouter, Depends, Header, Response
from fastapi.responses import JSONResponse
from sqlalchemy.orm import Session

from app.api.auth_responses import auth_error_response
from app.api.deps.access import AuthenticationRequired, get_current_principal
from app.api.deps.auth import get_otp_delivery_provider
from app.api.schemas.auth import (
    AuthErrorResponse,
    OtpChallengeCreateRequest,
    OtpChallengeCreatedResponse,
    OtpChallengeVerifyRequest,
    SessionListResponse,
    SessionRefreshRequest,
    SessionTokensResponse,
    SessionView,
)
from app.core.config import Settings, get_settings
from app.core.database import get_db
from app.domain.identity import DevicePlatform, SessionRevocationReason
from app.services.auth.errors import AuthServiceError, OtpChallengeCreated, SessionIssued
from app.services.auth.otp_provider import OtpDeliveryProvider
from app.services.auth.otp_service import request_otp_challenge, verify_otp_challenge
from app.services.auth.principal import AuthenticatedPrincipal
from app.services.auth.session_service import (
    list_user_sessions,
    refresh_session_tokens,
    revoke_session,
    session_state,
)
from app.services.auth.time_utils import utc_now

router = APIRouter(prefix="/auth", tags=["auth"])


def _session_tokens_response(issued: SessionIssued, *, now: datetime) -> SessionTokensResponse:
    return SessionTokensResponse(
        access_token=issued.access_token,
        access_token_expires_at=issued.access_token_expires_at,
        refresh_token=issued.refresh_token,
        refresh_token_expires_at=issued.refresh_token_expires_at,
        user_id=issued.user_id,
        session=SessionView(
            session_id=issued.session_id,
            state=SessionView.derive_state(
                expires_at=issued.session_expires_at,
                revoked_at=None,
                now=now,
            ),
            created_at=issued.session_created_at,
            expires_at=issued.session_expires_at,
            last_seen_at=issued.session_created_at,
            device_label=issued.device_label,
            device_platform=(
                DevicePlatform(issued.device_platform)
                if issued.device_platform is not None
                else None
            ),
            is_current=True,
        ),
    )


def _session_view(
    auth_session,
    *,
    current_session_id: uuid.UUID,
    now: datetime,
) -> SessionView:
    return SessionView(
        session_id=auth_session.id,
        state=session_state(auth_session, now=now),
        created_at=auth_session.created_at,
        expires_at=auth_session.expires_at,
        last_seen_at=auth_session.last_seen_at,
        revoked_at=auth_session.revoked_at,
        device_label=auth_session.device_label,
        device_platform=(
            DevicePlatform(auth_session.device_platform)
            if auth_session.device_platform is not None
            else None
        ),
        is_current=auth_session.id == current_session_id,
    )


@router.post(
    "/otp/challenges",
    response_model=OtpChallengeCreatedResponse,
    status_code=202,
    responses={
        429: {"model": AuthErrorResponse},
        501: {"model": AuthErrorResponse},
        503: {"model": AuthErrorResponse},
    },
)
async def create_otp_challenge(
    payload: OtpChallengeCreateRequest,
    db: Session = Depends(get_db),
    settings: Settings = Depends(get_settings),
    provider: OtpDeliveryProvider = Depends(get_otp_delivery_provider),
    x_correlation_id: str | None = Header(default=None, alias="X-Correlation-ID"),
) -> OtpChallengeCreatedResponse | JSONResponse:
    result = await request_otp_challenge(
        db,
        settings,
        provider,
        phone_e164=payload.phone,
        purpose=payload.purpose,
        correlation_id=x_correlation_id,
    )
    if isinstance(result, AuthServiceError):
        return auth_error_response(result)
    return OtpChallengeCreatedResponse(
        challenge_id=result.challenge_id,
        expires_at=result.expires_at,
        code_length=result.code_length,
    )


@router.post(
    "/otp/verify",
    response_model=SessionTokensResponse,
    responses={400: {"model": AuthErrorResponse}, 403: {"model": AuthErrorResponse}},
)
def verify_otp(
    payload: OtpChallengeVerifyRequest,
    db: Session = Depends(get_db),
    settings: Settings = Depends(get_settings),
    x_correlation_id: str | None = Header(default=None, alias="X-Correlation-ID"),
) -> SessionTokensResponse | JSONResponse:
    device = payload.device
    result = verify_otp_challenge(
        db,
        settings,
        challenge_id=payload.challenge_id,
        code=payload.code,
        device_label=device.label if device else None,
        device_platform=device.platform.value if device and device.platform else None,
        installation_id=device.installation_id if device else None,
        correlation_id=x_correlation_id,
    )
    if isinstance(result, AuthServiceError):
        return auth_error_response(result)
    return _session_tokens_response(result, now=datetime.now(UTC))


@router.post(
    "/sessions/refresh",
    response_model=SessionTokensResponse,
    responses={
        401: {"model": AuthErrorResponse},
        403: {"model": AuthErrorResponse},
        503: {"model": AuthErrorResponse},
    },
)
def refresh_session(
    payload: SessionRefreshRequest,
    db: Session = Depends(get_db),
    settings: Settings = Depends(get_settings),
    x_correlation_id: str | None = Header(default=None, alias="X-Correlation-ID"),
) -> SessionTokensResponse | JSONResponse:
    result = refresh_session_tokens(
        db,
        settings,
        refresh_token=payload.refresh_token,
        correlation_id=x_correlation_id,
    )
    if isinstance(result, AuthServiceError):
        return auth_error_response(result)
    return _session_tokens_response(result, now=utc_now())


@router.get(
    "/sessions",
    response_model=SessionListResponse,
    responses={401: {"model": AuthErrorResponse}},
)
def list_sessions(
    db: Session = Depends(get_db),
    principal: AuthenticatedPrincipal = Depends(get_current_principal),
) -> SessionListResponse:
    now = utc_now()
    sessions = list_user_sessions(
        db,
        user_id=principal.user_id,
        current_session_id=principal.session_id,
    )
    return SessionListResponse(
        sessions=[
            _session_view(row, current_session_id=principal.session_id, now=now)
            for row in sessions
        ],
    )


@router.delete(
    "/sessions/current",
    status_code=204,
    responses={401: {"model": AuthErrorResponse}},
)
def logout_current_session(
    db: Session = Depends(get_db),
    principal: AuthenticatedPrincipal = Depends(get_current_principal),
    x_correlation_id: str | None = Header(default=None, alias="X-Correlation-ID"),
) -> Response:
    revoke_session(
        db,
        user_id=principal.user_id,
        session_id=principal.session_id,
        reason=SessionRevocationReason.LOGOUT,
        correlation_id=x_correlation_id,
    )
    return Response(status_code=204)


@router.delete(
    "/sessions/{session_id}",
    responses={
        204: {"description": "Session revoked."},
        401: {"model": AuthErrorResponse},
        404: {"model": AuthErrorResponse},
    },
)
def revoke_owned_session(
    session_id: uuid.UUID,
    db: Session = Depends(get_db),
    principal: AuthenticatedPrincipal = Depends(get_current_principal),
    x_correlation_id: str | None = Header(default=None, alias="X-Correlation-ID"),
):
    result = revoke_session(
        db,
        user_id=principal.user_id,
        session_id=session_id,
        reason=SessionRevocationReason.REVOKED_BY_USER,
        correlation_id=x_correlation_id,
    )
    if isinstance(result, AuthServiceError):
        return auth_error_response(result)
    return Response(status_code=204)

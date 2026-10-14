"""Access token, refresh rotation, listing, and revocation tests."""

from __future__ import annotations

import uuid
from collections.abc import Generator
from datetime import UTC, datetime, timedelta
from pathlib import Path

import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine, select
from sqlalchemy.engine import Engine
from sqlalchemy.orm import Session, sessionmaker

from app.api.deps.auth import get_otp_delivery_provider
from app.core.auth.secrets import compute_secret_digest, require_digest_key
from app.core.config import Settings, get_settings
from app.core.database import get_db
from app.db.base import Base
from app.db.models.identity import AuthAuditEvent, AuthSession, User
from app.domain.identity import AccountStatus
from app.main import create_app
from tests.support.fake_otp_provider import FakeOtpProvider

_DIGEST_KEY = "s" * 32


@pytest.fixture
def auth_engine(tmp_path: Path, monkeypatch: pytest.MonkeyPatch) -> Generator[Engine, None, None]:
    url = f"sqlite:///{(tmp_path / 'sessions.db').as_posix()}"
    monkeypatch.delenv("DATABASE_URL", raising=False)
    monkeypatch.setenv("QOSHNI_DATABASE_URL", url)
    monkeypatch.setenv("QOSHNI_AUTH_SECRET_DIGEST_KEY", _DIGEST_KEY)
    get_settings.cache_clear()

    engine = create_engine(url, connect_args={"check_same_thread": False})
    Base.metadata.create_all(engine)
    yield engine
    engine.dispose()
    get_settings.cache_clear()


@pytest.fixture
def auth_client(auth_engine: Engine) -> Generator[tuple[TestClient, FakeOtpProvider], None, None]:
    provider = FakeOtpProvider()
    session_factory = sessionmaker(bind=auth_engine, autoflush=False, autocommit=False)

    def override_db() -> Generator[Session, None, None]:
        session = session_factory()
        try:
            yield session
        finally:
            session.close()

    application = create_app()
    application.dependency_overrides[get_db] = override_db
    application.dependency_overrides[get_otp_delivery_provider] = lambda: provider

    with TestClient(application) as client:
        yield client, provider

    application.dependency_overrides.clear()


def _sign_in(client: TestClient, provider: FakeOtpProvider, phone: str = "+998901234567") -> dict:
    challenge = client.post("/api/v1/auth/otp/challenges", json={"phone": phone})
    assert challenge.status_code == 202, challenge.text
    verify = client.post(
        "/api/v1/auth/otp/verify",
        json={
            "challenge_id": challenge.json()["challenge_id"],
            "code": provider.last_code,
        },
    )
    assert verify.status_code == 200, verify.text
    return verify.json()


def test_missing_bearer_returns_authentication_required(auth_client) -> None:
    client, _ = auth_client
    response = client.get("/api/v1/auth/sessions")
    assert response.status_code == 401
    assert response.json()["error"]["code"] == "authentication_required"
    assert "Bearer" not in response.text


def test_unknown_access_token_is_rejected(auth_client) -> None:
    client, _ = auth_client
    response = client.get(
        "/api/v1/auth/sessions",
        headers={"Authorization": "Bearer unknown-token-value"},
    )
    assert response.status_code == 401
    assert response.json()["error"]["code"] == "authentication_required"


def test_revoked_session_access_token_is_rejected(auth_client, auth_engine) -> None:
    client, provider = auth_client
    tokens = _sign_in(client, provider)
    client.delete(
        "/api/v1/auth/sessions/current",
        headers={"Authorization": f"Bearer {tokens['access_token']}"},
    )

    response = client.get(
        "/api/v1/auth/sessions",
        headers={"Authorization": f"Bearer {tokens['access_token']}"},
    )
    assert response.status_code == 401
    assert response.json()["error"]["code"] == "session_invalid"


def test_suspended_user_access_token_is_rejected(auth_client, auth_engine) -> None:
    client, provider = auth_client
    tokens = _sign_in(client, provider, phone="+998909999999")

    with Session(auth_engine) as session:
        user = session.scalar(select(User).where(User.phone_e164 == "+998909999999"))
        assert user is not None
        user.status = AccountStatus.SUSPENDED.value
        session.commit()

    response = client.get(
        "/api/v1/auth/sessions",
        headers={"Authorization": f"Bearer {tokens['access_token']}"},
    )
    assert response.status_code == 403
    assert response.json()["error"]["code"] == "account_unavailable"


def test_refresh_rotates_credentials_and_invalidates_old_tokens(auth_client) -> None:
    client, provider = auth_client
    tokens = _sign_in(client, provider)
    old_access = tokens["access_token"]
    old_refresh = tokens["refresh_token"]

    refreshed = client.post(
        "/api/v1/auth/sessions/refresh",
        json={"refresh_token": old_refresh},
    )
    assert refreshed.status_code == 200, refreshed.text
    body = refreshed.json()
    assert body["access_token"] != old_access
    assert body["refresh_token"] != old_refresh
    assert "digest" not in refreshed.text

    assert (
        client.get(
            "/api/v1/auth/sessions",
            headers={"Authorization": f"Bearer {old_access}"},
        ).status_code
        == 401
    )
    assert (
        client.post(
            "/api/v1/auth/sessions/refresh",
            json={"refresh_token": old_refresh},
        ).status_code
        == 401
    )


def test_same_refresh_token_cannot_be_reused_after_rotation(auth_client) -> None:
    client, provider = auth_client
    tokens = _sign_in(client, provider)
    refresh_token = tokens["refresh_token"]

    first = client.post("/api/v1/auth/sessions/refresh", json={"refresh_token": refresh_token})
    assert first.status_code == 200

    second = client.post("/api/v1/auth/sessions/refresh", json={"refresh_token": refresh_token})
    assert second.status_code == 401
    assert second.json()["error"]["code"] == "session_invalid"


def test_session_list_returns_only_owned_sessions_without_secrets(auth_client) -> None:
    client, provider = auth_client
    tokens = _sign_in(client, provider, phone="+998901111111")
    _sign_in(client, provider, phone="+998902222222")

    listed = client.get(
        "/api/v1/auth/sessions",
        headers={"Authorization": f"Bearer {tokens['access_token']}"},
    )
    assert listed.status_code == 200
    body = listed.json()
    assert len(body["sessions"]) >= 1
    assert all("digest" not in str(session).lower() for session in body["sessions"])
    assert body["sessions"][0]["is_current"] is True


def test_cross_user_session_revocation_returns_not_found(auth_client) -> None:
    client, provider = auth_client
    user_a = _sign_in(client, provider, phone="+998903333333")
    user_b = _sign_in(client, provider, phone="+998904444444")
    other_session_id = user_b["session"]["session_id"]

    response = client.delete(
        f"/api/v1/auth/sessions/{other_session_id}",
        headers={"Authorization": f"Bearer {user_a['access_token']}"},
    )
    assert response.status_code == 404
    assert response.json()["error"]["code"] == "session_not_found"


def test_repeated_logout_is_idempotent(auth_client) -> None:
    client, provider = auth_client
    tokens = _sign_in(client, provider)
    headers = {"Authorization": f"Bearer {tokens['access_token']}"}

    assert client.delete("/api/v1/auth/sessions/current", headers=headers).status_code == 204
    assert client.delete("/api/v1/auth/sessions/current", headers=headers).status_code == 401


def test_stored_session_uses_digests_not_raw_tokens(auth_client, auth_engine) -> None:
    client, provider = auth_client
    tokens = _sign_in(client, provider)
    settings = Settings()
    key = require_digest_key(settings)

    with Session(auth_engine) as session:
        row = session.get(AuthSession, uuid.UUID(tokens["session"]["session_id"]))
        assert row is not None
        assert row.access_token_digest == compute_secret_digest(
            key=key,
            secret=tokens["access_token"],
            domain="access_token",
        )
        assert tokens["access_token"] not in row.access_token_digest


def test_audit_events_exclude_tokens_and_phones(auth_client, auth_engine) -> None:
    client, provider = auth_client
    tokens = _sign_in(client, provider)
    client.post(
        "/api/v1/auth/sessions/refresh",
        json={"refresh_token": tokens["refresh_token"]},
    )

    with Session(auth_engine) as session:
        events = session.scalars(select(AuthAuditEvent)).all()
        assert events
        for event in events:
            payload = str(event.details or {})
            assert "access_token" not in payload
            assert "+998" not in payload

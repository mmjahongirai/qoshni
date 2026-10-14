"""Integration tests for OTP challenge and verification endpoints."""

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
from app.core.config import get_settings
from app.core.database import get_db
from app.db.base import Base
from app.db.models.identity import AuthSession, OtpChallenge, User
from app.domain.identity import AccountStatus, OtpPurpose
from app.main import create_app
from tests.support.fake_otp_provider import FakeOtpProvider

_DIGEST_KEY = "t" * 32


@pytest.fixture
def auth_engine(tmp_path: Path, monkeypatch: pytest.MonkeyPatch) -> Generator[Engine, None, None]:
    url = f"sqlite:///{(tmp_path / 'auth_api.db').as_posix()}"
    monkeypatch.delenv("DATABASE_URL", raising=False)
    monkeypatch.setenv("QOSHNI_DATABASE_URL", url)
    monkeypatch.setenv("QOSHNI_AUTH_SECRET_DIGEST_KEY", _DIGEST_KEY)
    monkeypatch.setenv("QOSHNI_AUTH_OTP_REQUEST_MAX_PER_WINDOW", "3")
    monkeypatch.setenv("QOSHNI_AUTH_OTP_REQUEST_WINDOW_SECONDS", "900")
    get_settings.cache_clear()

    engine = create_engine(url, connect_args={"check_same_thread": False})
    Base.metadata.create_all(engine)
    yield engine
    engine.dispose()
    get_settings.cache_clear()


@pytest.fixture
def fake_provider() -> FakeOtpProvider:
    return FakeOtpProvider()


@pytest.fixture
def auth_client(auth_engine: Engine, fake_provider: FakeOtpProvider) -> Generator[TestClient, None, None]:
    session_factory = sessionmaker(bind=auth_engine, autoflush=False, autocommit=False)

    def override_db() -> Generator[Session, None, None]:
        session = session_factory()
        try:
            yield session
        finally:
            session.close()

    application = create_app()
    application.dependency_overrides[get_db] = override_db
    application.dependency_overrides[get_otp_delivery_provider] = lambda: fake_provider

    with TestClient(application) as client:
        yield client

    application.dependency_overrides.clear()


def _create_challenge(client: TestClient, phone: str = "+998901234567") -> dict:
    response = client.post("/api/v1/auth/otp/challenges", json={"phone": phone})
    assert response.status_code == 202, response.text
    return response.json()


def test_challenge_and_verify_sign_in_flow(auth_client: TestClient, fake_provider: FakeOtpProvider) -> None:
    payload = _create_challenge(auth_client)
    assert payload["code_length"] == 6
    assert "code_digest" not in payload
    assert fake_provider.last_code is not None

    verify = auth_client.post(
        "/api/v1/auth/otp/verify",
        json={"challenge_id": payload["challenge_id"], "code": fake_provider.last_code},
    )
    assert verify.status_code == 200, verify.text
    body = verify.json()
    assert body["token_type"] == "bearer"
    assert len(body["access_token"]) > 20
    assert len(body["refresh_token"]) > 20
    assert "code_digest" not in verify.text
    assert "refresh_token_digest" not in verify.text
    assert body["session"]["state"] == "active"


def test_recovery_purpose_returns_not_available(auth_client: TestClient) -> None:
    response = auth_client.post(
        "/api/v1/auth/otp/challenges",
        json={"phone": "+998901234567", "purpose": "account_recovery"},
    )
    assert response.status_code == 501
    assert response.json()["error"]["code"] == "feature_not_available"


def test_provider_delivery_failure_marks_challenge_unusable(
    auth_client: TestClient,
    fake_provider: FakeOtpProvider,
    auth_engine: Engine,
) -> None:
    fake_provider.accept_delivery = False
    response = auth_client.post("/api/v1/auth/otp/challenges", json={"phone": "+998901234567"})
    assert response.status_code == 503

    with Session(auth_engine) as session:
        challenge = session.scalars(select(OtpChallenge)).one()
        assert challenge.consumed_at is not None

    verify = auth_client.post(
        "/api/v1/auth/otp/verify",
        json={"challenge_id": str(challenge.id), "code": "123456"},
    )
    assert verify.status_code == 409
    assert verify.json()["error"]["code"] == "challenge_consumed"


def test_rate_limit_blocks_excessive_challenge_requests(
    auth_client: TestClient,
    fake_provider: FakeOtpProvider,
) -> None:
    for _ in range(3):
        assert _create_challenge(auth_client, phone="+998901111111")["challenge_id"]

    blocked = auth_client.post("/api/v1/auth/otp/challenges", json={"phone": "+998901111111"})
    assert blocked.status_code == 429
    assert blocked.json()["error"]["code"] == "rate_limited"
    assert fake_provider.delivery_calls == 3


def test_wrong_code_increments_attempts_and_locks(auth_client: TestClient, fake_provider: FakeOtpProvider) -> None:
    payload = _create_challenge(auth_client, phone="+998902222222")

    for _ in range(4):
        bad = auth_client.post(
            "/api/v1/auth/otp/verify",
            json={"challenge_id": payload["challenge_id"], "code": "000000"},
        )
        assert bad.status_code == 400
        assert bad.json()["error"]["code"] == "code_incorrect"

    locked = auth_client.post(
        "/api/v1/auth/otp/verify",
        json={"challenge_id": payload["challenge_id"], "code": "000000"},
    )
    assert locked.status_code == 429
    assert locked.json()["error"]["code"] == "challenge_locked"


def test_suspended_account_cannot_open_session(
    auth_client: TestClient,
    fake_provider: FakeOtpProvider,
    auth_engine: Engine,
) -> None:
    with Session(auth_engine) as session:
        session.add(
            User(
                phone_e164="+998903333333",
                status=AccountStatus.SUSPENDED.value,
            ),
        )
        session.commit()

    payload = _create_challenge(auth_client, phone="+998903333333")
    verify = auth_client.post(
        "/api/v1/auth/otp/verify",
        json={"challenge_id": payload["challenge_id"], "code": fake_provider.last_code},
    )
    assert verify.status_code == 403
    assert verify.json()["error"]["code"] == "account_unavailable"

    with Session(auth_engine) as session:
        assert session.scalars(select(AuthSession)).all() == []


def test_missing_digest_key_returns_service_unavailable(
    auth_client: TestClient,
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    monkeypatch.delenv("QOSHNI_AUTH_SECRET_DIGEST_KEY", raising=False)
    get_settings.cache_clear()

    response = auth_client.post("/api/v1/auth/otp/challenges", json={"phone": "+998904444444"})
    assert response.status_code == 503
    assert response.json()["error"]["code"] == "service_unavailable"


def test_expired_challenge_is_rejected(
    auth_client: TestClient,
    fake_provider: FakeOtpProvider,
    auth_engine: Engine,
) -> None:
    payload = _create_challenge(auth_client, phone="+998905555555")
    with Session(auth_engine) as session:
        challenge = session.get(OtpChallenge, uuid.UUID(payload["challenge_id"]))
        assert challenge is not None
        challenge.expires_at = datetime.now(UTC) - timedelta(seconds=1)
        session.commit()

    verify = auth_client.post(
        "/api/v1/auth/otp/verify",
        json={"challenge_id": payload["challenge_id"], "code": fake_provider.last_code},
    )
    assert verify.status_code == 410
    assert verify.json()["error"]["code"] == "challenge_expired"

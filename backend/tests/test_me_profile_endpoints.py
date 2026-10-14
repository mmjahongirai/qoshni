"""Integration tests for /api/v1/me/profile and /api/v1/me/preferences."""

from __future__ import annotations

from collections.abc import Generator
from pathlib import Path

import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine, func, select
from sqlalchemy.engine import Engine
from sqlalchemy.orm import Session, sessionmaker

from app.api.deps.auth import get_otp_delivery_provider
from app.core.config import get_settings
from app.core.database import get_db
from app.db.base import Base
from app.db.models.profile import UserPreferences, UserProfile
from app.main import create_app
from tests.support.fake_otp_provider import FakeOtpProvider

_DIGEST_KEY = "p" * 32


@pytest.fixture
def me_engine(tmp_path: Path, monkeypatch: pytest.MonkeyPatch) -> Generator[Engine, None, None]:
    url = f"sqlite:///{(tmp_path / 'me_api.db').as_posix()}"
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
def me_client(me_engine: Engine) -> Generator[tuple[TestClient, FakeOtpProvider], None, None]:
    provider = FakeOtpProvider()
    session_factory = sessionmaker(bind=me_engine, autoflush=False, autocommit=False)

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


def _auth_headers(tokens: dict) -> dict[str, str]:
    return {"Authorization": f"Bearer {tokens['access_token']}"}


def test_sign_in_provisions_profile_and_preferences(
    me_client: tuple[TestClient, FakeOtpProvider],
    me_engine: Engine,
) -> None:
    client, provider = me_client
    tokens = _sign_in(client, provider)

    profile = client.get("/api/v1/me/profile", headers=_auth_headers(tokens))
    assert profile.status_code == 200, profile.text
    body = profile.json()
    assert body["display_name"] is None
    assert "+998" not in profile.text
    assert "phone" not in body

    prefs = client.get("/api/v1/me/preferences", headers=_auth_headers(tokens))
    assert prefs.status_code == 200, prefs.text
    assert prefs.json()["preferred_language"] == "en"
    assert prefs.json()["personalization_enabled"] is False

    with Session(me_engine) as session:
        assert session.scalar(select(func.count()).select_from(UserProfile)) == 1
        assert session.scalar(select(func.count()).select_from(UserPreferences)) == 1


def test_profile_patch_updates_and_clears_fields(me_client: tuple[TestClient, FakeOtpProvider]) -> None:
    client, provider = me_client
    tokens = _sign_in(client, provider, phone="+998901111111")
    headers = _auth_headers(tokens)

    updated = client.patch(
        "/api/v1/me/profile",
        headers=headers,
        json={"display_name": "Ada", "avatar_storage_ref": "avatars/ada.png"},
    )
    assert updated.status_code == 200
    assert updated.json()["display_name"] == "Ada"
    assert updated.json()["avatar_storage_ref"] == "avatars/ada.png"

    partial = client.patch(
        "/api/v1/me/profile",
        headers=headers,
        json={"display_name": "Ada Updated"},
    )
    assert partial.status_code == 200
    assert partial.json()["display_name"] == "Ada Updated"
    assert partial.json()["avatar_storage_ref"] == "avatars/ada.png"

    cleared = client.patch(
        "/api/v1/me/profile",
        headers=headers,
        json={"clear_avatar_storage_ref": True},
    )
    assert cleared.status_code == 200
    assert cleared.json()["avatar_storage_ref"] is None
    assert cleared.json()["display_name"] == "Ada Updated"

    client.patch(
        "/api/v1/me/profile",
        headers=headers,
        json={"clear_display_name": True},
    )
    assert client.get("/api/v1/me/profile", headers=headers).json()["display_name"] is None


def test_preferences_patch_updates_explicit_fields(me_client: tuple[TestClient, FakeOtpProvider]) -> None:
    client, provider = me_client
    tokens = _sign_in(client, provider, phone="+998902222222")
    headers = _auth_headers(tokens)

    patched = client.patch(
        "/api/v1/me/preferences",
        headers=headers,
        json={"preferred_language": "uz", "personalization_enabled": True},
    )
    assert patched.status_code == 200
    body = patched.json()
    assert body["preferred_language"] == "uz"
    assert body["personalization_enabled"] is True

    invalid = client.patch(
        "/api/v1/me/preferences",
        headers=headers,
        json={"preferred_language": "fr"},
    )
    assert invalid.status_code == 422


def test_me_routes_require_authentication(me_client: tuple[TestClient, FakeOtpProvider]) -> None:
    client, _ = me_client

    profile = client.get("/api/v1/me/profile")
    assert profile.status_code == 401
    assert profile.json()["error"]["code"] == "authentication_required"

    prefs = client.get("/api/v1/me/preferences")
    assert prefs.status_code == 401


def test_profile_not_found_when_row_missing(
    me_client: tuple[TestClient, FakeOtpProvider],
    me_engine: Engine,
) -> None:
    client, provider = me_client
    tokens = _sign_in(client, provider, phone="+998903333333")
    headers = _auth_headers(tokens)

    with Session(me_engine) as session:
        row = session.scalar(select(UserProfile))
        assert row is not None
        session.delete(row)
        session.commit()

    missing = client.get("/api/v1/me/profile", headers=headers)
    assert missing.status_code == 404
    assert missing.json()["error"]["code"] == "profile_not_found"


def test_profile_update_rejects_extra_fields(me_client: tuple[TestClient, FakeOtpProvider]) -> None:
    client, provider = me_client
    tokens = _sign_in(client, provider, phone="+998904444444")
    headers = _auth_headers(tokens)

    response = client.patch(
        "/api/v1/me/profile",
        headers=headers,
        json={"display_name": "Sam", "user_id": "00000000-0000-0000-0000-000000000001"},
    )
    assert response.status_code == 422

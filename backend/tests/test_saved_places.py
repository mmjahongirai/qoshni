"""Saved places API authorization and validation."""

from __future__ import annotations

from collections.abc import Generator
from pathlib import Path

import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.engine import Engine
from sqlalchemy.orm import Session, sessionmaker

from app.api.deps.auth import get_otp_delivery_provider
from app.core.config import get_settings
from app.core.database import get_db
from app.db.base import Base
from app.db.models.identity import User
from app.domain.identity import AccountStatus
from app.main import create_app
from tests.support.fake_otp_provider import FakeOtpProvider

_DIGEST_KEY = "t" * 32


@pytest.fixture
def places_engine(tmp_path: Path, monkeypatch: pytest.MonkeyPatch) -> Generator[Engine, None, None]:
    url = f"sqlite:///{(tmp_path / 'saved_places.db').as_posix()}"
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
def places_client(places_engine: Engine, fake_provider: FakeOtpProvider) -> Generator[TestClient, None, None]:
    session_factory = sessionmaker(bind=places_engine, autoflush=False, autocommit=False)

    def override_db() -> Generator[Session, None, None]:
        session = session_factory()
        try:
            yield session
        finally:
            session.close()

    app = create_app()
    app.dependency_overrides[get_db] = override_db
    app.dependency_overrides[get_otp_delivery_provider] = lambda: fake_provider
    with TestClient(app) as client:
        yield client
    app.dependency_overrides.clear()


@pytest.fixture
def fake_provider() -> FakeOtpProvider:
    return FakeOtpProvider()


def _auth_headers(client: TestClient, fake_provider: FakeOtpProvider) -> dict[str, str]:
    phone = "+998901234568"
    challenge = client.post("/api/v1/auth/otp/challenges", json={"phone": phone})
    assert challenge.status_code == 202, challenge.text
    payload = challenge.json()
    code = fake_provider.last_code
    assert code is not None
    verify = client.post(
        "/api/v1/auth/otp/verify",
        json={"challenge_id": payload["challenge_id"], "code": code},
    )
    assert verify.status_code == 200, verify.text
    token = verify.json()["access_token"]
    return {"Authorization": f"Bearer {token}"}


def test_saved_places_require_auth(places_client: TestClient) -> None:
    response = places_client.get("/api/v1/saved-places")
    assert response.status_code == 401


def test_create_list_update_delete_saved_place(
    places_client: TestClient,
    fake_provider: FakeOtpProvider,
) -> None:
    headers = _auth_headers(places_client, fake_provider)
    create = places_client.post(
        "/api/v1/saved-places",
        json={
            "label": "Home",
            "latitude": 41.31,
            "longitude": 69.28,
            "address_description": "User confirmed",
        },
        headers=headers,
    )
    assert create.status_code == 201, create.text
    place_id = create.json()["id"]

    listing = places_client.get("/api/v1/saved-places", headers=headers)
    assert listing.status_code == 200
    assert len(listing.json()) == 1

    patch = places_client.patch(
        f"/api/v1/saved-places/{place_id}",
        json={"label": "Work"},
        headers=headers,
    )
    assert patch.status_code == 200
    assert patch.json()["label"] == "Work"

    delete = places_client.delete(f"/api/v1/saved-places/{place_id}", headers=headers)
    assert delete.status_code == 204

    listing_after = places_client.get("/api/v1/saved-places", headers=headers)
    assert listing_after.json() == []


def test_cross_user_isolation(
    places_client: TestClient,
    fake_provider: FakeOtpProvider,
    places_engine: Engine,
) -> None:
    headers_a = _auth_headers(places_client, fake_provider)
    created = places_client.post(
        "/api/v1/saved-places",
        json={"label": "Secret", "latitude": 41.0, "longitude": 69.0},
        headers=headers_a,
    )
    place_id = created.json()["id"]

    headers_b = _auth_headers(places_client, fake_provider)
    forbidden = places_client.patch(
        f"/api/v1/saved-places/{place_id}",
        json={"label": "Hacked"},
        headers=headers_b,
    )
    assert forbidden.status_code == 404


def test_invalid_coordinates_rejected(
    places_client: TestClient,
    fake_provider: FakeOtpProvider,
) -> None:
    headers = _auth_headers(places_client, fake_provider)
    response = places_client.post(
        "/api/v1/saved-places",
        json={"label": "Bad", "latitude": 999, "longitude": 0},
        headers=headers,
    )
    assert response.status_code == 400

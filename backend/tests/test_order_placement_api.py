"""HTTP place-order fail-closed behavior."""

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
from app.main import create_app
from tests.support.fake_otp_provider import FakeOtpProvider

_DIGEST_KEY = "t" * 32


@pytest.fixture
def order_engine(tmp_path: Path, monkeypatch: pytest.MonkeyPatch) -> Generator[Engine, None, None]:
    url = f"sqlite:///{(tmp_path / 'orders_api.db').as_posix()}"
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
def order_client(
    order_engine: Engine,
    fake_provider: FakeOtpProvider,
) -> Generator[TestClient, None, None]:
    session_factory = sessionmaker(bind=order_engine, autoflush=False, autocommit=False)

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
    phone = "+998901234588"
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


def test_place_order_fails_closed_catalog_unavailable(
    order_client: TestClient,
    fake_provider: FakeOtpProvider,
) -> None:
    headers = _auth_headers(order_client, fake_provider)
    headers["Idempotency-Key"] = "test-key-1"
    response = order_client.post(
        "/api/v1/orders",
        json={
            "fulfillment_type": "pickup",
            "checkout_correlation_id": "corr-1",
            "server_quote_id": "quote-1",
            "server_quote_revision": 1,
            "lines": [
                {
                    "business_stable_id": "baraka-market",
                    "catalog_item_stable_id": "baraka-fresh-bread",
                    "quantity": 1,
                }
            ],
        },
        headers=headers,
    )
    assert response.status_code == 503
    assert response.json()["code"] == "authoritative_catalog_unavailable"

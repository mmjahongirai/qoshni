"""Server quote issuance fail-closed and durable quote path (fake catalog in tests)."""

from __future__ import annotations

from collections.abc import Generator
from pathlib import Path

import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.engine import Engine
from sqlalchemy.orm import Session, sessionmaker

from app.api.deps.auth import get_otp_delivery_provider
from app.api.deps.checkout import get_consumer_catalog_authority
from app.core.config import get_settings
from app.core.database import get_db
from app.db.base import Base
from app.main import create_app
from app.services.checkout.inventory_reservation_service import InventoryReservationService
from tests.support.fake_consumer_catalog import FakeConsumerCatalogAuthority
from tests.support.fake_otp_provider import FakeOtpProvider

_DIGEST_KEY = "t" * 32


@pytest.fixture
def wp3_engine(tmp_path: Path, monkeypatch: pytest.MonkeyPatch) -> Generator[Engine, None, None]:
    url = f"sqlite:///{(tmp_path / 'wp3.db').as_posix()}"
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
def wp3_client(
    wp3_engine: Engine,
    fake_provider: FakeOtpProvider,
) -> Generator[TestClient, None, None]:
    session_factory = sessionmaker(bind=wp3_engine, autoflush=False, autocommit=False)

    def override_db() -> Generator[Session, None, None]:
        session = session_factory()
        try:
            yield session
        finally:
            session.close()

    ledger = InventoryReservationService().ledger
    catalog = FakeConsumerCatalogAuthority(ledger)
    catalog.seed(
        business_stable_id="baraka-market",
        catalog_item_stable_id="baraka-fresh-bread",
        title="Bread",
        unit_price_minor=8000,
        stock=10,
    )

    app = create_app()
    app.dependency_overrides[get_db] = override_db
    app.dependency_overrides[get_otp_delivery_provider] = lambda: fake_provider
    app.dependency_overrides[get_consumer_catalog_authority] = lambda: catalog
    with TestClient(app) as client:
        yield client
    app.dependency_overrides.clear()


@pytest.fixture
def fake_provider() -> FakeOtpProvider:
    return FakeOtpProvider()


def _auth_headers(client: TestClient, fake_provider: FakeOtpProvider) -> dict[str, str]:
    phone = "+998901234577"
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


def test_quote_and_place_durable_idempotent(wp3_client: TestClient, fake_provider: FakeOtpProvider) -> None:
    headers = _auth_headers(wp3_client, fake_provider)
    quote_resp = wp3_client.post(
        "/api/v1/checkout/quotes",
        json={
            "fulfillment_type": "pickup",
            "lines": [
                {
                    "business_stable_id": "baraka-market",
                    "catalog_item_stable_id": "baraka-fresh-bread",
                    "quantity": 2,
                }
            ],
        },
        headers=headers,
    )
    assert quote_resp.status_code == 200, quote_resp.text
    quote = quote_resp.json()
    headers["Idempotency-Key"] = "wp3-idem-1"
    body = {
        "fulfillment_type": "pickup",
        "checkout_correlation_id": "corr-wp3",
        "server_quote_id": quote["quote_id"],
        "server_quote_revision": quote["pricing_revision"],
        "client_submitted_total_minor": 1,
        "lines": [
            {
                "business_stable_id": "baraka-market",
                "catalog_item_stable_id": "baraka-fresh-bread",
                "quantity": 2,
            }
        ],
    }
    first = wp3_client.post("/api/v1/orders", json=body, headers=headers)
    assert first.status_code == 200, first.text
    assert first.json()["total_minor"] == 16000
    second = wp3_client.post("/api/v1/orders", json=body, headers=headers)
    assert second.status_code == 200
    assert second.json()["idempotent_replay"] is True
    assert second.json()["order_id"] == first.json()["order_id"]


def test_migration_revision_chain() -> None:
    from pathlib import Path

    migration = (
        Path(__file__).resolve().parents[1]
        / "alembic/versions/b0a1f0180001_consumer_orders_and_quotes_foundation.py"
    )
    text = migration.read_text(encoding="utf-8")
    assert 'down_revision' in text and "b0a1f0170001" in text

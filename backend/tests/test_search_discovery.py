"""Search discovery API, cursor integrity, and index projection tests."""

from __future__ import annotations

import uuid
from collections.abc import Generator
from datetime import UTC, datetime
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
from app.db.models.business_onboarding import BusinessOnboardingApplication
from app.db.models.identity import User
from app.db.models.search_discovery import SearchIndexRecord
from app.domain.business_onboarding import BusinessServiceCategory, VerificationStatus
from app.domain.identity import AccountStatus
from app.main import create_app
from app.services.search_discovery.cursor import decode_signed_cursor, encode_signed_cursor, SearchCursorPayload, CURSOR_VERSION
from app.services.search_discovery.event_consumer import (
    SearchIndexProjectionEvent,
    consume_search_index_projection_event,
)
from app.services.search_discovery.metadata import get_catalog_generation
from app.services.search_discovery.projector import project_application, seed_category_rows
from tests.support.fake_otp_provider import FakeOtpProvider

_DIGEST_KEY = "t" * 32


@pytest.fixture
def search_engine(tmp_path: Path, monkeypatch: pytest.MonkeyPatch) -> Generator[Engine, None, None]:
    url = f"sqlite:///{(tmp_path / 'search_discovery.db').as_posix()}"
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
def search_client(search_engine: Engine, fake_provider: FakeOtpProvider) -> Generator[TestClient, None, None]:
    session_factory = sessionmaker(bind=search_engine, autoflush=False, autocommit=False)

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


def _seed_verified_application(session: Session, *, title: str = "Demo Pharmacy") -> uuid.UUID:
    owner = User(account_status=AccountStatus.ACTIVE.value)
    session.add(owner)
    session.flush()
    application = BusinessOnboardingApplication(
        owner_user_id=owner.id,
        legal_business_name=title,
        trade_display_name=title,
        service_category=BusinessServiceCategory.PHARMACY.value,
        registration_jurisdiction="UZ",
        registration_identifier="REG-123",
        verification_status=VerificationStatus.VERIFIED.value,
        submitted_at=datetime.now(tz=UTC),
        reviewed_at=datetime.now(tz=UTC),
    )
    session.add(application)
    session.commit()
    seed_category_rows(session)
    project_application(session, application)
    session.commit()
    return owner.id


def _auth_headers(client: TestClient, fake_provider: FakeOtpProvider) -> dict[str, str]:
    phone = "+998901234567"
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


def test_search_requires_authentication(search_client: TestClient) -> None:
    response = search_client.post("/api/v1/search/discovery", json={"query": "apteka"})
    assert response.status_code == 401


def test_search_returns_verified_business(search_client: TestClient, fake_provider: FakeOtpProvider, search_engine: Engine) -> None:
    session = sessionmaker(bind=search_engine)()
    owner_id = _seed_verified_application(session, title="Shifo Demo")
    session.close()

    headers = _auth_headers(search_client, fake_provider)
    response = search_client.post(
        "/api/v1/search/discovery",
        json={"query": "apteka", "page_size": 10},
        headers=headers,
    )
    assert response.status_code == 200, response.text
    body = response.json()
    titles = {item["title"] for item in body["items"]}
    assert "Pharmacy" in titles
    assert "Shifo Demo" in titles
    assert all(item["is_sponsored"] is False for item in body["items"])


def test_suspended_business_not_searchable(search_client: TestClient, fake_provider: FakeOtpProvider, search_engine: Engine) -> None:
    session = sessionmaker(bind=search_engine)()
    owner = User(account_status=AccountStatus.ACTIVE.value)
    session.add(owner)
    session.flush()
    application = BusinessOnboardingApplication(
        owner_user_id=owner.id,
        legal_business_name="Suspended Shop",
        trade_display_name="Suspended Shop",
        service_category=BusinessServiceCategory.SHOPS.value,
        registration_jurisdiction="UZ",
        registration_identifier="REG-SUSP",
        verification_status=VerificationStatus.SUSPENDED.value,
        submitted_at=datetime.now(tz=UTC),
        reviewed_at=datetime.now(tz=UTC),
    )
    session.add(application)
    session.commit()
    project_application(session, application)
    session.commit()
    owner_id = owner.id
    session.close()

    headers = _auth_headers(search_client, fake_provider)
    response = search_client.post(
        "/api/v1/search/discovery",
        json={"query": "suspended shop", "page_size": 10},
        headers=headers,
    )
    assert response.status_code == 200
    titles = {item["title"] for item in response.json()["items"]}
    assert "Suspended Shop" not in titles


def test_invalid_cursor_rejected(search_client: TestClient, fake_provider: FakeOtpProvider, search_engine: Engine) -> None:
    session = sessionmaker(bind=search_engine)()
    owner_id = _seed_verified_application(session)
    session.close()
    headers = _auth_headers(search_client, fake_provider)
    response = search_client.post(
        "/api/v1/search/discovery",
        json={"query": "apteka", "cursor": "not-valid"},
        headers=headers,
    )
    assert response.status_code == 400
    assert response.json()["error"]["code"] == "invalid_cursor"


def test_signed_cursor_tamper_rejected(search_client: TestClient, fake_provider: FakeOtpProvider, search_engine: Engine) -> None:
    settings = get_settings()
    session = sessionmaker(bind=search_engine)()
    owner_id = _seed_verified_application(session)
    generation = get_catalog_generation(session)
    session.close()
    tampered = encode_signed_cursor(
        settings,
        SearchCursorPayload(
            version=CURSOR_VERSION,
            query_fingerprint="apteka||||",
            catalog_generation=generation,
            after_total_score=999.0,
            after_relevance_score=999.0,
            after_stable_id="business:onboarding:fake",
        ),
    )
    headers = _auth_headers(search_client, fake_provider)
    first = search_client.post(
        "/api/v1/search/discovery",
        json={"query": "apteka", "page_size": 1},
        headers=headers,
    )
    assert first.status_code == 200
    cursor = first.json()["next_cursor"]
    assert cursor is not None
    decoded = decode_signed_cursor(settings, cursor)
    assert decoded is not None
    response = search_client.post(
        "/api/v1/search/discovery",
        json={"query": "apteka", "cursor": tampered},
        headers=headers,
    )
    assert response.status_code == 400


def test_projection_consumer_is_idempotent(search_engine: Engine) -> None:
    session = sessionmaker(bind=search_engine)()
    owner = User(account_status=AccountStatus.ACTIVE.value)
    session.add(owner)
    session.flush()
    application = BusinessOnboardingApplication(
        owner_user_id=owner.id,
        legal_business_name="Consumer Test",
        trade_display_name="Consumer Test",
        service_category=BusinessServiceCategory.RESTAURANTS.value,
        registration_jurisdiction="UZ",
        registration_identifier="REG-CONS",
        verification_status=VerificationStatus.VERIFIED.value,
        submitted_at=datetime.now(tz=UTC),
        reviewed_at=datetime.now(tz=UTC),
    )
    session.add(application)
    session.commit()
    event = SearchIndexProjectionEvent(event_id=uuid.uuid4(), application_id=application.id)
    assert consume_search_index_projection_event(session, event) is True
    assert consume_search_index_projection_event(session, event) is False
    session.commit()
    row = session.scalar(
        select(SearchIndexRecord).where(SearchIndexRecord.title == "Consumer Test")
    )
    assert row is not None
    session.close()

"""Location-aware search discovery (haversine, no PostGIS)."""

from __future__ import annotations

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
from app.services.search_discovery.projector import project_application, seed_category_rows
from tests.support.fake_otp_provider import FakeOtpProvider
from tests.test_search_discovery import _auth_headers

_DIGEST_KEY = "t" * 32


@pytest.fixture
def loc_engine(tmp_path: Path, monkeypatch: pytest.MonkeyPatch) -> Generator[Engine, None, None]:
    url = f"sqlite:///{(tmp_path / 'search_location.db').as_posix()}"
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
def loc_client(loc_engine: Engine, fake_provider: FakeOtpProvider) -> Generator[TestClient, None, None]:
    session_factory = sessionmaker(bind=loc_engine, autoflush=False, autocommit=False)

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


def _seed_business_with_coords(session: Session, *, title: str, lat: float, lng: float) -> None:
    owner = User(
        phone_e164=f"+9989013{uuid.uuid4().int % 100000000:07d}",
        status=AccountStatus.ACTIVE.value,
    )
    session.add(owner)
    session.flush()
    application = BusinessOnboardingApplication(
        owner_user_id=owner.id,
        legal_business_name=title,
        trade_display_name=title,
        service_category=BusinessServiceCategory.PHARMACY.value,
        registration_jurisdiction="UZ",
        registration_identifier=f"REG-{title}",
        verification_status=VerificationStatus.VERIFIED.value,
        submitted_at=datetime.now(tz=UTC),
        reviewed_at=datetime.now(tz=UTC),
    )
    session.add(application)
    session.commit()
    seed_category_rows(session)
    stable_id = project_application(session, application)
    assert stable_id is not None
    row = session.get(SearchIndexRecord, stable_id)
    assert row is not None
    row.branch_latitude = lat
    row.branch_longitude = lng
    session.commit()


def test_nearby_search_excludes_records_without_coordinates(
    loc_client: TestClient,
    fake_provider: FakeOtpProvider,
    loc_engine: Engine,
) -> None:
    session = sessionmaker(bind=loc_engine)()
    _seed_business_with_coords(session, title="Near Pharmacy", lat=41.311, lng=69.279)
    _seed_business_with_coords(session, title="Far Without Coords", lat=40.0, lng=64.0)
    no_coords = session.scalar(
        select(SearchIndexRecord).where(SearchIndexRecord.title == "Far Without Coords")
    )
    assert no_coords is not None
    no_coords.branch_latitude = None
    no_coords.branch_longitude = None
    session.commit()
    session.close()

    headers = _auth_headers(loc_client, fake_provider)
    response = loc_client.post(
        "/api/v1/search/discovery",
        json={
            "query": "pharmacy",
            "page_size": 10,
            "search_latitude": 41.311,
            "search_longitude": 69.279,
            "max_distance_meters": 5000,
        },
        headers=headers,
    )
    assert response.status_code == 200, response.text
    titles = {item["title"] for item in response.json()["items"]}
    assert "Near Pharmacy" in titles
    assert "Far Without Coords" not in titles


def test_invalid_radius_rejected(loc_client: TestClient, fake_provider: FakeOtpProvider) -> None:
    headers = _auth_headers(loc_client, fake_provider)
    response = loc_client.post(
        "/api/v1/search/discovery",
        json={
            "query": "apteka",
            "search_latitude": 41.0,
            "search_longitude": 69.0,
            "max_distance_meters": 999_999,
        },
        headers=headers,
    )
    assert response.status_code == 400


def test_location_cursor_mismatch_on_radius_change(
    loc_client: TestClient,
    fake_provider: FakeOtpProvider,
    loc_engine: Engine,
) -> None:
    session = sessionmaker(bind=loc_engine)()
    _seed_business_with_coords(session, title="Cursor Pharmacy", lat=41.311, lng=69.279)
    session.close()

    headers = _auth_headers(loc_client, fake_provider)
    first = loc_client.post(
        "/api/v1/search/discovery",
        json={
            "query": "pharmacy",
            "page_size": 1,
            "search_latitude": 41.311,
            "search_longitude": 69.279,
            "max_distance_meters": 5000,
        },
        headers=headers,
    )
    assert first.status_code == 200
    cursor = first.json()["next_cursor"]
    if cursor is None:
        pytest.skip("Not enough rows for pagination in this fixture")
    second = loc_client.post(
        "/api/v1/search/discovery",
        json={
            "query": "pharmacy",
            "page_size": 1,
            "cursor": cursor,
            "search_latitude": 41.311,
            "search_longitude": 69.279,
            "max_distance_meters": 8000,
        },
        headers=headers,
    )
    assert second.status_code == 400

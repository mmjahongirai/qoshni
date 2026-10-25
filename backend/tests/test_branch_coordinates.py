"""Trusted branch coordinate propose/verify and search projection."""

from __future__ import annotations

from collections.abc import Generator
from datetime import UTC, datetime
from pathlib import Path
from uuid import uuid4

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
from app.domain.branch_coordinates import BranchCoordinateSource
from app.domain.business_onboarding import BusinessServiceCategory, VerificationStatus
from app.db.models.platform_roles import UserPlatformRoleAssignment
from app.domain.identity import AccountStatus
from app.domain.platform_roles import PlatformRole
from app.domain.role_assignments import RoleAssignmentGrantSource
from app.main import create_app
from app.services.business_onboarding.branch_coordinate_service import (
    propose_branch_coordinates,
    verify_branch_coordinates,
)
from app.services.search_discovery.projector import project_application, seed_category_rows
from tests.support.fake_otp_provider import FakeOtpProvider

_DIGEST_KEY = "t" * 32


@pytest.fixture
def coord_engine(tmp_path: Path, monkeypatch: pytest.MonkeyPatch) -> Generator[Engine, None, None]:
    url = f"sqlite:///{(tmp_path / 'branch_coords.db').as_posix()}"
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
def coord_client(coord_engine: Engine, fake_provider: FakeOtpProvider) -> Generator[TestClient, None, None]:
    session_factory = sessionmaker(bind=coord_engine, autoflush=False, autocommit=False)

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


def _seed_verified_application(session: Session) -> tuple[User, BusinessOnboardingApplication]:
    owner = User(status=AccountStatus.ACTIVE.value)
    reviewer = User(status=AccountStatus.ACTIVE.value)
    session.add_all([owner, reviewer])
    session.flush()
    session.add(
        UserPlatformRoleAssignment(
            user_id=reviewer.id,
            role=PlatformRole.BUSINESS_ONBOARDING_REVIEWER.value,
            grant_source=RoleAssignmentGrantSource.OPERATOR_CONTROL_PLANE.value,
        )
    )
    application = BusinessOnboardingApplication(
        owner_user_id=owner.id,
        legal_business_name="Coord Shop",
        trade_display_name="Coord Shop",
        service_category=BusinessServiceCategory.PHARMACY.value,
        registration_jurisdiction="UZ",
        registration_identifier=f"REG-{uuid4()}",
        verification_status=VerificationStatus.VERIFIED.value,
        submitted_at=datetime.now(tz=UTC),
        reviewed_at=datetime.now(tz=UTC),
    )
    session.add(application)
    session.commit()
    seed_category_rows(session)
    project_application(session, application)
    session.commit()
    return owner, application


def test_unverified_coordinates_not_projected(coord_engine: Engine) -> None:
    session = sessionmaker(bind=coord_engine)()
    owner, application = _seed_verified_application(session)
    proposed = propose_branch_coordinates(
        session,
        owner_user_id=owner.id,
        application_id=application.id,
        latitude=41.31,
        longitude=69.28,
        source=BranchCoordinateSource.OWNER_CONFIRMED_PIN,
    )
    assert proposed is not None
    session.commit()
    row = session.scalar(
        select(SearchIndexRecord).where(
            SearchIndexRecord.source_application_id == application.id
        )
    )
    assert row is not None
    assert row.branch_latitude is None
    assert row.branch_longitude is None
    session.close()


def test_verified_coordinates_projected(coord_engine: Engine) -> None:
    session = sessionmaker(bind=coord_engine)()
    owner, application = _seed_verified_application(session)
    reviewer = session.scalars(select(User).where(User.id != owner.id)).first()
    assert reviewer is not None
    propose_branch_coordinates(
        session,
        owner_user_id=owner.id,
        application_id=application.id,
        latitude=41.31,
        longitude=69.28,
        source=BranchCoordinateSource.MANUAL_MAP_PIN,
    )
    verify_branch_coordinates(
        session,
        reviewer_user_id=reviewer.id,
        application_id=application.id,
    )
    session.commit()
    row = session.scalar(
        select(SearchIndexRecord).where(
            SearchIndexRecord.source_application_id == application.id
        )
    )
    assert row is not None
    assert row.branch_latitude == pytest.approx(41.31)
    assert row.branch_longitude == pytest.approx(69.28)
    session.close()

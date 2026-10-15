"""Alembic migration tests for document audit event types."""

from collections.abc import Generator
from pathlib import Path

import uuid

import pytest
from alembic import command
from alembic.config import Config
from sqlalchemy import create_engine, select
from sqlalchemy.engine import Engine
from sqlalchemy.orm import Session

from app.core.config import get_settings
from app.db.base import Base
from app.db.models import User
from app.db.models.business_onboarding import BusinessOnboardingApplication, BusinessOnboardingAuditEvent
from app.domain.business_onboarding import OnboardingAuditActorRole, OnboardingAuditEventType

BACKEND_ROOT = Path(__file__).resolve().parents[1]


@pytest.fixture
def sqlite_url(tmp_path: Path, monkeypatch: pytest.MonkeyPatch) -> Generator[str, None, None]:
    url = f"sqlite:///{(tmp_path / 'document_audit_migration.db').as_posix()}"
    monkeypatch.delenv("DATABASE_URL", raising=False)
    monkeypatch.setenv("QOSHNI_DATABASE_URL", url)
    get_settings.cache_clear()
    yield url
    get_settings.cache_clear()


@pytest.fixture
def alembic_config(sqlite_url: str) -> Config:
    config = Config()
    config.set_main_option("script_location", str(BACKEND_ROOT / "alembic"))
    config.set_main_option("sqlalchemy.url", sqlite_url)
    return config


@pytest.fixture
def engine(sqlite_url: str) -> Generator[Engine, None, None]:
    sqlite_engine = create_engine(sqlite_url)
    yield sqlite_engine
    sqlite_engine.dispose()


def test_document_audit_event_types_migration_upgrade_and_downgrade(
    alembic_config: Config,
    engine: Engine,
) -> None:
    command.upgrade(alembic_config, "b0a1f0120001")
    with Session(engine) as session:
        owner = User(phone_e164="+998901230001")
        session.add(owner)
        session.flush()
        application = BusinessOnboardingApplication(owner_user_id=owner.id)
        session.add(application)
        session.flush()
        session.add(
            BusinessOnboardingAuditEvent(
                application_id=application.id,
                event_type=OnboardingAuditEventType.DOCUMENT_REGISTERED.value,
                actor_role=OnboardingAuditActorRole.OWNER.value,
                actor_user_id=owner.id,
                details={"document_id": str(uuid.uuid4())},
            ),
        )
        session.commit()
        assert session.scalars(select(BusinessOnboardingAuditEvent)).one()
        for event in session.scalars(select(BusinessOnboardingAuditEvent)).all():
            session.delete(event)
        session.commit()

    command.downgrade(alembic_config, "b0a1f0110001")

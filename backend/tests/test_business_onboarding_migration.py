"""Upgrade/downgrade the business onboarding revision on temporary local SQLite."""

from collections.abc import Generator
from pathlib import Path

import pytest
from alembic import command
from alembic.autogenerate import compare_metadata
from alembic.config import Config
from alembic.migration import MigrationContext
from sqlalchemy import CheckConstraint, create_engine, inspect, text
from sqlalchemy.engine import Engine
from sqlalchemy.exc import IntegrityError

from app.core.config import get_settings
from app.db.base import Base

BACKEND_ROOT = Path(__file__).resolve().parents[1]
ONBOARDING_TABLES = {
    "business_onboarding_applications",
    "business_onboarding_audit_events",
}
PROFILE_TABLES = {"user_profiles", "user_preferences"}


@pytest.fixture
def sqlite_url(tmp_path: Path, monkeypatch: pytest.MonkeyPatch) -> Generator[str, None, None]:
    url = f"sqlite:///{(tmp_path / 'onboarding_migration.db').as_posix()}"
    monkeypatch.delenv("DATABASE_URL", raising=False)
    monkeypatch.setenv("QOSHNI_DATABASE_URL", url)
    get_settings.cache_clear()
    yield url
    get_settings.cache_clear()


@pytest.fixture
def alembic_config(sqlite_url: str) -> Config:
    config = Config()
    config.set_main_option("script_location", str(BACKEND_ROOT / "alembic"))
    return config


@pytest.fixture
def engine(sqlite_url: str) -> Generator[Engine, None, None]:
    sqlite_engine = create_engine(sqlite_url)
    yield sqlite_engine
    sqlite_engine.dispose()


def test_upgrade_creates_onboarding_schema(alembic_config: Config, engine: Engine) -> None:
    command.upgrade(alembic_config, "head")

    inspector = inspect(engine)
    assert ONBOARDING_TABLES <= set(inspector.get_table_names())
    assert PROFILE_TABLES <= set(inspector.get_table_names())


def test_migrated_schema_matches_orm_metadata(alembic_config: Config, engine: Engine) -> None:
    command.upgrade(alembic_config, "head")

    with engine.connect() as connection:
        context = MigrationContext.configure(connection, opts={"compare_type": False})
        differences = compare_metadata(context, Base.metadata)

    assert differences == []


def test_onboarding_check_constraint_names_match_orm(alembic_config: Config, engine: Engine) -> None:
    command.upgrade(alembic_config, "head")
    inspector = inspect(engine)

    for table_name in ONBOARDING_TABLES:
        migrated = {ck["name"] for ck in inspector.get_check_constraints(table_name)}
        declared = {
            constraint.name
            for constraint in Base.metadata.tables[table_name].constraints
            if isinstance(constraint, CheckConstraint)
        }
        assert migrated == declared, table_name


def test_downgrade_onboarding_revision_removes_only_onboarding_tables(
    alembic_config: Config,
    engine: Engine,
) -> None:
    command.upgrade(alembic_config, "head")
    command.downgrade(alembic_config, "b0a1f0070001")

    inspector = inspect(engine)
    assert not ONBOARDING_TABLES & set(inspector.get_table_names())
    assert PROFILE_TABLES <= set(inspector.get_table_names())
    assert "users" in inspector.get_table_names()

    command.upgrade(alembic_config, "b0a1f0080001")
    assert ONBOARDING_TABLES <= set(inspect(engine).get_table_names())


def test_migration_allows_multiple_applications_per_owner(alembic_config: Config, engine: Engine) -> None:
    command.upgrade(alembic_config, "head")

    user_id = "00000000000000000000000000000001"
    with engine.begin() as connection:
        connection.execute(
            text(
                "INSERT INTO users (id, phone_e164, status) "
                "VALUES (:id, '+998901234567', 'active')",
            ),
            {"id": user_id},
        )
        connection.execute(
            text(
                "INSERT INTO business_onboarding_applications (id, owner_user_id, legal_business_name) "
                "VALUES ('00000000000000000000000000000002', :owner, 'Alpha')",
            ),
            {"owner": user_id},
        )
        connection.execute(
            text(
                "INSERT INTO business_onboarding_applications (id, owner_user_id, legal_business_name) "
                "VALUES ('00000000000000000000000000000003', :owner, 'Beta')",
            ),
            {"owner": user_id},
        )

    with pytest.raises(IntegrityError):
        with engine.begin() as connection:
            connection.execute(
                text(
                    "INSERT INTO business_onboarding_applications "
                    "(id, owner_user_id, verification_status, rejection_reason_code, submitted_at) "
                    "VALUES ('00000000000000000000000000000004', :owner, 'rejected', NULL, "
                    "'2026-10-14 12:00:00')",
                ),
                {"owner": user_id},
            )

"""Migration tests for business_onboarding_documents."""

from collections.abc import Generator
from pathlib import Path

import pytest
from alembic import command
from alembic.autogenerate import compare_metadata
from alembic.config import Config
from alembic.migration import MigrationContext
from sqlalchemy import CheckConstraint, create_engine, inspect
from sqlalchemy.engine import Engine

from app.core.config import get_settings
from app.db.base import Base

BACKEND_ROOT = Path(__file__).resolve().parents[1]
DOCUMENT_TABLE = "business_onboarding_documents"


@pytest.fixture
def sqlite_url(tmp_path: Path, monkeypatch: pytest.MonkeyPatch) -> Generator[str, None, None]:
    url = f"sqlite:///{(tmp_path / 'documents_migration.db').as_posix()}"
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


def test_upgrade_creates_documents_table(alembic_config: Config, engine: Engine) -> None:
    command.upgrade(alembic_config, "head")
    assert DOCUMENT_TABLE in inspect(engine).get_table_names()


def test_migrated_schema_matches_orm_metadata(alembic_config: Config, engine: Engine) -> None:
    command.upgrade(alembic_config, "head")
    with engine.connect() as connection:
        context = MigrationContext.configure(connection, opts={"compare_type": False})
        differences = compare_metadata(context, Base.metadata)
    assert differences == []


def test_document_check_constraints_match_orm(alembic_config: Config, engine: Engine) -> None:
    command.upgrade(alembic_config, "head")
    inspector = inspect(engine)
    migrated = {ck["name"] for ck in inspector.get_check_constraints(DOCUMENT_TABLE)}
    declared = {
        constraint.name
        for constraint in Base.metadata.tables[DOCUMENT_TABLE].constraints
        if isinstance(constraint, CheckConstraint)
    }
    assert migrated == declared


def test_downgrade_documents_revision(alembic_config: Config, engine: Engine) -> None:
    command.upgrade(alembic_config, "head")
    command.downgrade(alembic_config, "b0a1f0090001")
    assert DOCUMENT_TABLE not in inspect(engine).get_table_names()
    command.upgrade(alembic_config, "b0a1f0100001")
    assert DOCUMENT_TABLE in inspect(engine).get_table_names()

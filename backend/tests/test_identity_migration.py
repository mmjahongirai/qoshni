"""Upgrade/downgrade the identity revision against a temporary local SQLite file.

No shared or external database is touched: the database URL is forced to a
file inside pytest's ``tmp_path`` for the duration of each test.
"""

from collections.abc import Generator
from enum import StrEnum
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
from app.domain.identity import (
    AccountStatus,
    AuthAuditEventType,
    DevicePlatform,
    OtpPurpose,
    SessionRevocationReason,
)

BACKEND_ROOT = Path(__file__).resolve().parents[1]
IDENTITY_TABLES = {"users", "otp_challenges", "auth_sessions", "auth_audit_events"}


@pytest.fixture
def sqlite_url(tmp_path: Path, monkeypatch: pytest.MonkeyPatch) -> Generator[str, None, None]:
    url = f"sqlite:///{(tmp_path / 'migration.db').as_posix()}"
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


def _tables(engine: Engine) -> set[str]:
    return set(inspect(engine).get_table_names())


def test_upgrade_creates_identity_schema(alembic_config: Config, engine: Engine) -> None:
    command.upgrade(alembic_config, "head")

    inspector = inspect(engine)
    assert IDENTITY_TABLES <= set(inspector.get_table_names())
    assert {uq["name"] for uq in inspector.get_unique_constraints("users")} == {
        "uq_users_phone_e164",
    }
    session_unique = {uq["name"] for uq in inspector.get_unique_constraints("auth_sessions")}
    assert "uq_auth_sessions_refresh_token_digest" in session_unique
    assert "uq_auth_sessions_access_token_digest" in session_unique
    session_fks = inspector.get_foreign_keys("auth_sessions")
    assert [(fk["referred_table"], fk["options"].get("ondelete")) for fk in session_fks] == [
        ("users", "CASCADE"),
    ]
    assert {ix["name"] for ix in inspector.get_indexes("otp_challenges")} == {
        "ix_otp_challenges_phone_e164_purpose_created_at",
        "ix_otp_challenges_expires_at",
    }


def test_migrated_schema_matches_orm_metadata(alembic_config: Config, engine: Engine) -> None:
    command.upgrade(alembic_config, "head")

    with engine.connect() as connection:
        context = MigrationContext.configure(connection, opts={"compare_type": False})
        differences = compare_metadata(context, Base.metadata)

    assert differences == []


def test_migrated_check_constraint_names_match_orm_metadata(
    alembic_config: Config,
    engine: Engine,
) -> None:
    command.upgrade(alembic_config, "head")
    inspector = inspect(engine)

    for table_name in IDENTITY_TABLES:
        migrated = {ck["name"] for ck in inspector.get_check_constraints(table_name)}
        declared = {
            constraint.name
            for constraint in Base.metadata.tables[table_name].constraints
            if isinstance(constraint, CheckConstraint)
        }
        assert migrated == declared, table_name
        assert all(name.count("ck_") == 1 for name in migrated)


def test_downgrade_to_baseline_removes_identity_schema(
    alembic_config: Config,
    engine: Engine,
) -> None:
    command.upgrade(alembic_config, "head")
    command.downgrade(alembic_config, "b0a1f0020001")

    assert not IDENTITY_TABLES & _tables(engine)

    command.upgrade(alembic_config, "head")
    assert IDENTITY_TABLES <= _tables(engine)


def _insert_accepts(engine: Engine, sql: str, params: dict[str, object]) -> None:
    with engine.begin() as connection:
        connection.execute(text(sql), params)


def _values(enum_type: type[StrEnum]) -> list[str]:
    return [member.value for member in enum_type]


def test_migration_check_constraints_match_domain_enums(
    alembic_config: Config,
    engine: Engine,
) -> None:
    command.upgrade(alembic_config, "head")

    for index, status in enumerate(_values(AccountStatus)):
        _insert_accepts(
            engine,
            "INSERT INTO users (id, phone_e164, status) VALUES (:id, :phone, :status)",
            {"id": f"{index:032x}", "phone": f"+99890000000{index}", "status": status},
        )
    for index, purpose in enumerate(_values(OtpPurpose)):
        _insert_accepts(
            engine,
            "INSERT INTO otp_challenges (id, phone_e164, purpose, code_digest, expires_at, "
            "max_attempts) VALUES (:id, '+998900000000', :purpose, 'x', CURRENT_TIMESTAMP, 5)",
            {"id": f"{index + 100:032x}", "purpose": purpose},
        )
    for index, event_type in enumerate(_values(AuthAuditEventType)):
        _insert_accepts(
            engine,
            "INSERT INTO auth_audit_events (id, event_type) VALUES (:id, :event_type)",
            {"id": f"{index + 200:032x}", "event_type": event_type},
        )

    platforms = _values(DevicePlatform)
    reasons = _values(SessionRevocationReason)
    for index in range(max(len(platforms), len(reasons))):
        _insert_accepts(
            engine,
            "INSERT INTO auth_sessions (id, user_id, access_token_digest, access_token_expires_at, "
            "refresh_token_digest, expires_at, device_platform, revoked_at, revoked_reason) "
            "VALUES (:id, :user_id, :access_digest, CURRENT_TIMESTAMP, :digest, "
            "CURRENT_TIMESTAMP, :platform, CURRENT_TIMESTAMP, :reason)",
            {
                "id": f"{index + 300:032x}",
                "user_id": f"{0:032x}",
                "access_digest": f"access-digest-{index}",
                "digest": f"digest-{index}",
                "platform": platforms[index % len(platforms)],
                "reason": reasons[index % len(reasons)],
            },
        )

    with pytest.raises(IntegrityError):
        _insert_accepts(
            engine,
            "INSERT INTO otp_challenges (id, phone_e164, purpose, code_digest, expires_at, "
            "attempt_count, max_attempts) VALUES (:id, '+998900000000', 'sign_in', 'x', "
            "CURRENT_TIMESTAMP, 6, 5)",
            {"id": f"{999:032x}"},
        )

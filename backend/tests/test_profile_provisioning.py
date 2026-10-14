"""Profile provisioning service behavior."""

import uuid
from collections.abc import Generator

import pytest
from sqlalchemy import create_engine, event, func, select
from sqlalchemy.engine import Engine
from sqlalchemy.orm import Session

from app.db.base import Base
from app.db.models import User, UserPreferences, UserProfile
from app.services.profile.provisioning import ensure_user_profile_resources


@pytest.fixture
def engine() -> Generator[Engine, None, None]:
    sqlite_engine = create_engine("sqlite://")

    @event.listens_for(sqlite_engine, "connect")
    def _enable_foreign_keys(dbapi_connection, _record) -> None:
        dbapi_connection.execute("PRAGMA foreign_keys=ON")

    Base.metadata.create_all(sqlite_engine)
    yield sqlite_engine
    sqlite_engine.dispose()


def test_provisioning_is_idempotent(engine: Engine) -> None:
    with Session(engine) as session:
        user = User(phone_e164="+998901234567")
        session.add(user)
        session.flush()

        ensure_user_profile_resources(session, user.id)
        ensure_user_profile_resources(session, user.id)
        session.commit()

        assert session.scalar(select(func.count()).select_from(UserProfile)) == 1
        assert session.scalar(select(func.count()).select_from(UserPreferences)) == 1


def test_provisioning_requires_existing_user(engine: Engine) -> None:
    with Session(engine) as session:
        with pytest.raises(Exception):
            ensure_user_profile_resources(session, uuid.uuid4())
            session.flush()

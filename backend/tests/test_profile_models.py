"""User profile and preferences model constraints."""

import uuid
from collections.abc import Generator
from datetime import UTC, datetime

import pytest
from sqlalchemy import create_engine, event, select
from sqlalchemy.engine import Engine
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from app.db.base import Base
from app.db.models import User, UserPreferences, UserProfile
from app.domain.profile import SupportedLocale


@pytest.fixture
def engine() -> Generator[Engine, None, None]:
    sqlite_engine = create_engine("sqlite://")

    @event.listens_for(sqlite_engine, "connect")
    def _enable_foreign_keys(dbapi_connection, _record) -> None:
        dbapi_connection.execute("PRAGMA foreign_keys=ON")

    Base.metadata.create_all(sqlite_engine)
    yield sqlite_engine
    sqlite_engine.dispose()


@pytest.fixture
def session(engine: Engine) -> Generator[Session, None, None]:
    with Session(engine) as db_session:
        yield db_session


def _user(phone: str = "+998901234567") -> User:
    return User(phone_e164=phone)


def test_profile_and_preferences_default_timestamps(session: Session) -> None:
    user = _user()
    session.add(user)
    session.flush()

    profile = UserProfile(user_id=user.id)
    prefs = UserPreferences(user_id=user.id)
    session.add_all([profile, prefs])
    session.commit()

    assert isinstance(profile.id, uuid.UUID)
    assert profile.display_name is None
    assert profile.avatar_storage_ref is None
    assert profile.created_at is not None
    assert prefs.preferred_language == SupportedLocale.ENGLISH.value
    assert prefs.personalization_enabled is False
    assert prefs.created_at is not None


def test_one_profile_per_user(session: Session) -> None:
    user = _user()
    session.add(user)
    session.flush()
    session.add_all(
        [
            UserProfile(user_id=user.id),
            UserProfile(user_id=user.id),
        ],
    )

    with pytest.raises(IntegrityError):
        session.commit()


def test_one_preferences_record_per_user(session: Session) -> None:
    user = _user()
    session.add(user)
    session.flush()
    session.add_all(
        [
            UserPreferences(user_id=user.id),
            UserPreferences(user_id=user.id),
        ],
    )

    with pytest.raises(IntegrityError):
        session.commit()


@pytest.mark.parametrize(
    ("language", "phone_suffix"),
    [("en", "01"), ("ru", "02"), ("uz", "03")],
)
def test_supported_preferred_language_values(
    session: Session,
    language: str,
    phone_suffix: str,
) -> None:
    user = _user(phone=f"+9989012345{phone_suffix}")
    session.add(user)
    session.flush()
    session.add(UserPreferences(user_id=user.id, preferred_language=language))
    session.commit()

    stored = session.scalars(select(UserPreferences)).one()
    assert stored.preferred_language == language


def test_invalid_preferred_language_rejected(session: Session) -> None:
    user = _user()
    session.add(user)
    session.flush()
    session.add(UserPreferences(user_id=user.id, preferred_language="fr"))

    with pytest.raises(IntegrityError):
        session.commit()


def test_blank_display_name_rejected(session: Session) -> None:
    user = _user()
    session.add(user)
    session.flush()
    session.add(UserProfile(user_id=user.id, display_name="   "))

    with pytest.raises(IntegrityError):
        session.commit()


def test_profile_requires_existing_user(session: Session) -> None:
    session.add(UserProfile(user_id=uuid.uuid4()))

    with pytest.raises(IntegrityError):
        session.commit()


def test_deleting_user_cascades_profile_and_preferences(session: Session) -> None:
    user = _user()
    session.add(user)
    session.flush()
    session.add_all(
        [
            UserProfile(user_id=user.id, display_name="Sam"),
            UserPreferences(user_id=user.id, preferred_language="uz"),
        ],
    )
    session.commit()

    session.delete(user)
    session.commit()
    session.expire_all()

    assert session.scalars(select(UserProfile)).all() == []
    assert session.scalars(select(UserPreferences)).all() == []


def test_profile_tables_exclude_phone_and_secrets() -> None:
    profile_columns = set(UserProfile.__table__.columns.keys())
    pref_columns = set(UserPreferences.__table__.columns.keys())

    forbidden = {"phone", "phone_e164", "access_token", "refresh_token", "code", "otp"}
    assert not forbidden & profile_columns
    assert not forbidden & pref_columns


def test_repr_omits_display_name_and_avatar_ref(session: Session) -> None:
    user = _user()
    session.add(user)
    session.flush()
    profile = UserProfile(
        user_id=user.id,
        display_name="Secret Name",
        avatar_storage_ref="avatars/user/photo.jpg",
    )
    session.add(profile)
    session.commit()

    text = repr(profile)
    assert "Secret Name" not in text
    assert "photo.jpg" not in text

"""Identity model constraints, exercised on a throwaway in-memory SQLite engine."""

import uuid
from collections.abc import Generator
from datetime import UTC, datetime, timedelta

import pytest
from sqlalchemy import create_engine, event, select
from sqlalchemy.engine import Engine
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from app.core.config import Settings
from app.db.base import Base
from app.db.models import AuthAuditEvent, AuthSession, OtpChallenge, User
from app.domain.identity import AccountStatus, AuthAuditEventType, SessionRevocationReason


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


def _now() -> datetime:
    return datetime.now(UTC)


def _user(phone: str = "+998901234567") -> User:
    return User(phone_e164=phone)


def _challenge(**overrides: object) -> OtpChallenge:
    values: dict[str, object] = {
        "phone_e164": "+998901234567",
        "purpose": "sign_in",
        "code_digest": "d" * 64,
        "expires_at": _now() + timedelta(minutes=5),
        "max_attempts": 5,
    }
    values.update(overrides)
    return OtpChallenge(**values)


def _auth_session(user: User, **overrides: object) -> AuthSession:
    values: dict[str, object] = {
        "user_id": user.id,
        "access_token_digest": uuid.uuid4().hex * 2,
        "access_token_expires_at": _now() + timedelta(hours=1),
        "refresh_token_digest": uuid.uuid4().hex * 2,
        "expires_at": _now() + timedelta(days=30),
    }
    values.update(overrides)
    return AuthSession(**values)


def test_user_defaults_to_pending_with_stable_uuid(session: Session) -> None:
    user = _user()
    session.add(user)
    session.commit()

    assert isinstance(user.id, uuid.UUID)
    assert user.status == AccountStatus.PENDING
    assert user.phone_verified_at is None
    assert user.created_at is not None and user.updated_at is not None


def test_phone_identity_is_unique(session: Session) -> None:
    session.add_all([_user(), _user()])

    with pytest.raises(IntegrityError):
        session.commit()


def test_user_status_rejects_unknown_value(session: Session) -> None:
    session.add(User(phone_e164="+998901234567", status="admin"))

    with pytest.raises(IntegrityError):
        session.commit()


def test_otp_challenge_tracks_expiry_attempts_and_consumption(session: Session) -> None:
    challenge = _challenge()
    session.add(challenge)
    session.commit()

    assert challenge.attempt_count == 0
    assert challenge.consumed_at is None

    challenge.attempt_count = 5
    challenge.consumed_at = _now()
    session.commit()

    stored = session.scalars(select(OtpChallenge)).one()
    assert stored.attempt_count == stored.max_attempts
    assert stored.consumed_at is not None
    assert stored.expires_at is not None


@pytest.mark.parametrize(
    "overrides",
    [
        {"attempt_count": 6, "max_attempts": 5},
        {"attempt_count": -1},
        {"max_attempts": 0},
        {"purpose": "password_reset"},
    ],
)
def test_otp_challenge_rejects_invalid_counters_and_purpose(
    session: Session,
    overrides: dict[str, object],
) -> None:
    session.add(_challenge(**overrides))

    with pytest.raises(IntegrityError):
        session.commit()


def test_otp_challenge_has_no_plaintext_code_column() -> None:
    columns = set(OtpChallenge.__table__.columns.keys())

    assert "code_digest" in columns
    assert not {"code", "otp", "otp_code", "plain_code"} & columns


def test_session_refresh_token_digest_is_unique(session: Session) -> None:
    user = _user()
    session.add(user)
    session.flush()
    session.add_all(
        [
            _auth_session(user, refresh_token_digest="a" * 64),
            _auth_session(user, refresh_token_digest="a" * 64),
        ],
    )

    with pytest.raises(IntegrityError):
        session.commit()


def test_session_revocation_requires_reason_and_timestamp_together(session: Session) -> None:
    user = _user()
    session.add(user)
    session.flush()
    session.add(_auth_session(user, revoked_at=_now()))

    with pytest.raises(IntegrityError):
        session.commit()


def test_session_revocation_is_persisted(session: Session) -> None:
    user = _user()
    session.add(user)
    session.flush()
    auth_session = _auth_session(user)
    session.add(auth_session)
    session.commit()

    assert auth_session.revoked_at is None
    auth_session.revoked_at = _now()
    auth_session.revoked_reason = SessionRevocationReason.LOGOUT.value
    session.commit()

    stored = session.get(AuthSession, auth_session.id)
    assert stored is not None
    assert stored.revoked_reason == "logout"


def test_session_requires_existing_user(session: Session) -> None:
    session.add(
        AuthSession(
            user_id=uuid.uuid4(),
            refresh_token_digest="b" * 64,
            expires_at=_now() + timedelta(days=1),
        ),
    )

    with pytest.raises(IntegrityError):
        session.commit()


def test_deleting_user_cascades_sessions_and_keeps_anonymized_audit(session: Session) -> None:
    user = _user()
    session.add(user)
    session.flush()
    session.add(_auth_session(user))
    session.add(
        AuthAuditEvent(
            event_type=AuthAuditEventType.SESSION_CREATED.value,
            user_id=user.id,
            correlation_id="req-123",
        ),
    )
    session.commit()

    session.delete(user)
    session.commit()
    session.expire_all()

    assert session.scalars(select(AuthSession)).all() == []
    audit = session.scalars(select(AuthAuditEvent)).one()
    assert audit.user_id is None
    assert audit.event_type == "session_created"


def test_audit_event_rejects_unknown_type(session: Session) -> None:
    session.add(AuthAuditEvent(event_type="otp_code_sent_plaintext"))

    with pytest.raises(IntegrityError):
        session.commit()


def test_audit_event_has_no_phone_or_secret_columns() -> None:
    columns = set(AuthAuditEvent.__table__.columns.keys())

    assert not {"phone", "phone_e164", "code", "code_digest", "token"} & columns


def test_repr_does_not_include_secret_digests() -> None:
    challenge = _challenge(code_digest="secret-digest-value")
    auth_session = AuthSession(
        user_id=uuid.uuid4(),
        access_token_digest="secret-access-digest",
        access_token_expires_at=_now(),
        refresh_token_digest="secret-refresh-digest",
        expires_at=_now(),
    )

    assert "secret-digest-value" not in repr(challenge)
    assert "+998" not in repr(challenge)
    assert "secret-refresh-digest" not in repr(auth_session)


def test_auth_policy_settings_have_safe_defaults() -> None:
    settings = Settings()

    assert settings.auth_otp_ttl_seconds == 300
    assert settings.auth_otp_max_attempts == 5
    assert settings.auth_otp_code_length == 6
    assert settings.auth_access_token_ttl_seconds == 900
    assert settings.auth_refresh_token_ttl_seconds == 30 * 24 * 3600
    assert settings.auth_secret_digest_key is None


def test_auth_session_stores_access_token_digest_not_plaintext(session: Session) -> None:
    user = _user()
    session.add(user)
    session.flush()
    auth_session = _auth_session(user)
    session.add(auth_session)
    session.commit()

    columns = set(AuthSession.__table__.columns.keys())
    assert "access_token_digest" in columns
    assert "access_token_expires_at" in columns
    assert "access_token" not in columns


def test_auth_secret_digest_key_is_masked(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setenv("QOSHNI_AUTH_SECRET_DIGEST_KEY", "very-secret-key-material")
    settings = Settings()

    assert settings.auth_secret_digest_key is not None
    assert "very-secret-key-material" not in repr(settings)
    assert "very-secret-key-material" not in str(settings.model_dump())


def test_auth_policy_rejects_unsafe_otp_ttl(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setenv("QOSHNI_AUTH_OTP_TTL_SECONDS", "86400")

    with pytest.raises(ValueError):
        Settings()

"""Platform role assignment model and authorization foundation."""

import uuid
from collections.abc import Generator
from datetime import UTC, datetime, timedelta

import pytest
from fastapi import Depends, FastAPI
from fastapi.testclient import TestClient
from sqlalchemy import create_engine, event, select
from sqlalchemy.engine import Engine
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session, sessionmaker

from app.api.deps.access import AuthenticationRequired
from app.api.deps.auth import get_otp_delivery_provider
from app.api.deps.reviewer import require_business_onboarding_reviewer
from app.api.schemas.business_onboarding import ONBOARDING_ENDPOINT_CONTRACTS
from app.api.schemas.business_onboarding_documents import DOCUMENT_ENDPOINT_CONTRACTS
from app.api.schemas.profile import UserProfileUpdateRequest
from app.core.config import get_settings
from app.core.database import get_db
from app.db.base import Base
from app.db.models import User
from app.db.models.business_onboarding import BusinessOnboardingApplication
from app.db.models.platform_roles import UserPlatformRoleAssignment
from app.domain.identity import AccountStatus
from app.domain.platform_roles import PlatformRole
from app.domain.reviewer_permissions import (
    BUSINESS_ONBOARDING_REVIEWER_PERMISSIONS,
    ROLE_PERMISSIONS,
)
from app.domain.role_assignments import (
    RoleAssignmentGrantSource,
    RoleAssignmentRevocationReason,
)
from app.main import create_app
from app.services.authorization.role_assignments import get_active_role_assignment
from app.services.business_onboarding.review_authorization import (
    ReviewAuthorizationError,
    assert_reviewer_not_application_owner,
)
from tests.support.fake_otp_provider import FakeOtpProvider

_DIGEST_KEY = "p" * 32


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


def _user(session: Session, phone: str = "+998901234567") -> User:
    user = User(phone_e164=phone, status=AccountStatus.ACTIVE.value)
    session.add(user)
    session.flush()
    return user


def _assignment(
    session: Session,
    user: User,
    *,
    granted_at: datetime | None = None,
    expires_at: datetime | None = None,
    revoked_at: datetime | None = None,
    revocation_reason: RoleAssignmentRevocationReason | None = None,
) -> UserPlatformRoleAssignment:
    effective_granted_at = granted_at
    if effective_granted_at is None:
        # Align grant time with revocation when tests revoke in the same instant,
        # so revoked_at is never before granted_at (DB CHECK constraint).
        effective_granted_at = revoked_at or datetime.now(UTC)
    elif revoked_at is not None and revoked_at < effective_granted_at:
        effective_granted_at = revoked_at

    row = UserPlatformRoleAssignment(
        user_id=user.id,
        role=PlatformRole.BUSINESS_ONBOARDING_REVIEWER.value,
        grant_source=RoleAssignmentGrantSource.OPERATOR_CONTROL_PLANE.value,
        grant_reference="ticket-ops-001",
        granted_at=effective_granted_at,
        expires_at=expires_at,
        revoked_at=revoked_at,
        revocation_reason=revocation_reason.value if revocation_reason else None,
    )
    session.add(row)
    session.flush()
    return row


def test_valid_reviewer_assignment_persists(session: Session) -> None:
    user = _user(session)
    row = _assignment(session, user)
    session.commit()
    assert row.role == PlatformRole.BUSINESS_ONBOARDING_REVIEWER.value
    assert row.revoked_at is None


def test_invalid_role_rejected(session: Session) -> None:
    user = _user(session)
    session.add(
        UserPlatformRoleAssignment(
            user_id=user.id,
            role="super_admin",
            grant_source=RoleAssignmentGrantSource.OPERATOR_CONTROL_PLANE.value,
        ),
    )
    with pytest.raises(IntegrityError):
        session.commit()


def test_only_one_active_assignment_per_user_and_role(session: Session) -> None:
    user = _user(session)
    _assignment(session, user)
    session.commit()
    session.add(
        UserPlatformRoleAssignment(
            user_id=user.id,
            role=PlatformRole.BUSINESS_ONBOARDING_REVIEWER.value,
            grant_source=RoleAssignmentGrantSource.OPERATOR_CONTROL_PLANE.value,
        ),
    )
    with pytest.raises(IntegrityError):
        session.commit()


def test_revoked_assignment_allows_regrant(session: Session) -> None:
    user = _user(session)
    now = datetime.now(UTC)
    first = _assignment(
        session,
        user,
        revoked_at=now,
        revocation_reason=RoleAssignmentRevocationReason.SUPERSEDED_BY_NEW_GRANT,
    )
    session.commit()
    second = UserPlatformRoleAssignment(
        user_id=user.id,
        role=PlatformRole.BUSINESS_ONBOARDING_REVIEWER.value,
        grant_source=RoleAssignmentGrantSource.OPERATOR_CONTROL_PLANE.value,
    )
    session.add(second)
    session.commit()
    assert first.revoked_at is not None
    assert second.revoked_at is None


def test_expired_assignment_not_active(session: Session) -> None:
    user = _user(session)
    now = datetime.now(UTC)
    granted = now - timedelta(hours=2)
    expired = now - timedelta(hours=1)
    _assignment(session, user, granted_at=granted, expires_at=expired)
    session.commit()
    assert (
        get_active_role_assignment(
            session,
            user_id=user.id,
            role=PlatformRole.BUSINESS_ONBOARDING_REVIEWER,
            now=datetime.now(UTC),
        )
        is None
    )


def test_revoked_assignment_not_active(session: Session) -> None:
    user = _user(session)
    _assignment(
        session,
        user,
        revoked_at=datetime.now(UTC),
        revocation_reason=RoleAssignmentRevocationReason.OPERATOR_REVOCATION,
    )
    session.commit()
    assert (
        get_active_role_assignment(
            session,
            user_id=user.id,
            role=PlatformRole.BUSINESS_ONBOARDING_REVIEWER,
            now=datetime.now(UTC),
        )
        is None
    )


def test_reviewer_permissions_are_scoped() -> None:
    perms = ROLE_PERMISSIONS[PlatformRole.BUSINESS_ONBOARDING_REVIEWER]
    assert perms == BUSINESS_ONBOARDING_REVIEWER_PERMISSIONS
    assert all(perm.value.startswith("onboarding.") for perm in perms)


def test_self_review_guard_denies_same_owner() -> None:
    user_id = uuid.uuid4()
    with pytest.raises(ReviewAuthorizationError) as exc_info:
        assert_reviewer_not_application_owner(
            reviewer_user_id=user_id,
            owner_user_id=user_id,
        )
    assert exc_info.value.code.value == "forbidden"


def test_self_review_guard_allows_different_users() -> None:
    assert_reviewer_not_application_owner(
        reviewer_user_id=uuid.uuid4(),
        owner_user_id=uuid.uuid4(),
    )


def test_profile_update_cannot_self_assign_role() -> None:
    with pytest.raises(Exception):
        UserProfileUpdateRequest(
            display_name="Ada",
            business_onboarding_reviewer=True,  # type: ignore[call-arg]
        )


@pytest.fixture
def reviewer_auth_client(
    tmp_path,
    monkeypatch: pytest.MonkeyPatch,
) -> Generator[tuple[TestClient, FakeOtpProvider, sessionmaker[Session]], None, None]:
    url = f"sqlite:///{(tmp_path / 'reviewer_auth.db').as_posix()}"
    monkeypatch.delenv("DATABASE_URL", raising=False)
    monkeypatch.setenv("QOSHNI_DATABASE_URL", url)
    monkeypatch.setenv("QOSHNI_AUTH_SECRET_DIGEST_KEY", _DIGEST_KEY)
    get_settings.cache_clear()

    engine = create_engine(url, connect_args={"check_same_thread": False})
    Base.metadata.create_all(engine)
    factory = sessionmaker(bind=engine, autoflush=False, autocommit=False)
    provider = FakeOtpProvider()

    probe_app = FastAPI()

    @probe_app.exception_handler(AuthenticationRequired)
    async def _auth_required(_request, exc: AuthenticationRequired):
        from app.api.auth_responses import auth_error_response

        return auth_error_response(exc.error)

    from app.services.authorization.errors import AuthorizationDenied

    @probe_app.exception_handler(AuthorizationDenied)
    async def _authz_denied(_request, exc: AuthorizationDenied):
        from app.api.authorization_responses import authorization_error_response

        return authorization_error_response(exc.error)

    @probe_app.get("/probe/reviewer")
    def _probe(_: object = Depends(require_business_onboarding_reviewer)) -> dict[str, str]:
        return {"ok": "true"}

    def override_db() -> Generator[Session, None, None]:
        session = factory()
        try:
            yield session
        finally:
            session.close()

    main_app = create_app()
    main_app.dependency_overrides[get_db] = override_db
    main_app.dependency_overrides[get_otp_delivery_provider] = lambda: provider
    probe_app.dependency_overrides[get_db] = override_db

    with TestClient(probe_app) as probe, TestClient(main_app) as main:
        yield probe, provider, factory, main


def _sign_in(client: TestClient, provider: FakeOtpProvider, phone: str) -> str:
    challenge = client.post("/api/v1/auth/otp/challenges", json={"phone": phone})
    assert challenge.status_code == 202, challenge.text
    challenge_id = challenge.json()["challenge_id"]
    code = provider.last_code
    assert code is not None
    verify = client.post(
        "/api/v1/auth/otp/verify",
        json={"challenge_id": challenge_id, "code": code},
    )
    assert verify.status_code == 200, verify.text
    return verify.json()["access_token"]


def test_unauthenticated_reviewer_probe_returns_401(reviewer_auth_client) -> None:
    probe, *_ = reviewer_auth_client
    response = probe.get("/probe/reviewer")
    assert response.status_code == 401
    assert response.json()["error"]["code"] == "authentication_required"


def test_authenticated_user_without_role_returns_403(reviewer_auth_client) -> None:
    probe, provider, _factory, main = reviewer_auth_client
    token = _sign_in(main, provider, "+998901111111")
    response = probe.get("/probe/reviewer", headers={"Authorization": f"Bearer {token}"})
    assert response.status_code == 403
    assert response.json()["error"]["code"] == "authorization_denied"


def test_reviewer_with_active_grant_returns_200(reviewer_auth_client) -> None:
    probe, provider, factory, main = reviewer_auth_client
    phone = "+998902222222"
    token = _sign_in(main, provider, phone)
    with factory() as session:
        user = session.scalar(select(User).where(User.phone_e164 == phone))
        assert user is not None
        _assignment(session, user)
        session.commit()
    response = probe.get("/probe/reviewer", headers={"Authorization": f"Bearer {token}"})
    assert response.status_code == 200
    assert response.json()["ok"] == "true"


def test_suspended_user_with_grant_is_not_authorized(reviewer_auth_client) -> None:
    probe, provider, factory, main = reviewer_auth_client
    phone = "+998903333333"
    token = _sign_in(main, provider, phone)
    with factory() as session:
        user = session.scalar(select(User).where(User.phone_e164 == phone))
        assert user is not None
        _assignment(session, user)
        user.status = AccountStatus.SUSPENDED.value
        session.commit()
    response = probe.get("/probe/reviewer", headers={"Authorization": f"Bearer {token}"})
    assert response.status_code == 403
    assert response.json()["error"]["code"] == "account_unavailable"


def test_expired_grant_denied(reviewer_auth_client) -> None:
    probe, provider, factory, main = reviewer_auth_client
    phone = "+998904444444"
    token = _sign_in(main, provider, phone)
    now = datetime.now(UTC)
    with factory() as session:
        user = session.scalar(select(User).where(User.phone_e164 == phone))
        assert user is not None
        _assignment(
            session,
            user,
            granted_at=now - timedelta(hours=1),
            expires_at=now - timedelta(minutes=5),
        )
        session.commit()
    response = probe.get("/probe/reviewer", headers={"Authorization": f"Bearer {token}"})
    assert response.status_code == 403
    assert response.json()["error"]["code"] == "authorization_denied"


def test_document_internal_routes_are_mounted_on_review_router() -> None:
    from app.main import create_app

    application = create_app()
    mounted_paths = set(application.openapi()["paths"].keys())
    assert any(
        "/internal/business/onboarding" in path and "/documents" in path for path in mounted_paths
    )


def test_document_content_contract_remains_unimplemented() -> None:
    internal = [c for c in DOCUMENT_ENDPOINT_CONTRACTS if "/internal/" in c.path]
    content = next(c for c in internal if c.path.endswith("/content"))
    assert content.implemented is False


def test_owner_application_still_requires_owner_scope(reviewer_auth_client) -> None:
    _probe, provider, factory, main = reviewer_auth_client
    owner_phone = "+998905555555"
    other_phone = "+998906666666"
    owner_token = _sign_in(main, provider, owner_phone)
    _sign_in(main, provider, other_phone)
    with factory() as session:
        owner = session.scalar(select(User).where(User.phone_e164 == owner_phone))
        assert owner is not None
        application = BusinessOnboardingApplication(owner_user_id=owner.id)
        session.add(application)
        session.commit()
        application_id = application.id
    denied = main.get(
        f"/api/v1/business/onboarding/applications/{application_id}",
        headers={"Authorization": f"Bearer {_sign_in(main, provider, other_phone)}"},
    )
    assert denied.status_code == 404

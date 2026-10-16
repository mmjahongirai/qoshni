"""Integration tests for privileged business onboarding review APIs."""

from __future__ import annotations

import uuid
from collections.abc import Generator
from datetime import UTC, datetime, timedelta
from pathlib import Path

import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine, func, select
from sqlalchemy.engine import Engine
from sqlalchemy.orm import Session, sessionmaker

from app.api.deps.auth import get_otp_delivery_provider
from app.core.config import get_settings
from app.core.database import get_db
from app.db.base import Base
from app.db.models.business_onboarding import (
    BusinessOnboardingApplication,
    BusinessOnboardingAuditEvent,
)
from app.db.models.identity import User
from app.db.models.platform_roles import UserPlatformRoleAssignment
from app.domain.business_onboarding import (
    OnboardingAuditActorRole,
    OnboardingAuditEventType,
    OnboardingRejectionReasonCode,
    VerificationStatus,
)
from app.domain.identity import AccountStatus
from app.domain.platform_roles import PlatformRole
from app.domain.role_assignments import RoleAssignmentGrantSource
from app.main import create_app
from tests.support.fake_otp_provider import FakeOtpProvider

_DIGEST_KEY = "p" * 32
_REVIEW_PREFIX = "/api/v1/internal/business/onboarding/applications"
_OWNER_PREFIX = "/api/v1/business/onboarding/applications"


@pytest.fixture
def review_engine(tmp_path: Path, monkeypatch: pytest.MonkeyPatch) -> Generator[Engine, None, None]:
    url = f"sqlite:///{(tmp_path / 'review_api.db').as_posix()}"
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
def review_client(
    review_engine: Engine,
) -> Generator[tuple[TestClient, FakeOtpProvider, sessionmaker[Session]], None, None]:
    provider = FakeOtpProvider()
    session_factory = sessionmaker(bind=review_engine, autoflush=False, autocommit=False)

    def override_db() -> Generator[Session, None, None]:
        session = session_factory()
        try:
            yield session
        finally:
            session.close()

    application = create_app()
    application.dependency_overrides[get_db] = override_db
    application.dependency_overrides[get_otp_delivery_provider] = lambda: provider

    with TestClient(application) as client:
        yield client, provider, session_factory


def _sign_in(client: TestClient, provider: FakeOtpProvider, phone: str) -> str:
    challenge = client.post("/api/v1/auth/otp/challenges", json={"phone": phone})
    assert challenge.status_code == 202, challenge.text
    verify = client.post(
        "/api/v1/auth/otp/verify",
        json={"challenge_id": challenge.json()["challenge_id"], "code": provider.last_code},
    )
    assert verify.status_code == 200, verify.text
    return verify.json()["access_token"]


def _auth(token: str) -> dict[str, str]:
    return {"Authorization": f"Bearer {token}"}


def _grant_reviewer(session: Session, user_id: uuid.UUID) -> None:
    session.add(
        UserPlatformRoleAssignment(
            user_id=user_id,
            role=PlatformRole.BUSINESS_ONBOARDING_REVIEWER.value,
            grant_source=RoleAssignmentGrantSource.OPERATOR_CONTROL_PLANE.value,
        ),
    )
    session.commit()


def _submitted_application(
    session: Session,
    owner: User,
    *,
    registration_identifier: str = "REG-100",
) -> BusinessOnboardingApplication:
    application = BusinessOnboardingApplication(
        owner_user_id=owner.id,
        legal_business_name="Acme LLC",
        service_category="shops",
        registration_jurisdiction="UZ",
        registration_identifier=registration_identifier,
        verification_status=VerificationStatus.SUBMITTED.value,
        submitted_at=datetime.now(UTC),
    )
    session.add(application)
    session.commit()
    session.refresh(application)
    return application


def _user(session: Session, phone: str) -> User:
    user = User(phone_e164=phone, status=AccountStatus.ACTIVE.value)
    session.add(user)
    session.flush()
    return user


@pytest.mark.parametrize(
    "endpoint_suffix",
    [
        "begin-review",
        "verify",
        "suspend",
        "reinstate",
    ],
)
def test_reviewer_decision_post_accepts_empty_json_object(
    review_client,
    endpoint_suffix: str,
) -> None:
    """Empty JSON object is the documented request body for decision POSTs."""
    client, provider, factory = review_client
    reviewer_phone = "+998900000020"
    owner_phone = "+998900000021"
    reviewer_token = _sign_in(client, provider, reviewer_phone)
    _sign_in(client, provider, owner_phone)
    with factory() as session:
        reviewer = session.scalar(select(User).where(User.phone_e164 == reviewer_phone))
        owner = session.scalar(select(User).where(User.phone_e164 == owner_phone))
        assert reviewer and owner
        _grant_reviewer(session, reviewer.id)
        application = _submitted_application(session, owner)
        application_id = application.id

    headers = _auth(reviewer_token)
    path = f"{_REVIEW_PREFIX}/{application_id}/{endpoint_suffix}"
    response = client.post(path, json={}, headers=headers)
    assert response.status_code != 422, response.text


def test_reviewer_decision_post_without_body_is_unprocessable(review_client) -> None:
    """Missing JSON body is rejected (same FastAPI rule as owner submit)."""
    client, provider, factory = review_client
    reviewer_phone = "+998900000022"
    owner_phone = "+998900000023"
    reviewer_token = _sign_in(client, provider, reviewer_phone)
    _sign_in(client, provider, owner_phone)
    with factory() as session:
        reviewer = session.scalar(select(User).where(User.phone_e164 == reviewer_phone))
        owner = session.scalar(select(User).where(User.phone_e164 == owner_phone))
        assert reviewer and owner
        _grant_reviewer(session, reviewer.id)
        application = _submitted_application(session, owner)
        application_id = application.id

    response = client.post(
        f"{_REVIEW_PREFIX}/{application_id}/begin-review",
        headers=_auth(reviewer_token),
    )
    assert response.status_code == 422


def test_reviewer_queue_requires_authentication(review_client) -> None:
    client, _, _ = review_client
    assert client.get(f"{_REVIEW_PREFIX}").status_code == 401


def test_reviewer_queue_forbidden_without_role(review_client) -> None:
    client, provider, _ = review_client
    token = _sign_in(client, provider, "+998911111111")
    assert client.get(f"{_REVIEW_PREFIX}", headers=_auth(token)).status_code == 403


def test_reviewer_http_response_excludes_private_metadata(review_client) -> None:
    client, provider, factory = review_client
    reviewer_phone = "+998900000024"
    owner_phone = "+998900000025"
    reviewer_token = _sign_in(client, provider, reviewer_phone)
    _sign_in(client, provider, owner_phone)
    with factory() as session:
        reviewer = session.scalar(select(User).where(User.phone_e164 == reviewer_phone))
        owner = session.scalar(select(User).where(User.phone_e164 == owner_phone))
        assert reviewer and owner
        _grant_reviewer(session, reviewer.id)
        _submitted_application(session, owner)

    listed = client.get(f"{_REVIEW_PREFIX}", headers=_auth(reviewer_token))
    assert listed.status_code == 200
    application_payload = listed.json()["applications"][0]
    forbidden = {
        "owner_user_id",
        "storage_object_key",
        "checksum_sha256",
        "actor_role",
        "actor_user_id",
        "internal_note",
    }
    assert forbidden.isdisjoint(application_payload.keys())


def test_reviewer_queue_lists_submitted_application(review_client) -> None:
    client, provider, factory = review_client
    reviewer_phone = "+998922222222"
    owner_phone = "+998933333333"
    reviewer_token = _sign_in(client, provider, reviewer_phone)
    _sign_in(client, provider, owner_phone)
    with factory() as session:
        reviewer = session.scalar(select(User).where(User.phone_e164 == reviewer_phone))
        owner = session.scalar(select(User).where(User.phone_e164 == owner_phone))
        assert reviewer and owner
        _grant_reviewer(session, reviewer.id)
        _submitted_application(session, owner)
    listed = client.get(f"{_REVIEW_PREFIX}", headers=_auth(reviewer_token))
    assert listed.status_code == 200
    assert len(listed.json()["applications"]) == 1


def test_full_review_workflow(review_client) -> None:
    client, provider, factory = review_client
    reviewer_phone = "+998944444444"
    owner_phone = "+998955555555"
    reviewer_token = _sign_in(client, provider, reviewer_phone)
    _sign_in(client, provider, owner_phone)
    with factory() as session:
        reviewer = session.scalar(select(User).where(User.phone_e164 == reviewer_phone))
        owner = session.scalar(select(User).where(User.phone_e164 == owner_phone))
        assert reviewer and owner
        _grant_reviewer(session, reviewer.id)
        application = _submitted_application(session, owner)
        application_id = application.id

    headers = _auth(reviewer_token)
    began = client.post(f"{_REVIEW_PREFIX}/{application_id}/begin-review", json={}, headers=headers)
    assert began.status_code == 200
    assert began.json()["verification_status"] == VerificationStatus.UNDER_REVIEW.value

    verified = client.post(f"{_REVIEW_PREFIX}/{application_id}/verify", json={}, headers=headers)
    assert verified.status_code == 200
    assert verified.json()["verification_status"] == VerificationStatus.VERIFIED.value

    suspended = client.post(f"{_REVIEW_PREFIX}/{application_id}/suspend", json={}, headers=headers)
    assert suspended.status_code == 200
    assert suspended.json()["verification_status"] == VerificationStatus.SUSPENDED.value

    reinstated = client.post(
        f"{_REVIEW_PREFIX}/{application_id}/reinstate",
        json={},
        headers=headers,
    )
    assert reinstated.status_code == 200
    assert reinstated.json()["verification_status"] == VerificationStatus.UNDER_REVIEW.value

    with factory() as session:
        audit_count = session.scalar(
            select(func.count())
            .select_from(BusinessOnboardingAuditEvent)
            .where(
                BusinessOnboardingAuditEvent.application_id == application_id,
                BusinessOnboardingAuditEvent.event_type == OnboardingAuditEventType.STATUS_CHANGED.value,
                BusinessOnboardingAuditEvent.actor_role == OnboardingAuditActorRole.REVIEWER.value,
            ),
        )
        assert audit_count == 4


def test_reviewer_routes_reject_internal_note_in_body(review_client) -> None:
    client, provider, factory = review_client
    reviewer_phone = "+998966660001"
    owner_phone = "+998966660002"
    reviewer_token = _sign_in(client, provider, reviewer_phone)
    _sign_in(client, provider, owner_phone)
    with factory() as session:
        reviewer = session.scalar(select(User).where(User.phone_e164 == reviewer_phone))
        owner = session.scalar(select(User).where(User.phone_e164 == owner_phone))
        assert reviewer and owner
        _grant_reviewer(session, reviewer.id)
        application = _submitted_application(session, owner)
        application_id = application.id

    headers = _auth(reviewer_token)
    assert (
        client.post(
            f"{_REVIEW_PREFIX}/{application_id}/begin-review",
            json={"internal_note": "should fail"},
            headers=headers,
        ).status_code
        == 422
    )
    assert (
        client.post(
            f"{_REVIEW_PREFIX}/{application_id}/reject",
            json={
                "rejection_reason_code": OnboardingRejectionReasonCode.OTHER.value,
                "internal_note": "should fail",
            },
            headers=headers,
        ).status_code
        == 422
    )


def test_reject_with_controlled_reason(review_client) -> None:
    client, provider, factory = review_client
    reviewer_phone = "+998966666666"
    owner_phone = "+998977777777"
    reviewer_token = _sign_in(client, provider, reviewer_phone)
    _sign_in(client, provider, owner_phone)
    with factory() as session:
        reviewer = session.scalar(select(User).where(User.phone_e164 == reviewer_phone))
        owner = session.scalar(select(User).where(User.phone_e164 == owner_phone))
        assert reviewer and owner
        _grant_reviewer(session, reviewer.id)
        application = _submitted_application(session, owner)
        application_id = application.id
        client.post(
            f"{_REVIEW_PREFIX}/{application_id}/begin-review",
            json={},
            headers=_auth(reviewer_token),
        )

    rejected = client.post(
        f"{_REVIEW_PREFIX}/{application_id}/reject",
        json={"rejection_reason_code": OnboardingRejectionReasonCode.POLICY_VIOLATION.value},
        headers=_auth(reviewer_token),
    )
    assert rejected.status_code == 200
    assert rejected.json()["rejection_reason_code"] == OnboardingRejectionReasonCode.POLICY_VIOLATION.value


def test_self_review_forbidden(review_client) -> None:
    client, provider, factory = review_client
    phone = "+998988888888"
    token = _sign_in(client, provider, phone)
    with factory() as session:
        user = session.scalar(select(User).where(User.phone_e164 == phone))
        assert user
        _grant_reviewer(session, user.id)
        application = _submitted_application(session, user)
        application_id = application.id

    response = client.post(
        f"{_REVIEW_PREFIX}/{application_id}/begin-review",
        json={},
        headers=_auth(token),
    )
    assert response.status_code == 403
    assert response.json()["error"]["code"] == "forbidden"


def test_invalid_transition_returns_conflict(review_client) -> None:
    client, provider, factory = review_client
    reviewer_phone = "+998999999999"
    owner_phone = "+998900000001"
    reviewer_token = _sign_in(client, provider, reviewer_phone)
    _sign_in(client, provider, owner_phone)
    with factory() as session:
        reviewer = session.scalar(select(User).where(User.phone_e164 == reviewer_phone))
        owner = session.scalar(select(User).where(User.phone_e164 == owner_phone))
        assert reviewer and owner
        _grant_reviewer(session, reviewer.id)
        application = _submitted_application(session, owner)
        application_id = application.id

    verify = client.post(
        f"{_REVIEW_PREFIX}/{application_id}/verify",
        json={},
        headers=_auth(reviewer_token),
    )
    assert verify.status_code == 409


def test_reject_idempotent_same_reason_no_duplicate_audit(review_client) -> None:
    client, provider, factory = review_client
    reviewer_phone = "+998900000011"
    owner_phone = "+998900000012"
    reviewer_token = _sign_in(client, provider, reviewer_phone)
    _sign_in(client, provider, owner_phone)
    with factory() as session:
        reviewer = session.scalar(select(User).where(User.phone_e164 == reviewer_phone))
        owner = session.scalar(select(User).where(User.phone_e164 == owner_phone))
        assert reviewer and owner
        _grant_reviewer(session, reviewer.id)
        application = _submitted_application(session, owner)
        application_id = application.id

    headers = _auth(reviewer_token)
    client.post(f"{_REVIEW_PREFIX}/{application_id}/begin-review", json={}, headers=headers)
    body = {
        "rejection_reason_code": OnboardingRejectionReasonCode.INCOMPLETE_INFORMATION.value,
    }
    assert (
        client.post(f"{_REVIEW_PREFIX}/{application_id}/reject", json=body, headers=headers).status_code
        == 200
    )
    assert (
        client.post(f"{_REVIEW_PREFIX}/{application_id}/reject", json=body, headers=headers).status_code
        == 200
    )
    with factory() as session:
        count = session.scalar(
            select(func.count())
            .select_from(BusinessOnboardingAuditEvent)
            .where(
                BusinessOnboardingAuditEvent.application_id == application_id,
                BusinessOnboardingAuditEvent.to_status == VerificationStatus.REJECTED.value,
            ),
        )
        assert count == 1


def test_reject_different_reason_after_rejected_returns_conflict(review_client) -> None:
    client, provider, factory = review_client
    reviewer_phone = "+998900000013"
    owner_phone = "+998900000014"
    reviewer_token = _sign_in(client, provider, reviewer_phone)
    _sign_in(client, provider, owner_phone)
    with factory() as session:
        reviewer = session.scalar(select(User).where(User.phone_e164 == reviewer_phone))
        owner = session.scalar(select(User).where(User.phone_e164 == owner_phone))
        assert reviewer and owner
        _grant_reviewer(session, reviewer.id)
        application = _submitted_application(session, owner)
        application_id = application.id

    headers = _auth(reviewer_token)
    client.post(f"{_REVIEW_PREFIX}/{application_id}/begin-review", json={}, headers=headers)
    client.post(
        f"{_REVIEW_PREFIX}/{application_id}/reject",
        json={"rejection_reason_code": OnboardingRejectionReasonCode.OTHER.value},
        headers=headers,
    )
    conflict = client.post(
        f"{_REVIEW_PREFIX}/{application_id}/reject",
        json={"rejection_reason_code": OnboardingRejectionReasonCode.POLICY_VIOLATION.value},
        headers=headers,
    )
    assert conflict.status_code == 409
    assert conflict.json()["error"]["code"] == "invalid_status_transition"
    with factory() as session:
        row = session.get(BusinessOnboardingApplication, application_id)
        assert row is not None
        assert row.rejection_reason_code == OnboardingRejectionReasonCode.OTHER.value


def test_idempotent_begin_review_does_not_duplicate_audit(review_client) -> None:
    client, provider, factory = review_client
    reviewer_phone = "+998900000002"
    owner_phone = "+998900000003"
    reviewer_token = _sign_in(client, provider, reviewer_phone)
    _sign_in(client, provider, owner_phone)
    with factory() as session:
        reviewer = session.scalar(select(User).where(User.phone_e164 == reviewer_phone))
        owner = session.scalar(select(User).where(User.phone_e164 == owner_phone))
        assert reviewer and owner
        _grant_reviewer(session, reviewer.id)
        application = _submitted_application(session, owner)
        application_id = application.id

    headers = _auth(reviewer_token)
    assert client.post(f"{_REVIEW_PREFIX}/{application_id}/begin-review", json={}, headers=headers).status_code == 200
    assert client.post(f"{_REVIEW_PREFIX}/{application_id}/begin-review", json={}, headers=headers).status_code == 200

    with factory() as session:
        count = session.scalar(
            select(func.count())
            .select_from(BusinessOnboardingAuditEvent)
            .where(
                BusinessOnboardingAuditEvent.application_id == application_id,
                BusinessOnboardingAuditEvent.to_status == VerificationStatus.UNDER_REVIEW.value,
            ),
        )
        assert count == 1


def test_expired_reviewer_grant_denied(review_client) -> None:
    client, provider, factory = review_client
    reviewer_phone = "+998900000004"
    token = _sign_in(client, provider, reviewer_phone)
    now = datetime.now(UTC)
    with factory() as session:
        user = session.scalar(select(User).where(User.phone_e164 == reviewer_phone))
        assert user
        session.add(
            UserPlatformRoleAssignment(
                user_id=user.id,
                role=PlatformRole.BUSINESS_ONBOARDING_REVIEWER.value,
                grant_source=RoleAssignmentGrantSource.OPERATOR_CONTROL_PLANE.value,
                granted_at=now - timedelta(hours=2),
                expires_at=now - timedelta(minutes=1),
            ),
        )
        session.commit()
    assert client.get(f"{_REVIEW_PREFIX}", headers=_auth(token)).status_code == 403


def test_owner_routes_still_owner_scoped(review_client) -> None:
    client, provider, factory = review_client
    owner_phone = "+998900000005"
    other_phone = "+998900000006"
    owner_token = _sign_in(client, provider, owner_phone)
    _sign_in(client, provider, other_phone)
    with factory() as session:
        owner = session.scalar(select(User).where(User.phone_e164 == owner_phone))
        assert owner
        application = _submitted_application(session, owner)
        application_id = application.id
    other_token = _sign_in(client, provider, other_phone)
    denied = client.get(
        f"{_OWNER_PREFIX}/{application_id}",
        headers=_auth(other_token),
    )
    assert denied.status_code == 404


def test_failed_transition_rolls_back_status(review_client, monkeypatch: pytest.MonkeyPatch) -> None:
    client, provider, factory = review_client
    reviewer_phone = "+998900000009"
    owner_phone = "+998900000010"
    reviewer_token = _sign_in(client, provider, reviewer_phone)
    _sign_in(client, provider, owner_phone)
    with factory() as session:
        reviewer = session.scalar(select(User).where(User.phone_e164 == reviewer_phone))
        owner = session.scalar(select(User).where(User.phone_e164 == owner_phone))
        assert reviewer and owner
        _grant_reviewer(session, reviewer.id)
        application = _submitted_application(session, owner)
        application_id = application.id

    def _fail_audit(*_args, **_kwargs) -> None:
        raise RuntimeError("audit write failed")

    monkeypatch.setattr(
        "app.services.business_onboarding.review_service._record_audit",
        _fail_audit,
    )
    with pytest.raises(RuntimeError):
        client.post(
            f"{_REVIEW_PREFIX}/{application_id}/begin-review",
            json={},
            headers=_auth(reviewer_token),
        )
    with factory() as session:
        row = session.get(BusinessOnboardingApplication, application_id)
        assert row is not None
        assert row.verification_status == VerificationStatus.SUBMITTED.value
        assert (
            session.scalar(
                select(func.count()).select_from(BusinessOnboardingAuditEvent).where(
                    BusinessOnboardingAuditEvent.application_id == application_id,
                ),
            )
            == 0
        )


def test_reviewer_detail_hides_draft_applications(review_client) -> None:
    client, provider, factory = review_client
    reviewer_phone = "+998900000007"
    owner_phone = "+998900000008"
    reviewer_token = _sign_in(client, provider, reviewer_phone)
    _sign_in(client, provider, owner_phone)
    with factory() as session:
        reviewer = session.scalar(select(User).where(User.phone_e164 == reviewer_phone))
        owner = session.scalar(select(User).where(User.phone_e164 == owner_phone))
        assert reviewer and owner
        _grant_reviewer(session, reviewer.id)
        draft = BusinessOnboardingApplication(owner_user_id=owner.id)
        session.add(draft)
        session.commit()
        draft_id = draft.id

    assert (
        client.get(
            f"{_REVIEW_PREFIX}/{draft_id}",
            headers=_auth(reviewer_token),
        ).status_code
        == 404
    )

"""Integration tests for owner business onboarding APIs."""

from __future__ import annotations

import uuid
from collections.abc import Generator
from datetime import UTC, datetime
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
from app.domain.business_onboarding import (
    OnboardingAuditEventType,
    VerificationStatus,
)
from app.main import create_app
from tests.support.fake_otp_provider import FakeOtpProvider

_DIGEST_KEY = "p" * 32
_PREFIX = "/api/v1/business/onboarding/applications"


@pytest.fixture
def onboarding_engine(tmp_path: Path, monkeypatch: pytest.MonkeyPatch) -> Generator[Engine, None, None]:
    url = f"sqlite:///{(tmp_path / 'onboarding_api.db').as_posix()}"
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
def onboarding_client(
    onboarding_engine: Engine,
) -> Generator[tuple[TestClient, FakeOtpProvider], None, None]:
    provider = FakeOtpProvider()
    session_factory = sessionmaker(bind=onboarding_engine, autoflush=False, autocommit=False)

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
        yield client, provider

    application.dependency_overrides.clear()


def _sign_in(client: TestClient, provider: FakeOtpProvider, phone: str = "+998901234567") -> dict:
    challenge = client.post("/api/v1/auth/otp/challenges", json={"phone": phone})
    assert challenge.status_code == 202, challenge.text
    verify = client.post(
        "/api/v1/auth/otp/verify",
        json={
            "challenge_id": challenge.json()["challenge_id"],
            "code": provider.last_code,
        },
    )
    assert verify.status_code == 200, verify.text
    return verify.json()


def _auth_headers(tokens: dict) -> dict[str, str]:
    return {"Authorization": f"Bearer {tokens['access_token']}"}


def test_create_list_and_get_owner_application(
    onboarding_client: tuple[TestClient, FakeOtpProvider],
) -> None:
    client, provider = onboarding_client
    tokens = _sign_in(client, provider)
    headers = _auth_headers(tokens)

    created = client.post(
        _PREFIX,
        headers=headers,
        json={"legal_business_name": "Alpha LLC", "service_category": "shops"},
    )
    assert created.status_code == 201, created.text
    body = created.json()
    assert body["verification_status"] == "draft"
    assert body["legal_business_name"] == "Alpha LLC"
    assert "owner_user_id" not in body
    application_id = body["application_id"]

    listed = client.get(_PREFIX, headers=headers)
    assert listed.status_code == 200
    assert len(listed.json()["applications"]) == 1

    fetched = client.get(f"{_PREFIX}/{application_id}", headers=headers)
    assert fetched.status_code == 200
    assert fetched.json()["application_id"] == application_id


def test_cross_owner_access_returns_not_found(
    onboarding_client: tuple[TestClient, FakeOtpProvider],
) -> None:
    client, provider = onboarding_client
    owner_a = _sign_in(client, provider, phone="+998901111111")
    owner_b = _sign_in(client, provider, phone="+998902222222")

    created = client.post(
        _PREFIX,
        headers=_auth_headers(owner_a),
        json={"legal_business_name": "Private LLC"},
    )
    application_id = created.json()["application_id"]

    denied = client.get(
        f"{_PREFIX}/{application_id}",
        headers=_auth_headers(owner_b),
    )
    assert denied.status_code == 404
    assert denied.json()["error"]["code"] == "application_not_found"


def test_draft_patch_and_submit_with_single_submit_audit(
    onboarding_client: tuple[TestClient, FakeOtpProvider],
    onboarding_engine: Engine,
) -> None:
    client, provider = onboarding_client
    tokens = _sign_in(client, provider)
    headers = _auth_headers(tokens)

    created = client.post(_PREFIX, headers=headers, json={})
    application_id = created.json()["application_id"]

    patched = client.patch(
        f"{_PREFIX}/{application_id}",
        headers=headers,
        json={
            "legal_business_name": "Beta LLC",
            "service_category": "pharmacy",
            "registration_identifier": "REG-100",
        },
    )
    assert patched.status_code == 200

    submitted = client.post(
        f"{_PREFIX}/{application_id}/submit",
        headers=headers,
        json={},
    )
    assert submitted.status_code == 200
    assert submitted.json()["verification_status"] == "submitted"
    assert submitted.json()["submitted_at"] is not None

    retry = client.post(
        f"{_PREFIX}/{application_id}/submit",
        headers=headers,
        json={},
    )
    assert retry.status_code == 200
    assert retry.json()["verification_status"] == "submitted"

    with Session(onboarding_engine) as session:
        submit_events = session.scalar(
            select(func.count())
            .select_from(BusinessOnboardingAuditEvent)
            .where(
                BusinessOnboardingAuditEvent.application_id == uuid.UUID(application_id),
                BusinessOnboardingAuditEvent.event_type == OnboardingAuditEventType.SUBMITTED.value,
            ),
        )
        assert submit_events == 1


def test_submit_requires_legal_name_and_category(
    onboarding_client: tuple[TestClient, FakeOtpProvider],
) -> None:
    client, provider = onboarding_client
    headers = _auth_headers(_sign_in(client, provider))

    application_id = client.post(_PREFIX, headers=headers, json={}).json()["application_id"]
    response = client.post(f"{_PREFIX}/{application_id}/submit", headers=headers, json={})
    assert response.status_code == 422
    assert response.json()["error"]["code"] == "validation_failed"


def test_patch_rejects_status_injection_via_extra_fields(
    onboarding_client: tuple[TestClient, FakeOtpProvider],
) -> None:
    client, provider = onboarding_client
    headers = _auth_headers(_sign_in(client, provider))
    application_id = client.post(_PREFIX, headers=headers, json={}).json()["application_id"]

    response = client.patch(
        f"{_PREFIX}/{application_id}",
        headers=headers,
        json={"verification_status": "verified"},
    )
    assert response.status_code == 422


def test_submitted_application_cannot_be_edited(
    onboarding_client: tuple[TestClient, FakeOtpProvider],
) -> None:
    client, provider = onboarding_client
    headers = _auth_headers(_sign_in(client, provider))
    application_id = client.post(_PREFIX, headers=headers, json={}).json()["application_id"]
    client.patch(
        f"{_PREFIX}/{application_id}",
        headers=headers,
        json={"legal_business_name": "Gamma LLC", "service_category": "rent"},
    )
    client.post(f"{_PREFIX}/{application_id}/submit", headers=headers, json={})

    edit = client.patch(
        f"{_PREFIX}/{application_id}",
        headers=headers,
        json={"legal_business_name": "Changed LLC"},
    )
    assert edit.status_code == 409
    assert edit.json()["error"]["code"] == "invalid_status_transition"


def test_duplicate_registration_identifier_blocks_submit(
    onboarding_client: tuple[TestClient, FakeOtpProvider],
) -> None:
    client, provider = onboarding_client
    headers_a = _auth_headers(_sign_in(client, provider, phone="+998903333333"))
    app_a = client.post(_PREFIX, headers=headers_a, json={}).json()["application_id"]
    client.patch(
        f"{_PREFIX}/{app_a}",
        headers=headers_a,
        json={
            "legal_business_name": "First LLC",
            "service_category": "shops",
            "registration_identifier": "DUP-1",
        },
    )
    assert client.post(f"{_PREFIX}/{app_a}/submit", headers=headers_a, json={}).status_code == 200

    headers_b = _auth_headers(_sign_in(client, provider, phone="+998904444444"))
    app_b = client.post(_PREFIX, headers=headers_b, json={}).json()["application_id"]
    client.patch(
        f"{_PREFIX}/{app_b}",
        headers=headers_b,
        json={
            "legal_business_name": "Second LLC",
            "service_category": "shops",
            "registration_identifier": "DUP-1",
        },
    )
    blocked = client.post(f"{_PREFIX}/{app_b}/submit", headers=headers_b, json={})
    assert blocked.status_code == 422
    assert blocked.json()["error"]["code"] == "validation_failed"
    assert "owner" not in blocked.text.lower()


def test_verification_status_endpoint(
    onboarding_client: tuple[TestClient, FakeOtpProvider],
) -> None:
    client, provider = onboarding_client
    headers = _auth_headers(_sign_in(client, provider))
    application_id = client.post(_PREFIX, headers=headers, json={}).json()["application_id"]

    status = client.get(
        f"{_PREFIX}/{application_id}/verification-status",
        headers=headers,
    )
    assert status.status_code == 200
    payload = status.json()
    assert payload["verification_status"] == "draft"
    assert "tax_identifier" not in payload


def test_routes_require_authentication(onboarding_client: tuple[TestClient, FakeOtpProvider]) -> None:
    client, _ = onboarding_client
    assert client.get(_PREFIX).status_code == 401
    random_id = "11111111-1111-1111-1111-111111111111"
    assert client.get(f"{_PREFIX}/{random_id}").status_code == 401


def test_manual_verified_row_cannot_be_self_edited_to_verified_via_api(
    onboarding_client: tuple[TestClient, FakeOtpProvider],
    onboarding_engine: Engine,
) -> None:
    client, provider = onboarding_client
    tokens = _sign_in(client, provider)
    headers = _auth_headers(tokens)
    application_id = client.post(_PREFIX, headers=headers, json={}).json()["application_id"]

    with Session(onboarding_engine) as session:
        row = session.get(BusinessOnboardingApplication, uuid.UUID(application_id))
        assert row is not None
        row.verification_status = VerificationStatus.VERIFIED.value
        row.submitted_at = datetime.now(UTC)
        session.commit()

    patch = client.patch(
        f"{_PREFIX}/{application_id}",
        headers=headers,
        json={"legal_business_name": "Hacker LLC"},
    )
    assert patch.status_code == 409

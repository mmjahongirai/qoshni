"""End-to-end owner onboarding via HTTP, then privileged reviewer verify and download."""

from __future__ import annotations

import uuid
from collections.abc import Generator
from pathlib import Path

import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine, select
from sqlalchemy.engine import Engine
from sqlalchemy.orm import Session, sessionmaker

from app.api.deps.auth import get_otp_delivery_provider
from app.api.deps.malware_scanner import get_malware_scanner
from app.api.deps.object_storage import get_object_storage
from app.core.config import get_settings
from app.core.database import get_db
from app.db.base import Base
from app.db.models.identity import User
from app.db.models.platform_roles import UserPlatformRoleAssignment
from app.domain.business_onboarding import VerificationStatus
from app.domain.malware_scanning import MalwareScanVerdict
from app.domain.platform_roles import PlatformRole
from app.domain.role_assignments import RoleAssignmentGrantSource
from app.main import create_app
from app.services.business_onboarding.document_service import build_storage_object_key
from app.services.malware_scanning.fake import FakeMalwareScanner
from tests.support.fake_otp_provider import FakeOtpProvider
from tests.support.memory_object_storage import MemoryObjectStorage

_DIGEST_KEY = "p" * 32
_OWNER_PREFIX = "/api/v1/business/onboarding/applications"
_REVIEW_PREFIX = "/api/v1/internal/business/onboarding/applications"
_MINIMAL_PDF = b"%PDF-1.4\n1 0 obj\n<<>>\nendobj\ntrail\n%%EOF"


@pytest.fixture
def e2e_engine(tmp_path: Path, monkeypatch: pytest.MonkeyPatch) -> Generator[Engine, None, None]:
    url = f"sqlite:///{(tmp_path / 'onboarding_e2e.db').as_posix()}"
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
def e2e_client(
    e2e_engine: Engine,
) -> Generator[
    tuple[TestClient, FakeOtpProvider, MemoryObjectStorage, sessionmaker[Session]],
    None,
    None,
]:
    provider = FakeOtpProvider()
    storage = MemoryObjectStorage()
    scanner = FakeMalwareScanner(verdict=MalwareScanVerdict.CLEAN)
    session_factory = sessionmaker(bind=e2e_engine, autoflush=False, autocommit=False)

    def override_db() -> Generator[Session, None, None]:
        session = session_factory()
        try:
            yield session
        finally:
            session.close()

    application = create_app()
    application.dependency_overrides[get_db] = override_db
    application.dependency_overrides[get_otp_delivery_provider] = lambda: provider
    application.dependency_overrides[get_object_storage] = lambda: storage
    application.dependency_overrides[get_malware_scanner] = lambda: scanner

    with TestClient(application) as client:
        yield client, provider, storage, session_factory

    application.dependency_overrides.clear()


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


def test_owner_api_pipeline_then_reviewer_verify_and_download(e2e_client) -> None:
    client, provider, storage, factory = e2e_client
    owner_phone = "+998977770001"
    reviewer_phone = "+998977770002"
    owner_token = _sign_in(client, provider, owner_phone)
    reviewer_token = _sign_in(client, provider, reviewer_phone)
    owner_headers = _auth(owner_token)

    created = client.post(
        _OWNER_PREFIX,
        headers=owner_headers,
        json={"registration_jurisdiction": "UZ"},
    )
    assert created.status_code == 201, created.text
    application_id = created.json()["application_id"]
    assert "owner_user_id" not in created.text
    assert "storage_object_key" not in created.text

    patched = client.patch(
        f"{_OWNER_PREFIX}/{application_id}",
        headers=owner_headers,
        json={
            "legal_business_name": "E2E Pipeline LLC",
            "service_category": "shops",
            "registration_identifier": f"REG-E2E-{uuid.uuid4().hex[:8]}",
        },
    )
    assert patched.status_code == 200, patched.text

    listed = client.get(_OWNER_PREFIX, headers=owner_headers)
    assert listed.status_code == 200
    assert any(a["application_id"] == application_id for a in listed.json()["applications"])

    detail = client.get(f"{_OWNER_PREFIX}/{application_id}", headers=owner_headers)
    assert detail.status_code == 200
    assert detail.json()["legal_business_name"] == "E2E Pipeline LLC"

    registered = client.post(
        f"{_OWNER_PREFIX}/{application_id}/documents",
        headers=owner_headers,
        json={"document_type": "registration_certificate"},
    )
    assert registered.status_code == 201, registered.text
    document_id = registered.json()["document_id"]
    assert registered.json()["lifecycle_state"] == "awaiting_upload"

    uploaded = client.post(
        f"{_OWNER_PREFIX}/{application_id}/documents/{document_id}/upload",
        headers=owner_headers,
        files={"file": ("cert.pdf", _MINIMAL_PDF, "application/pdf")},
    )
    assert uploaded.status_code == 200, uploaded.text
    key = build_storage_object_key(uuid.UUID(application_id), uuid.UUID(document_id))
    assert storage.read(key) == _MINIMAL_PDF

    submitted = client.post(
        f"{_OWNER_PREFIX}/{application_id}/submit",
        headers=owner_headers,
        json={},
    )
    assert submitted.status_code == 200, submitted.text
    assert submitted.json()["verification_status"] == VerificationStatus.SUBMITTED.value

    status = client.get(
        f"{_OWNER_PREFIX}/{application_id}/verification-status",
        headers=owner_headers,
    )
    assert status.status_code == 200
    assert status.json()["verification_status"] == VerificationStatus.SUBMITTED.value

    with factory() as session:
        reviewer = session.scalar(select(User).where(User.phone_e164 == reviewer_phone))
        assert reviewer is not None
        _grant_reviewer(session, reviewer.id)

    review_headers = _auth(reviewer_token)
    began = client.post(
        f"{_REVIEW_PREFIX}/{application_id}/begin-review",
        json={},
        headers=review_headers,
    )
    assert began.status_code == 200, began.text
    assert began.json()["verification_status"] == VerificationStatus.UNDER_REVIEW.value

    verified = client.post(
        f"{_REVIEW_PREFIX}/{application_id}/verify",
        json={},
        headers=review_headers,
    )
    assert verified.status_code == 200, verified.text
    assert verified.json()["verification_status"] == VerificationStatus.VERIFIED.value

    doc_list = client.get(
        f"{_REVIEW_PREFIX}/{application_id}/documents",
        headers=review_headers,
    )
    assert doc_list.status_code == 200
    assert len(doc_list.json()["documents"]) == 1
    assert "checksum_sha256" not in doc_list.text

    download = client.get(
        f"{_REVIEW_PREFIX}/{application_id}/documents/{document_id}/download",
        headers=review_headers,
    )
    assert download.status_code == 200, download.text
    assert download.content == _MINIMAL_PDF

    owner_after = client.get(f"{_OWNER_PREFIX}/{application_id}", headers=owner_headers)
    assert owner_after.status_code == 200
    assert owner_after.json()["verification_status"] == VerificationStatus.VERIFIED.value

    owner_status = client.get(
        f"{_OWNER_PREFIX}/{application_id}/verification-status",
        headers=owner_headers,
    )
    assert owner_status.json()["verification_status"] == VerificationStatus.VERIFIED.value


def test_owner_cannot_call_reviewer_routes(e2e_client) -> None:
    client, provider, _storage, factory = e2e_client
    owner_token = _sign_in(client, provider, "+998977770003")
    owner_headers = _auth(owner_token)
    application_id = client.post(_OWNER_PREFIX, headers=owner_headers, json={}).json()[
        "application_id"
    ]
    with factory() as session:
        owner = session.scalar(select(User).where(User.phone_e164 == "+998977770003"))
        assert owner is not None
        _grant_reviewer(session, owner.id)

    denied = client.post(
        f"{_REVIEW_PREFIX}/{application_id}/begin-review",
        json={},
        headers=owner_headers,
    )
    assert denied.status_code == 403
    assert denied.json()["error"]["code"] == "forbidden"

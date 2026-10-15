"""Integration tests for owner onboarding document APIs."""

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
from app.api.deps.object_storage import get_object_storage
from app.api.schemas.business_onboarding_documents import DOCUMENT_ENDPOINT_CONTRACTS
from app.core.config import get_settings
from app.core.database import get_db
from app.db.base import Base
from app.db.models.business_onboarding import (
    BusinessOnboardingApplication,
    BusinessOnboardingAuditEvent,
    BusinessOnboardingDocument,
)
from app.domain.business_onboarding import VerificationStatus
from app.domain.business_onboarding_documents import BusinessOnboardingDocumentLifecycle
from app.main import create_app
from app.services.business_onboarding.document_service import build_storage_object_key
from tests.support.fake_otp_provider import FakeOtpProvider
from tests.support.memory_object_storage import MemoryObjectStorage

_DIGEST_KEY = "p" * 32
_APP_PREFIX = "/api/v1/business/onboarding/applications"

_MINIMAL_PDF = b"%PDF-1.4\n1 0 obj\n<<>>\nendobj\ntrail\n%%EOF"
_MINIMAL_PNG = (
    b"\x89PNG\r\n\x1a\n\x00\x00\x00\rIHDR\x00\x00\x00\x01"
    b"\x00\x00\x00\x01\x08\x06\x00\x00\x00\x1f\x15\xc4\x89"
    b"\x00\x00\x00\nIDATx\x9cc\x00\x01\x00\x00\x05\x00\x01"
    b"\r\n-\xdb\x00\x00\x00\x00IEND\xaeB`\x82"
)
_MINIMAL_JPEG = b"\xff\xd8\xff\xe0\x00\x10JFIF\x00\x01\x01\x00\x00\x01\x00\x01\x00\x00\xff\xd9"


@pytest.fixture
def document_engine(tmp_path: Path, monkeypatch: pytest.MonkeyPatch) -> Generator[Engine, None, None]:
    url = f"sqlite:///{(tmp_path / 'document_api.db').as_posix()}"
    monkeypatch.delenv("DATABASE_URL", raising=False)
    monkeypatch.setenv("QOSHNI_DATABASE_URL", url)
    monkeypatch.setenv("QOSHNI_AUTH_SECRET_DIGEST_KEY", _DIGEST_KEY)
    monkeypatch.setenv("QOSHNI_ONBOARDING_DOCUMENT_MAX_BYTES", str(1024))
    get_settings.cache_clear()

    engine = create_engine(url, connect_args={"check_same_thread": False})
    Base.metadata.create_all(engine)
    yield engine
    engine.dispose()
    get_settings.cache_clear()


@pytest.fixture
def document_client(
    document_engine: Engine,
) -> Generator[tuple[TestClient, FakeOtpProvider, MemoryObjectStorage], None, None]:
    provider = FakeOtpProvider()
    storage = MemoryObjectStorage()
    session_factory = sessionmaker(bind=document_engine, autoflush=False, autocommit=False)

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

    with TestClient(application) as client:
        yield client, provider, storage

    application.dependency_overrides.clear()


def _sign_in(client: TestClient, provider: FakeOtpProvider, phone: str = "+998901234567") -> dict:
    challenge = client.post("/api/v1/auth/otp/challenges", json={"phone": phone})
    assert challenge.status_code == 202, challenge.text
    verify = client.post(
        "/api/v1/auth/otp/verify",
        json={"challenge_id": challenge.json()["challenge_id"], "code": provider.last_code},
    )
    assert verify.status_code == 200, verify.text
    return verify.json()


def _auth_headers(tokens: dict) -> dict[str, str]:
    return {"Authorization": f"Bearer {tokens['access_token']}"}


def _create_application(client: TestClient, headers: dict[str, str]) -> str:
    created = client.post(
        _APP_PREFIX,
        headers=headers,
        json={"legal_business_name": "Docs LLC", "service_category": "shops"},
    )
    assert created.status_code == 201, created.text
    return created.json()["application_id"]


def _register_document(client: TestClient, headers: dict[str, str], application_id: str) -> str:
    registered = client.post(
        f"{_APP_PREFIX}/{application_id}/documents",
        headers=headers,
        json={"document_type": "registration_certificate", "declared_content_type": "application/pdf"},
    )
    assert registered.status_code == 201, registered.text
    body = registered.json()
    assert body["lifecycle_state"] == "awaiting_upload"
    assert "storage_object_key" not in body
    assert "checksum_sha256" not in body
    return body["document_id"]


def test_owner_registers_lists_and_uploads_pdf(
    document_client: tuple[TestClient, FakeOtpProvider, MemoryObjectStorage],
) -> None:
    client, provider, storage = document_client
    headers = _auth_headers(_sign_in(client, provider))
    application_id = _create_application(client, headers)
    document_id = _register_document(client, headers, application_id)

    listed = client.get(f"{_APP_PREFIX}/{application_id}/documents", headers=headers)
    assert listed.status_code == 200
    documents = listed.json()["documents"]
    assert len(documents) == 1
    assert documents[0]["document_id"] == document_id

    uploaded = client.post(
        f"{_APP_PREFIX}/{application_id}/documents/{document_id}/upload",
        headers=headers,
        files={"file": ("cert.pdf", _MINIMAL_PDF, "text/plain")},
    )
    assert uploaded.status_code == 200, uploaded.text
    body = uploaded.json()
    assert body["lifecycle_state"] == "uploaded_pending_validation"
    key = build_storage_object_key(uuid.UUID(application_id), uuid.UUID(document_id))
    assert storage.read(key) == _MINIMAL_PDF


def test_storage_object_key_is_server_generated(
    document_client: tuple[TestClient, FakeOtpProvider, MemoryObjectStorage],
    document_engine: Engine,
) -> None:
    client, provider, _storage = document_client
    headers = _auth_headers(_sign_in(client, provider))
    application_id = _create_application(client, headers)
    document_id = _register_document(client, headers, application_id)

    with Session(document_engine) as session:
        row = session.scalar(
            select(BusinessOnboardingDocument).where(BusinessOnboardingDocument.id == uuid.UUID(document_id)),
        )
        assert row is not None
        assert row.storage_object_key == build_storage_object_key(
            uuid.UUID(application_id),
            uuid.UUID(document_id),
        )
        assert row.uploaded_by_user_id is not None


def test_cross_owner_document_access_returns_not_found(
    document_client: tuple[TestClient, FakeOtpProvider, MemoryObjectStorage],
) -> None:
    client, provider, _storage = document_client
    owner_headers = _auth_headers(_sign_in(client, provider, "+998901234501"))
    application_id = _create_application(client, owner_headers)
    document_id = _register_document(client, owner_headers, application_id)

    other_headers = _auth_headers(_sign_in(client, provider, "+998901234502"))
    listed = client.get(f"{_APP_PREFIX}/{application_id}/documents", headers=other_headers)
    assert listed.status_code == 404

    uploaded = client.post(
        f"{_APP_PREFIX}/{application_id}/documents/{document_id}/upload",
        headers=other_headers,
        files={"file": ("cert.pdf", _MINIMAL_PDF, "application/pdf")},
    )
    assert uploaded.status_code == 404


def test_rejects_invalid_signature_and_oversized_payload(
    document_client: tuple[TestClient, FakeOtpProvider, MemoryObjectStorage],
) -> None:
    client, provider, _storage = document_client
    headers = _auth_headers(_sign_in(client, provider))
    application_id = _create_application(client, headers)
    document_id = _register_document(client, headers, application_id)

    bad_type = client.post(
        f"{_APP_PREFIX}/{application_id}/documents/{document_id}/upload",
        headers=headers,
        files={"file": ("evil.bin", b"NOT-A-REAL-FILE", "application/pdf")},
    )
    assert bad_type.status_code == 422

    too_large = client.post(
        f"{_APP_PREFIX}/{application_id}/documents/{document_id}/upload",
        headers=headers,
        files={"file": ("big.pdf", b"%PDF" + (b"x" * 1024), "application/pdf")},
    )
    assert too_large.status_code == 422


@pytest.mark.parametrize(
    ("payload", "filename"),
    [
        (_MINIMAL_JPEG, "photo.jpg"),
        (_MINIMAL_PNG, "photo.png"),
    ],
)
def test_accepts_jpeg_and_png_signatures(
    document_client: tuple[TestClient, FakeOtpProvider, MemoryObjectStorage],
    payload: bytes,
    filename: str,
) -> None:
    client, provider, storage = document_client
    headers = _auth_headers(_sign_in(client, provider))
    application_id = _create_application(client, headers)
    document_id = _register_document(client, headers, application_id)

    uploaded = client.post(
        f"{_APP_PREFIX}/{application_id}/documents/{document_id}/upload",
        headers=headers,
        files={"file": (filename, payload, "application/octet-stream")},
    )
    assert uploaded.status_code == 200, uploaded.text


def test_upload_blocked_when_application_not_draft(
    document_client: tuple[TestClient, FakeOtpProvider, MemoryObjectStorage],
) -> None:
    client, provider, _storage = document_client
    headers = _auth_headers(_sign_in(client, provider))
    application_id = _create_application(client, headers)
    document_id = _register_document(client, headers, application_id)

    submitted = client.post(f"{_APP_PREFIX}/{application_id}/submit", headers=headers, json={})
    assert submitted.status_code == 200
    assert submitted.json()["verification_status"] == VerificationStatus.SUBMITTED.value

    blocked = client.post(
        f"{_APP_PREFIX}/{application_id}/documents/{document_id}/upload",
        headers=headers,
        files={"file": ("cert.pdf", _MINIMAL_PDF, "application/pdf")},
    )
    assert blocked.status_code == 409


def test_duplicate_upload_is_idempotent(
    document_client: tuple[TestClient, FakeOtpProvider, MemoryObjectStorage],
    document_engine: Engine,
) -> None:
    client, provider, storage = document_client
    headers = _auth_headers(_sign_in(client, provider))
    application_id = _create_application(client, headers)
    document_id = _register_document(client, headers, application_id)

    first = client.post(
        f"{_APP_PREFIX}/{application_id}/documents/{document_id}/upload",
        headers=headers,
        files={"file": ("cert.pdf", _MINIMAL_PDF, "application/pdf")},
    )
    assert first.status_code == 200
    calls_after_first = storage.put_calls

    second = client.post(
        f"{_APP_PREFIX}/{application_id}/documents/{document_id}/upload",
        headers=headers,
        files={"file": ("cert.pdf", _MINIMAL_PDF, "application/pdf")},
    )
    assert second.status_code == 200
    assert storage.put_calls == calls_after_first

    with Session(document_engine) as session:
        audit_events = session.scalars(select(BusinessOnboardingAuditEvent)).all()
        assert len(audit_events) == 1
        assert audit_events[0].event_type == "application_created"


def test_storage_failure_returns_safe_error_and_keeps_awaiting_upload(
    document_client: tuple[TestClient, FakeOtpProvider, MemoryObjectStorage],
    document_engine: Engine,
) -> None:
    client, provider, storage = document_client
    storage.fail_puts = True
    headers = _auth_headers(_sign_in(client, provider))
    application_id = _create_application(client, headers)
    document_id = _register_document(client, headers, application_id)

    failed = client.post(
        f"{_APP_PREFIX}/{application_id}/documents/{document_id}/upload",
        headers=headers,
        files={"file": ("cert.pdf", _MINIMAL_PDF, "application/pdf")},
    )
    assert failed.status_code == 503
    body = failed.json()
    assert body["error"]["code"] == "storage_unavailable"
    assert "storage_object_key" not in failed.text
    assert "Injected storage failure" not in failed.text

    with Session(document_engine) as session:
        row = session.get(BusinessOnboardingDocument, uuid.UUID(document_id))
        assert row is not None
        assert row.lifecycle_state == BusinessOnboardingDocumentLifecycle.AWAITING_UPLOAD.value


def test_document_endpoint_contracts_implementation_flags() -> None:
    owner_implemented = {
        contract.path
        for contract in DOCUMENT_ENDPOINT_CONTRACTS
        if contract.owner_accessible and contract.implemented
    }
    assert f"/business/onboarding/applications/{{application_id}}/documents" in owner_implemented
    assert (
        "/business/onboarding/applications/{application_id}/documents/{document_id}/upload"
        in owner_implemented
    )
    upload_init = next(
        contract
        for contract in DOCUMENT_ENDPOINT_CONTRACTS
        if contract.path.endswith("/upload-init")
    )
    assert upload_init.implemented is False
    internal = [c for c in DOCUMENT_ENDPOINT_CONTRACTS if "/internal/" in c.path]
    assert all(not c.implemented for c in internal)


def test_register_rejects_client_storage_key_in_body(
    document_client: tuple[TestClient, FakeOtpProvider, MemoryObjectStorage],
) -> None:
    client, provider, _storage = document_client
    headers = _auth_headers(_sign_in(client, provider))
    application_id = _create_application(client, headers)

    rejected = client.post(
        f"{_APP_PREFIX}/{application_id}/documents",
        headers=headers,
        json={
            "document_type": "registration_certificate",
            "storage_object_key": "private/onboarding/evil",
        },
    )
    assert rejected.status_code == 422

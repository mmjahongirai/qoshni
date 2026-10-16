"""Document upload error semantics (HTTP status and compensation)."""

from __future__ import annotations

import uuid
from collections.abc import Generator
from pathlib import Path
from unittest.mock import MagicMock

import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.engine import Engine
from sqlalchemy.orm import Session, sessionmaker

from app.api.deps.auth import get_otp_delivery_provider
from app.api.deps.object_storage import get_object_storage
from app.api.routes.business_onboarding_documents import _commit_document_upload
from app.core.config import get_settings
from app.core.database import get_db
from app.db.base import Base
from app.main import create_app
from app.services.business_onboarding.onboarding_service import OnboardingServiceErrorCode
from app.services.object_storage.errors import StorageOperationError
from tests.support.fake_otp_provider import FakeOtpProvider
from app.services.malware_scanning.fake import FakeMalwareScanner
from tests.support.memory_object_storage import MemoryObjectStorage

_DIGEST_KEY = "p" * 32
_APP_PREFIX = "/api/v1/business/onboarding/applications"
_MINIMAL_PDF = b"%PDF-1.4\n1 0 obj\n<<>>\nendobj\ntrail\n%%EOF"


@pytest.fixture
def bare_document_client(
    tmp_path: Path,
    monkeypatch: pytest.MonkeyPatch,
) -> Generator[tuple[TestClient, FakeOtpProvider], None, None]:
    url = f"sqlite:///{(tmp_path / 'document_upload_errors.db').as_posix()}"
    monkeypatch.delenv("DATABASE_URL", raising=False)
    monkeypatch.delenv("QOSHNI_OBJECT_STORAGE_PROVIDER", raising=False)
    monkeypatch.delenv("QOSHNI_OBJECT_STORAGE_LOCAL_ROOT", raising=False)
    monkeypatch.setenv("QOSHNI_DATABASE_URL", url)
    monkeypatch.setenv("QOSHNI_AUTH_SECRET_DIGEST_KEY", _DIGEST_KEY)
    get_settings.cache_clear()

    engine = create_engine(url, connect_args={"check_same_thread": False})
    Base.metadata.create_all(engine)
    session_factory = sessionmaker(bind=engine, autoflush=False, autocommit=False)
    provider = FakeOtpProvider()

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
    engine.dispose()
    get_settings.cache_clear()


def _sign_in(client: TestClient, provider: FakeOtpProvider) -> dict[str, str]:
    challenge = client.post("/api/v1/auth/otp/challenges", json={"phone": "+998901234567"})
    assert challenge.status_code == 202
    verify = client.post(
        "/api/v1/auth/otp/verify",
        json={"challenge_id": challenge.json()["challenge_id"], "code": provider.last_code},
    )
    assert verify.status_code == 200
    return {"Authorization": f"Bearer {verify.json()['access_token']}"}


def test_commit_failure_returns_storage_unavailable_even_if_delete_fails() -> None:
    db = MagicMock()
    db.commit.side_effect = RuntimeError("database unavailable")
    storage = MagicMock()
    storage.delete.side_effect = StorageOperationError("delete failed")

    error = _commit_document_upload(
        db,
        storage,
        storage_key="private/onboarding/app/doc",
    )

    assert error is not None
    assert error.code == OnboardingServiceErrorCode.STORAGE_UNAVAILABLE
    assert "database unavailable" not in error.message
    assert "delete failed" not in error.message
    db.rollback.assert_called_once()
    storage.delete.assert_called_once_with("private/onboarding/app/doc")


def test_upload_without_storage_configuration_returns_503(
    bare_document_client: tuple[TestClient, FakeOtpProvider],
) -> None:
    client, provider = bare_document_client
    headers = _sign_in(client, provider)
    application_id = client.post(
        _APP_PREFIX,
        headers=headers,
        json={"legal_business_name": "No Storage LLC", "service_category": "shops"},
    ).json()["application_id"]
    document_id = client.post(
        f"{_APP_PREFIX}/{application_id}/documents",
        headers=headers,
        json={"document_type": "registration_certificate"},
    ).json()["document_id"]

    response = client.post(
        f"{_APP_PREFIX}/{application_id}/documents/{document_id}/upload",
        headers=headers,
        files={"file": ("cert.pdf", _MINIMAL_PDF, "application/pdf")},
    )
    assert response.status_code == 503
    assert "private/onboarding" not in response.text


def test_service_maps_storage_put_failure_to_storage_unavailable() -> None:
    from sqlalchemy.orm import Session

    from app.db.models.business_onboarding import BusinessOnboardingApplication, BusinessOnboardingDocument
    from app.db.models import User
    from app.services.business_onboarding.document_service import (
        build_storage_object_key,
        upload_owner_document_bytes,
    )
    from app.services.business_onboarding.onboarding_service import OnboardingServiceError

    engine = create_engine("sqlite://")
    Base.metadata.create_all(engine)
    storage = MemoryObjectStorage(fail_puts=True)
    with Session(engine) as session:
        owner = User(phone_e164="+998901111111")
        session.add(owner)
        session.flush()
        application = BusinessOnboardingApplication(owner_user_id=owner.id)
        session.add(application)
        session.flush()
        document_id = uuid.uuid4()
        document = BusinessOnboardingDocument(
            id=document_id,
            application_id=application.id,
            uploaded_by_user_id=owner.id,
            document_type="registration_certificate",
            storage_object_key=build_storage_object_key(application.id, document_id),
        )
        session.add(document)
        session.commit()

        result = upload_owner_document_bytes(
            session,
            owner_user_id=owner.id,
            application_id=application.id,
            document_id=document.id,
            payload=_MINIMAL_PDF,
            storage=storage,
            scanner=FakeMalwareScanner(),
            max_bytes=1024 * 1024,
        )
        assert isinstance(result, OnboardingServiceError)
        assert result.code == OnboardingServiceErrorCode.STORAGE_UNAVAILABLE
        session.refresh(document)
        assert document.lifecycle_state == "awaiting_upload"

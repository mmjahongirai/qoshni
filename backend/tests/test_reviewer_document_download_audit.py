"""Audit trail for privileged reviewer document downloads."""

from __future__ import annotations

import uuid
from collections.abc import Generator
from pathlib import Path
from unittest.mock import patch

import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine, func, select
from sqlalchemy.engine import Engine
from sqlalchemy.orm import Session, sessionmaker

from app.api.deps.auth import get_otp_delivery_provider
from app.api.deps.object_storage import get_object_storage
from app.core.config import get_settings
from app.core.database import get_db
from app.db.base import Base
from app.db.models.business_onboarding import BusinessOnboardingAuditEvent, BusinessOnboardingDocument
from app.db.models.identity import User
from app.db.models.platform_roles import UserPlatformRoleAssignment
from app.domain.business_onboarding import OnboardingAuditActorRole, OnboardingAuditEventType
from app.domain.business_onboarding_documents import BusinessOnboardingDocumentLifecycle
from app.domain.malware_scanning import MalwareScanStatus
from app.domain.platform_roles import PlatformRole
from app.domain.role_assignments import RoleAssignmentGrantSource
from app.main import create_app
from app.services.business_onboarding.document_service import build_storage_object_key
from app.services.business_onboarding.onboarding_service import (
    OnboardingServiceError,
    OnboardingServiceErrorCode,
)
from tests.support.fake_otp_provider import FakeOtpProvider
from tests.support.memory_object_storage import MemoryObjectStorage

_DIGEST_KEY = "p" * 32
_REVIEW_PREFIX = "/api/v1/internal/business/onboarding/applications"
_MINIMAL_PDF = b"%PDF-1.4\n1 0 obj\n<<>>\nendobj\ntrail\n%%EOF"


@pytest.fixture
def download_audit_engine(tmp_path: Path, monkeypatch: pytest.MonkeyPatch) -> Generator[Engine, None, None]:
    url = f"sqlite:///{(tmp_path / 'download_audit.db').as_posix()}"
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
def download_audit_client(
    download_audit_engine: Engine,
) -> Generator[tuple[TestClient, FakeOtpProvider, MemoryObjectStorage, sessionmaker[Session]], None, None]:
    provider = FakeOtpProvider()
    storage = MemoryObjectStorage()
    session_factory = sessionmaker(bind=download_audit_engine, autoflush=False, autocommit=False)

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
        yield client, provider, storage, session_factory

    application.dependency_overrides.clear()


def _sign_in(client: TestClient, provider: FakeOtpProvider, phone: str) -> str:
    challenge = client.post("/api/v1/auth/otp/challenges", json={"phone": phone})
    verify = client.post(
        "/api/v1/auth/otp/verify",
        json={"challenge_id": challenge.json()["challenge_id"], "code": provider.last_code},
    )
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


def _submitted_application(session: Session, owner: User) -> uuid.UUID:
    from datetime import UTC, datetime

    from app.db.models.business_onboarding import BusinessOnboardingApplication
    from app.domain.business_onboarding import VerificationStatus

    application = BusinessOnboardingApplication(
        owner_user_id=owner.id,
        legal_business_name="Audit LLC",
        service_category="shops",
        registration_jurisdiction="UZ",
        registration_identifier=f"REG-{uuid.uuid4().hex[:8]}",
        verification_status=VerificationStatus.SUBMITTED.value,
        submitted_at=datetime.now(UTC),
    )
    session.add(application)
    session.flush()
    return application.id


def _clean_document(
    session: Session,
    *,
    application_id: uuid.UUID,
    owner_id: uuid.UUID,
    storage: MemoryObjectStorage,
) -> uuid.UUID:
    document_id = uuid.uuid4()
    key = build_storage_object_key(application_id, document_id)
    storage.put(key, _MINIMAL_PDF, content_type="application/pdf")
    session.add(
        BusinessOnboardingDocument(
            id=document_id,
            application_id=application_id,
            uploaded_by_user_id=owner_id,
            document_type="registration_certificate",
            storage_object_key=key,
            lifecycle_state=BusinessOnboardingDocumentLifecycle.UPLOADED_PENDING_VALIDATION.value,
            byte_size=len(_MINIMAL_PDF),
            checksum_sha256="a" * 64,
            malware_scan_status=MalwareScanStatus.CLEAN.value,
        ),
    )
    session.commit()
    return document_id


def _download_served_count(session: Session, application_id: uuid.UUID) -> int:
    return session.scalar(
        select(func.count())
        .select_from(BusinessOnboardingAuditEvent)
        .where(
            BusinessOnboardingAuditEvent.application_id == application_id,
            BusinessOnboardingAuditEvent.event_type
            == OnboardingAuditEventType.DOCUMENT_DOWNLOAD_SERVED.value,
        ),
    ) or 0


def test_successful_download_writes_one_audit_event(download_audit_client) -> None:
    client, provider, storage, factory = download_audit_client
    reviewer_phone = "+998901240001"
    owner_phone = "+998901240002"
    reviewer_token = _sign_in(client, provider, reviewer_phone)
    _sign_in(client, provider, owner_phone)
    reviewer_user_id: uuid.UUID
    with factory() as session:
        reviewer = session.scalar(select(User).where(User.phone_e164 == reviewer_phone))
        owner = session.scalar(select(User).where(User.phone_e164 == owner_phone))
        assert reviewer and owner
        reviewer_user_id = reviewer.id
        _grant_reviewer(session, reviewer.id)
        application_id = _submitted_application(session, owner)
        document_id = _clean_document(
            session,
            application_id=application_id,
            owner_id=owner.id,
            storage=storage,
        )

    path = f"{_REVIEW_PREFIX}/{application_id}/documents/{document_id}/download"
    response = client.get(path, headers=_auth(reviewer_token))
    assert response.status_code == 200
    assert response.content == _MINIMAL_PDF

    with factory() as session:
        assert _download_served_count(session, application_id) == 1
        event = session.scalar(
            select(BusinessOnboardingAuditEvent).where(
                BusinessOnboardingAuditEvent.application_id == application_id,
                BusinessOnboardingAuditEvent.event_type
                == OnboardingAuditEventType.DOCUMENT_DOWNLOAD_SERVED.value,
            ),
        )
        assert event is not None
        assert event.actor_role == OnboardingAuditActorRole.REVIEWER.value
        assert event.actor_user_id == reviewer_user_id
        assert event.details == {"document_id": str(document_id)}
        assert "storage_object_key" not in str(event.details)
        assert "checksum" not in str(event.details).lower()


def test_repeat_downloads_append_separate_audit_rows(download_audit_client) -> None:
    client, provider, storage, factory = download_audit_client
    reviewer_phone = "+998901240003"
    owner_phone = "+998901240004"
    reviewer_token = _sign_in(client, provider, reviewer_phone)
    _sign_in(client, provider, owner_phone)
    with factory() as session:
        reviewer = session.scalar(select(User).where(User.phone_e164 == reviewer_phone))
        owner = session.scalar(select(User).where(User.phone_e164 == owner_phone))
        assert reviewer and owner
        _grant_reviewer(session, reviewer.id)
        application_id = _submitted_application(session, owner)
        document_id = _clean_document(
            session,
            application_id=application_id,
            owner_id=owner.id,
            storage=storage,
        )

    path = f"{_REVIEW_PREFIX}/{application_id}/documents/{document_id}/download"
    assert client.get(path, headers=_auth(reviewer_token)).status_code == 200
    assert client.get(path, headers=_auth(reviewer_token)).status_code == 200

    with factory() as session:
        assert _download_served_count(session, application_id) == 2


def test_forbidden_reviewer_does_not_write_download_audit(download_audit_client) -> None:
    client, provider, storage, factory = download_audit_client
    owner_phone = "+998901240005"
    owner_token = _sign_in(client, provider, owner_phone)
    with factory() as session:
        owner = session.scalar(select(User).where(User.phone_e164 == owner_phone))
        assert owner
        application_id = _submitted_application(session, owner)
        document_id = _clean_document(
            session,
            application_id=application_id,
            owner_id=owner.id,
            storage=storage,
        )

    response = client.get(
        f"{_REVIEW_PREFIX}/{application_id}/documents/{document_id}/download",
        headers=_auth(owner_token),
    )
    assert response.status_code == 403
    with factory() as session:
        assert _download_served_count(session, application_id) == 0


def test_self_review_download_blocked_without_audit(download_audit_client) -> None:
    client, provider, storage, factory = download_audit_client
    phone = "+998901240006"
    token = _sign_in(client, provider, phone)
    with factory() as session:
        user = session.scalar(select(User).where(User.phone_e164 == phone))
        assert user
        _grant_reviewer(session, user.id)
        application_id = _submitted_application(session, user)
        document_id = _clean_document(
            session,
            application_id=application_id,
            owner_id=user.id,
            storage=storage,
        )

    assert (
        client.get(
            f"{_REVIEW_PREFIX}/{application_id}/documents/{document_id}/download",
            headers=_auth(token),
        ).status_code
        == 403
    )
    with factory() as session:
        assert _download_served_count(session, application_id) == 0


def test_unscanned_document_no_download_audit(download_audit_client) -> None:
    client, provider, storage, factory = download_audit_client
    reviewer_phone = "+998901240007"
    owner_phone = "+998901240008"
    reviewer_token = _sign_in(client, provider, reviewer_phone)
    _sign_in(client, provider, owner_phone)
    with factory() as session:
        reviewer = session.scalar(select(User).where(User.phone_e164 == reviewer_phone))
        owner = session.scalar(select(User).where(User.phone_e164 == owner_phone))
        assert reviewer and owner
        _grant_reviewer(session, reviewer.id)
        application_id = _submitted_application(session, owner)
        document_id = uuid.uuid4()
        key = build_storage_object_key(application_id, document_id)
        storage.put(key, _MINIMAL_PDF)
        session.add(
            BusinessOnboardingDocument(
                id=document_id,
                application_id=application_id,
                uploaded_by_user_id=owner.id,
                document_type="registration_certificate",
                storage_object_key=key,
                lifecycle_state=BusinessOnboardingDocumentLifecycle.UPLOADED_PENDING_VALIDATION.value,
                byte_size=len(_MINIMAL_PDF),
                malware_scan_status=None,
            ),
        )
        session.commit()

    assert (
        client.get(
            f"{_REVIEW_PREFIX}/{application_id}/documents/{document_id}/download",
            headers=_auth(reviewer_token),
        ).status_code
        == 404
    )
    with factory() as session:
        assert _download_served_count(session, application_id) == 0


def test_missing_storage_object_no_download_audit(download_audit_client) -> None:
    client, provider, _storage, factory = download_audit_client
    reviewer_phone = "+998901240009"
    owner_phone = "+998901240010"
    reviewer_token = _sign_in(client, provider, reviewer_phone)
    _sign_in(client, provider, owner_phone)
    with factory() as session:
        reviewer = session.scalar(select(User).where(User.phone_e164 == reviewer_phone))
        owner = session.scalar(select(User).where(User.phone_e164 == owner_phone))
        assert reviewer and owner
        _grant_reviewer(session, reviewer.id)
        application_id = _submitted_application(session, owner)
        document_id = uuid.uuid4()
        session.add(
            BusinessOnboardingDocument(
                id=document_id,
                application_id=application_id,
                uploaded_by_user_id=owner.id,
                document_type="registration_certificate",
                storage_object_key=build_storage_object_key(application_id, document_id),
                lifecycle_state=BusinessOnboardingDocumentLifecycle.UPLOADED_PENDING_VALIDATION.value,
                byte_size=len(_MINIMAL_PDF),
                malware_scan_status=MalwareScanStatus.CLEAN.value,
            ),
        )
        session.commit()

    assert (
        client.get(
            f"{_REVIEW_PREFIX}/{application_id}/documents/{document_id}/download",
            headers=_auth(reviewer_token),
        ).status_code
        == 503
    )
    with factory() as session:
        assert _download_served_count(session, application_id) == 0


def test_audit_commit_failure_does_not_return_file_bytes(download_audit_client) -> None:
    client, provider, storage, factory = download_audit_client
    reviewer_phone = "+998901240011"
    owner_phone = "+998901240012"
    reviewer_token = _sign_in(client, provider, reviewer_phone)
    _sign_in(client, provider, owner_phone)
    with factory() as session:
        reviewer = session.scalar(select(User).where(User.phone_e164 == reviewer_phone))
        owner = session.scalar(select(User).where(User.phone_e164 == owner_phone))
        assert reviewer and owner
        _grant_reviewer(session, reviewer.id)
        application_id = _submitted_application(session, owner)
        document_id = _clean_document(
            session,
            application_id=application_id,
            owner_id=owner.id,
            storage=storage,
        )

    path = f"{_REVIEW_PREFIX}/{application_id}/documents/{document_id}/download"
    with patch(
        "app.api.routes.business_onboarding_review._commit_reviewer_download_audit",
        return_value=OnboardingServiceError(
            code=OnboardingServiceErrorCode.STORAGE_UNAVAILABLE,
            message="Document could not be retrieved.",
        ),
    ):
        response = client.get(path, headers=_auth(reviewer_token))

    assert response.status_code == 503
    assert response.content != _MINIMAL_PDF
    assert "error" in response.json()

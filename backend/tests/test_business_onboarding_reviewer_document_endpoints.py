"""Reviewer onboarding document list and download tests."""

from __future__ import annotations

import uuid
from collections.abc import Generator
from datetime import UTC, datetime
from pathlib import Path

import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine, select
from sqlalchemy.engine import Engine
from sqlalchemy.orm import Session, sessionmaker

from app.api.deps.auth import get_otp_delivery_provider
from app.api.deps.object_storage import get_object_storage
from app.core.config import get_settings
from app.core.database import get_db
from app.db.base import Base
from app.db.models.business_onboarding import BusinessOnboardingApplication, BusinessOnboardingDocument
from app.db.models.identity import User
from app.db.models.platform_roles import UserPlatformRoleAssignment
from app.domain.business_onboarding import VerificationStatus
from app.domain.business_onboarding_documents import BusinessOnboardingDocumentLifecycle
from app.domain.identity import AccountStatus
from app.domain.malware_scanning import MalwareScanStatus
from app.domain.platform_roles import PlatformRole
from app.domain.role_assignments import RoleAssignmentGrantSource
from app.main import create_app
from app.services.business_onboarding.document_service import build_storage_object_key
from tests.support.fake_otp_provider import FakeOtpProvider
from tests.support.memory_object_storage import MemoryObjectStorage

_DIGEST_KEY = "p" * 32
_REVIEW_PREFIX = "/api/v1/internal/business/onboarding/applications"
_MINIMAL_PDF = b"%PDF-1.4\n1 0 obj\n<<>>\nendobj\ntrail\n%%EOF"


@pytest.fixture
def reviewer_doc_engine(tmp_path: Path, monkeypatch: pytest.MonkeyPatch) -> Generator[Engine, None, None]:
    url = f"sqlite:///{(tmp_path / 'reviewer_docs.db').as_posix()}"
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
def reviewer_doc_client(
    reviewer_doc_engine: Engine,
) -> Generator[tuple[TestClient, FakeOtpProvider, MemoryObjectStorage, sessionmaker[Session]], None, None]:
    provider = FakeOtpProvider()
    storage = MemoryObjectStorage()
    session_factory = sessionmaker(bind=reviewer_doc_engine, autoflush=False, autocommit=False)

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


def _submitted_application(
    session: Session,
    owner: User,
    *,
    registration_identifier: str | None = None,
) -> BusinessOnboardingApplication:
    application = BusinessOnboardingApplication(
        owner_user_id=owner.id,
        legal_business_name="Docs Review LLC",
        service_category="shops",
        registration_jurisdiction="UZ",
        registration_identifier=registration_identifier or f"REG-DOC-{uuid.uuid4().hex[:8]}",
        verification_status=VerificationStatus.SUBMITTED.value,
        submitted_at=datetime.now(UTC),
    )
    session.add(application)
    session.flush()
    return application


def _clean_document(
    session: Session,
    *,
    application: BusinessOnboardingApplication,
    owner: User,
    storage: MemoryObjectStorage,
) -> BusinessOnboardingDocument:
    document_id = uuid.uuid4()
    key = build_storage_object_key(application.id, document_id)
    storage.put(key, _MINIMAL_PDF, content_type="application/pdf")
    document = BusinessOnboardingDocument(
        id=document_id,
        application_id=application.id,
        uploaded_by_user_id=owner.id,
        document_type="registration_certificate",
        storage_object_key=key,
        lifecycle_state=BusinessOnboardingDocumentLifecycle.UPLOADED_PENDING_VALIDATION.value,
        byte_size=len(_MINIMAL_PDF),
        checksum_sha256="a" * 64,
        malware_scan_status=MalwareScanStatus.CLEAN.value,
    )
    session.add(document)
    session.commit()
    return document


def test_reviewer_lists_document_metadata(reviewer_doc_client) -> None:
    client, provider, storage, factory = reviewer_doc_client
    reviewer_phone = "+998901230001"
    owner_phone = "+998901230002"
    reviewer_token = _sign_in(client, provider, reviewer_phone)
    _sign_in(client, provider, owner_phone)
    with factory() as session:
        reviewer = session.scalar(select(User).where(User.phone_e164 == reviewer_phone))
        owner = session.scalar(select(User).where(User.phone_e164 == owner_phone))
        assert reviewer and owner
        owner.status = AccountStatus.ACTIVE.value
        _grant_reviewer(session, reviewer.id)
        application = _submitted_application(session, owner)
        document = _clean_document(session, application=application, owner=owner, storage=storage)
        application_id = str(application.id)
        document_id = str(document.id)

    listed = client.get(f"{_REVIEW_PREFIX}/{application_id}/documents", headers=_auth(reviewer_token))
    assert listed.status_code == 200, listed.text
    body = listed.json()
    assert len(body["documents"]) == 1
    item = body["documents"][0]
    assert item["document_id"] == document_id
    assert item["byte_size"] == len(_MINIMAL_PDF)
    assert "storage_object_key" not in listed.text
    assert "checksum_sha256" not in listed.text


def test_reviewer_downloads_clean_document(reviewer_doc_client) -> None:
    client, provider, storage, factory = reviewer_doc_client
    reviewer_phone = "+998901230003"
    owner_phone = "+998901230004"
    reviewer_token = _sign_in(client, provider, reviewer_phone)
    _sign_in(client, provider, owner_phone)
    with factory() as session:
        reviewer = session.scalar(select(User).where(User.phone_e164 == reviewer_phone))
        owner = session.scalar(select(User).where(User.phone_e164 == owner_phone))
        assert reviewer and owner
        _grant_reviewer(session, reviewer.id)
        application = _submitted_application(session, owner)
        document = _clean_document(session, application=application, owner=owner, storage=storage)
        application_id = str(application.id)
        document_id = str(document.id)

    response = client.get(
        f"{_REVIEW_PREFIX}/{application_id}/documents/{document_id}/download",
        headers=_auth(reviewer_token),
    )
    assert response.status_code == 200, response.text
    assert response.content == _MINIMAL_PDF
    assert response.headers["content-type"].startswith("application/pdf")
    assert response.headers["x-content-type-options"] == "nosniff"
    assert "attachment" in response.headers["content-disposition"].lower()
    assert "private/onboarding" not in response.text


def test_unscanned_document_download_rejected(reviewer_doc_client) -> None:
    client, provider, storage, factory = reviewer_doc_client
    reviewer_phone = "+998901230005"
    owner_phone = "+998901230006"
    reviewer_token = _sign_in(client, provider, reviewer_phone)
    _sign_in(client, provider, owner_phone)
    with factory() as session:
        reviewer = session.scalar(select(User).where(User.phone_e164 == reviewer_phone))
        owner = session.scalar(select(User).where(User.phone_e164 == owner_phone))
        assert reviewer and owner
        _grant_reviewer(session, reviewer.id)
        application = _submitted_application(session, owner)
        document_id = uuid.uuid4()
        key = build_storage_object_key(application.id, document_id)
        storage.put(key, _MINIMAL_PDF)
        document = BusinessOnboardingDocument(
            id=document_id,
            application_id=application.id,
            uploaded_by_user_id=owner.id,
            document_type="registration_certificate",
            storage_object_key=key,
            lifecycle_state=BusinessOnboardingDocumentLifecycle.UPLOADED_PENDING_VALIDATION.value,
            byte_size=len(_MINIMAL_PDF),
            malware_scan_status=None,
        )
        session.add(document)
        session.commit()
        application_id = str(application.id)

    response = client.get(
        f"{_REVIEW_PREFIX}/{application_id}/documents/{document_id}/download",
        headers=_auth(reviewer_token),
    )
    assert response.status_code == 404


def test_non_reviewer_forbidden(reviewer_doc_client) -> None:
    client, provider, _storage, factory = reviewer_doc_client
    owner_phone = "+998901230007"
    owner_token = _sign_in(client, provider, owner_phone)
    with factory() as session:
        owner = session.scalar(select(User).where(User.phone_e164 == owner_phone))
        assert owner
        application = _submitted_application(session, owner)
        application_id = str(application.id)

    assert client.get(f"{_REVIEW_PREFIX}/{application_id}/documents", headers=_auth(owner_token)).status_code == 403


def test_self_review_blocked(reviewer_doc_client) -> None:
    client, provider, storage, factory = reviewer_doc_client
    phone = "+998901230008"
    token = _sign_in(client, provider, phone)
    with factory() as session:
        user = session.scalar(select(User).where(User.phone_e164 == phone))
        assert user
        _grant_reviewer(session, user.id)
        application = _submitted_application(session, user)
        document = _clean_document(session, application=application, owner=user, storage=storage)
        application_id = str(application.id)
        document_id = str(document.id)

    assert client.get(f"{_REVIEW_PREFIX}/{application_id}/documents", headers=_auth(token)).status_code == 403
    assert (
        client.get(
            f"{_REVIEW_PREFIX}/{application_id}/documents/{document_id}/download",
            headers=_auth(token),
        ).status_code
        == 403
    )


def test_cross_application_document_download_not_found(reviewer_doc_client) -> None:
    client, provider, storage, factory = reviewer_doc_client
    reviewer_phone = "+998901230009"
    owner_a = "+998901230010"
    owner_b = "+998901230011"
    reviewer_token = _sign_in(client, provider, reviewer_phone)
    _sign_in(client, provider, owner_a)
    _sign_in(client, provider, owner_b)
    with factory() as session:
        reviewer = session.scalar(select(User).where(User.phone_e164 == reviewer_phone))
        owner1 = session.scalar(select(User).where(User.phone_e164 == owner_a))
        owner2 = session.scalar(select(User).where(User.phone_e164 == owner_b))
        assert reviewer and owner1 and owner2
        _grant_reviewer(session, reviewer.id)
        app_a = _submitted_application(session, owner1)
        app_b = _submitted_application(session, owner2)
        doc_b = _clean_document(session, application=app_b, owner=owner2, storage=storage)
        application_a_id = str(app_a.id)
        document_b_id = str(doc_b.id)

    assert (
        client.get(
            f"{_REVIEW_PREFIX}/{application_a_id}/documents/{document_b_id}/download",
            headers=_auth(reviewer_token),
        ).status_code
        == 404
    )


def test_missing_storage_object_returns_safe_error(reviewer_doc_client) -> None:
    client, provider, _storage, factory = reviewer_doc_client
    reviewer_phone = "+998901230012"
    owner_phone = "+998901230013"
    reviewer_token = _sign_in(client, provider, reviewer_phone)
    _sign_in(client, provider, owner_phone)
    with factory() as session:
        reviewer = session.scalar(select(User).where(User.phone_e164 == reviewer_phone))
        owner = session.scalar(select(User).where(User.phone_e164 == owner_phone))
        assert reviewer and owner
        _grant_reviewer(session, reviewer.id)
        application = _submitted_application(session, owner)
        document_id = uuid.uuid4()
        document = BusinessOnboardingDocument(
            id=document_id,
            application_id=application.id,
            uploaded_by_user_id=owner.id,
            document_type="registration_certificate",
            storage_object_key=build_storage_object_key(application.id, document_id),
            lifecycle_state=BusinessOnboardingDocumentLifecycle.UPLOADED_PENDING_VALIDATION.value,
            byte_size=len(_MINIMAL_PDF),
            malware_scan_status=MalwareScanStatus.CLEAN.value,
        )
        session.add(document)
        session.commit()
        application_id = str(application.id)

    response = client.get(
        f"{_REVIEW_PREFIX}/{application_id}/documents/{document_id}/download",
        headers=_auth(reviewer_token),
    )
    assert response.status_code == 503
    assert "private/onboarding" not in response.text

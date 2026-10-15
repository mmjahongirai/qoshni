"""Business onboarding private document metadata."""

import uuid
from collections.abc import Generator
from datetime import UTC, datetime

import pytest
from sqlalchemy import create_engine, event, select
from sqlalchemy.engine import Engine
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from app.api.schemas.business_onboarding_documents import (
    DOCUMENT_ENDPOINT_CONTRACTS,
    OwnerOnboardingDocumentView,
)
from app.api.schemas.profile import UserProfileView
from app.db.base import Base
from app.db.models import User
from app.db.models.business_onboarding import (
    BusinessOnboardingApplication,
    BusinessOnboardingDocument,
)
from app.domain.business_onboarding import VerificationStatus
from app.domain.business_onboarding_documents import (
    BusinessOnboardingDocumentLifecycle,
    BusinessOnboardingDocumentType,
)


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
    user = User(phone_e164=phone)
    session.add(user)
    session.flush()
    return user


def _application(session: Session, owner: User) -> BusinessOnboardingApplication:
    application = BusinessOnboardingApplication(owner_user_id=owner.id)
    session.add(application)
    session.flush()
    return application


def test_document_defaults_to_awaiting_upload(session: Session) -> None:
    owner = _user(session)
    application = _application(session, owner)
    document = BusinessOnboardingDocument(
        application_id=application.id,
        uploaded_by_user_id=owner.id,
        document_type=BusinessOnboardingDocumentType.REGISTRATION_CERTIFICATE.value,
        storage_object_key="private/onboarding/11111111-1111-1111-1111-111111111111",
    )
    session.add(document)
    session.commit()

    assert document.lifecycle_state == BusinessOnboardingDocumentLifecycle.AWAITING_UPLOAD.value
    assert document.created_at is not None


def test_storage_object_key_must_be_unique(session: Session) -> None:
    owner = _user(session)
    application = _application(session, owner)
    key = "private/onboarding/shared-key"
    session.add(
        BusinessOnboardingDocument(
            application_id=application.id,
            uploaded_by_user_id=owner.id,
            document_type=BusinessOnboardingDocumentType.TAX_REGISTRATION.value,
            storage_object_key=key,
        ),
    )
    session.commit()

    other_app = BusinessOnboardingApplication(owner_user_id=owner.id)
    session.add(other_app)
    session.flush()
    session.add(
        BusinessOnboardingDocument(
            application_id=other_app.id,
            uploaded_by_user_id=owner.id,
            document_type=BusinessOnboardingDocumentType.OTHER_SUPPORTING.value,
            storage_object_key=key,
        ),
    )
    with pytest.raises(IntegrityError):
        session.commit()


def test_document_requires_valid_application(session: Session) -> None:
    owner = _user(session)
    session.add(
        BusinessOnboardingDocument(
            application_id=uuid.uuid4(),
            uploaded_by_user_id=owner.id,
            document_type=BusinessOnboardingDocumentType.OTHER_SUPPORTING.value,
            storage_object_key="private/onboarding/missing-app",
        ),
    )
    with pytest.raises(IntegrityError):
        session.commit()


def test_invalid_document_type_rejected(session: Session) -> None:
    owner = _user(session)
    application = _application(session, owner)
    session.add(
        BusinessOnboardingDocument(
            application_id=application.id,
            uploaded_by_user_id=owner.id,
            document_type="not_a_real_type",
            storage_object_key="private/onboarding/bad-type",
        ),
    )
    with pytest.raises(IntegrityError):
        session.commit()


def test_trimmed_storage_key_required(session: Session) -> None:
    owner = _user(session)
    application = _application(session, owner)
    session.add(
        BusinessOnboardingDocument(
            application_id=application.id,
            uploaded_by_user_id=owner.id,
            document_type=BusinessOnboardingDocumentType.OTHER_SUPPORTING.value,
            storage_object_key="  padded-key  ",
        ),
    )
    with pytest.raises(IntegrityError):
        session.commit()


def test_owner_document_view_excludes_storage_key() -> None:
    now = datetime.now(UTC)
    view = OwnerOnboardingDocumentView(
        document_id=uuid.uuid4(),
        application_id=uuid.uuid4(),
        document_type=BusinessOnboardingDocumentType.REGISTRATION_CERTIFICATE,
        lifecycle_state=BusinessOnboardingDocumentLifecycle.AWAITING_UPLOAD,
        created_at=now,
        updated_at=now,
    )
    payload = view.model_dump()
    assert "storage_object_key" not in payload
    assert "checksum_sha256" not in payload


def test_profile_view_unrelated_to_documents() -> None:
    """Public profile DTOs must not carry onboarding document fields."""
    fields = set(UserProfileView.model_fields.keys())
    assert "storage_object_key" not in fields
    assert "document_type" not in fields


def test_document_contracts_remain_unimplemented() -> None:
    assert DOCUMENT_ENDPOINT_CONTRACTS
    assert all(not contract.implemented for contract in DOCUMENT_ENDPOINT_CONTRACTS)


def test_reviewer_document_routes_are_not_owner_accessible() -> None:
    internal = [c for c in DOCUMENT_ENDPOINT_CONTRACTS if "/internal/" in c.path]
    assert internal
    assert all(not c.owner_accessible for c in internal)


def test_document_and_internal_onboarding_routes_not_mounted() -> None:
    from app.main import app

    mounted_paths = [getattr(route, "path", "") for route in app.routes if getattr(route, "path", "")]
    assert not any("/internal/business/onboarding" in path for path in mounted_paths)
    assert not any(
        "/business/onboarding/applications" in path and "/documents" in path for path in mounted_paths
    )


def test_deleting_application_cascades_documents(session: Session) -> None:
    owner = _user(session)
    application = _application(session, owner)
    session.add(
        BusinessOnboardingDocument(
            application_id=application.id,
            uploaded_by_user_id=owner.id,
            document_type=BusinessOnboardingDocumentType.REGISTRATION_CERTIFICATE.value,
            storage_object_key="private/onboarding/cascade-test",
        ),
    )
    session.commit()
    session.delete(application)
    session.commit()
    assert session.scalars(select(BusinessOnboardingDocument)).all() == []

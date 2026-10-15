"""Dry-run reconciliation service tests."""

from __future__ import annotations

import uuid

import pytest
from sqlalchemy import create_engine
from sqlalchemy.orm import Session

from app.db.base import Base
from app.db.models import User
from app.db.models.business_onboarding import BusinessOnboardingApplication, BusinessOnboardingDocument
from app.domain.business_onboarding_documents import BusinessOnboardingDocumentLifecycle
from app.services.business_onboarding.document_service import build_storage_object_key
from app.services.business_onboarding.reconciliation_service import ReconciliationAnomalyKind
from app.services.business_onboarding.reconciliation_service import (
    reconcile_onboarding_documents_dry_run,
)
from tests.support.memory_object_storage import MemoryObjectStorage

_MINIMAL_PDF = b"%PDF-1.4\n"


def _document(session: Session, *, lifecycle: str, byte_size: int | None = None) -> BusinessOnboardingDocument:
    owner = User(phone_e164="+998901234599")
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
        lifecycle_state=lifecycle,
        byte_size=byte_size,
        checksum_sha256="a" * 64 if byte_size is not None else None,
    )
    session.add(document)
    session.commit()
    return document


def test_db_uploaded_storage_missing_detected() -> None:
    engine = create_engine("sqlite://")
    Base.metadata.create_all(engine)
    storage = MemoryObjectStorage()
    with Session(engine) as session:
        document = _document(
            session,
            lifecycle=BusinessOnboardingDocumentLifecycle.UPLOADED_PENDING_VALIDATION.value,
            byte_size=10,
        )
        report = reconcile_onboarding_documents_dry_run(session, storage)
        assert report.counts_by_kind[ReconciliationAnomalyKind.DB_UPLOADED_STORAGE_MISSING.value] == 1
        assert str(document.id) in report.document_ids_by_kind[
            ReconciliationAnomalyKind.DB_UPLOADED_STORAGE_MISSING.value
        ]


def test_db_awaiting_with_storage_present_detected() -> None:
    engine = create_engine("sqlite://")
    Base.metadata.create_all(engine)
    storage = MemoryObjectStorage()
    with Session(engine) as session:
        document = _document(session, lifecycle=BusinessOnboardingDocumentLifecycle.AWAITING_UPLOAD.value)
        storage.put(document.storage_object_key, _MINIMAL_PDF)
        report = reconcile_onboarding_documents_dry_run(session, storage)
        assert report.counts_by_kind[ReconciliationAnomalyKind.DB_AWAITING_STORAGE_PRESENT.value] == 1


def test_byte_size_mismatch_detected() -> None:
    engine = create_engine("sqlite://")
    Base.metadata.create_all(engine)
    storage = MemoryObjectStorage()
    with Session(engine) as session:
        document = _document(
            session,
            lifecycle=BusinessOnboardingDocumentLifecycle.UPLOADED_PENDING_VALIDATION.value,
            byte_size=10,
        )
        storage.put(document.storage_object_key, b"%PDF-longer")
        report = reconcile_onboarding_documents_dry_run(session, storage)
        assert report.counts_by_kind[ReconciliationAnomalyKind.BYTE_SIZE_MISMATCH.value] == 1


def test_storage_orphan_detected() -> None:
    engine = create_engine("sqlite://")
    Base.metadata.create_all(engine)
    storage = MemoryObjectStorage()
    orphan_key = f"private/onboarding/{uuid.uuid4()}/{uuid.uuid4()}"
    storage.put(orphan_key, _MINIMAL_PDF)
    with Session(engine) as session:
        report = reconcile_onboarding_documents_dry_run(session, storage)
        assert report.counts_by_kind[ReconciliationAnomalyKind.STORAGE_ORPHAN_UNMATCHED.value] >= 1


def test_dry_run_report_excludes_storage_keys() -> None:
    engine = create_engine("sqlite://")
    Base.metadata.create_all(engine)
    storage = MemoryObjectStorage()
    with Session(engine) as session:
        _document(
            session,
            lifecycle=BusinessOnboardingDocumentLifecycle.UPLOADED_PENDING_VALIDATION.value,
            byte_size=5,
        )
        report = reconcile_onboarding_documents_dry_run(session, storage)
        payload = str(report.to_public_dict())
        assert "private/onboarding/" not in payload


def test_partial_storage_head_failure_marks_report_incomplete() -> None:
    from app.services.object_storage.errors import StorageOperationError

    engine = create_engine("sqlite://")
    Base.metadata.create_all(engine)

    class FlakyStorage(MemoryObjectStorage):
        def head(self, key: str):
            raise StorageOperationError("storage unavailable")

    storage = FlakyStorage()
    with Session(engine) as session:
        _document(
            session,
            lifecycle=BusinessOnboardingDocumentLifecycle.UPLOADED_PENDING_VALIDATION.value,
            byte_size=4,
        )
        report = reconcile_onboarding_documents_dry_run(session, storage)
        assert report.complete is False
        assert "storage_head_failed" in report.errors

"""Read-only DB/storage reconciliation for onboarding documents (dry-run)."""

from __future__ import annotations

import uuid
from dataclasses import dataclass, field
from enum import StrEnum

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.db.models.business_onboarding import BusinessOnboardingDocument
from app.domain.business_onboarding_documents import BusinessOnboardingDocumentLifecycle
from app.services.business_onboarding.document_service import build_storage_object_key
from app.services.object_storage.document_keys import parse_onboarding_document_object_key
from app.services.object_storage.errors import StorageError, StorageObjectNotFoundError
from app.services.object_storage.port import StoragePort

DOCUMENT_LIST_BATCH_SIZE = 200
STORAGE_LIST_BATCH_SIZE = 500
MAX_REPORTED_DOCUMENT_IDS = 100


class ReconciliationAnomalyKind(StrEnum):
    DB_UPLOADED_STORAGE_MISSING = "db_uploaded_storage_missing"
    DB_AWAITING_STORAGE_PRESENT = "db_awaiting_storage_present"
    STORAGE_ORPHAN_UNMATCHED = "storage_orphan_unmatched"
    BYTE_SIZE_MISMATCH = "byte_size_mismatch"


@dataclass(frozen=True, slots=True)
class ReconciliationReport:
    run_id: uuid.UUID
    complete: bool
    documents_examined: int
    storage_keys_examined: int
    counts_by_kind: dict[str, int]
    document_ids_by_kind: dict[str, tuple[str, ...]]
    errors: tuple[str, ...] = field(default_factory=tuple)

    def to_public_dict(self) -> dict[str, object]:
        return {
            "run_id": str(self.run_id),
            "complete": self.complete,
            "documents_examined": self.documents_examined,
            "storage_keys_examined": self.storage_keys_examined,
            "counts_by_kind": dict(self.counts_by_kind),
            "document_ids_by_kind": {
                kind: list(document_ids) for kind, document_ids in self.document_ids_by_kind.items()
            },
            "errors": list(self.errors),
        }


def _append_document_id(
    bucket: dict[str, list[str]],
    kind: ReconciliationAnomalyKind,
    document_id: uuid.UUID,
) -> None:
    items = bucket.setdefault(kind.value, [])
    if len(items) < MAX_REPORTED_DOCUMENT_IDS:
        items.append(str(document_id))


def reconcile_onboarding_documents_dry_run(
    session: Session,
    storage: StoragePort,
    *,
    run_id: uuid.UUID | None = None,
) -> ReconciliationReport:
    """Compare DB metadata with storage; never mutates DB or storage."""

    run = run_id or uuid.uuid4()
    counts: dict[str, int] = {kind.value: 0 for kind in ReconciliationAnomalyKind}
    document_ids: dict[str, list[str]] = {}
    errors: list[str] = []
    documents_examined = 0
    storage_keys_examined = 0
    complete = True

    last_document_id: uuid.UUID | None = None
    while True:
        stmt = select(BusinessOnboardingDocument).order_by(BusinessOnboardingDocument.id.asc())
        if last_document_id is not None:
            stmt = stmt.where(BusinessOnboardingDocument.id > last_document_id)
        stmt = stmt.limit(DOCUMENT_LIST_BATCH_SIZE)
        batch = list(session.scalars(stmt).all())
        if not batch:
            break

        for document in batch:
            documents_examined += 1
            last_document_id = document.id
            if document.lifecycle_state == BusinessOnboardingDocumentLifecycle.DELETED.value:
                continue

            expected_key = build_storage_object_key(document.application_id, document.id)
            lifecycle = BusinessOnboardingDocumentLifecycle(document.lifecycle_state)
            try:
                head = storage.head(expected_key)
            except StorageObjectNotFoundError:
                if lifecycle == BusinessOnboardingDocumentLifecycle.UPLOADED_PENDING_VALIDATION:
                    counts[ReconciliationAnomalyKind.DB_UPLOADED_STORAGE_MISSING.value] += 1
                    _append_document_id(document_ids, ReconciliationAnomalyKind.DB_UPLOADED_STORAGE_MISSING, document.id)
                continue
            except StorageError:
                complete = False
                errors.append("storage_head_failed")
                continue

            if lifecycle == BusinessOnboardingDocumentLifecycle.AWAITING_UPLOAD:
                counts[ReconciliationAnomalyKind.DB_AWAITING_STORAGE_PRESENT.value] += 1
                _append_document_id(document_ids, ReconciliationAnomalyKind.DB_AWAITING_STORAGE_PRESENT, document.id)
                continue

            if (
                lifecycle == BusinessOnboardingDocumentLifecycle.UPLOADED_PENDING_VALIDATION
                and document.byte_size is not None
                and head.byte_size != document.byte_size
            ):
                counts[ReconciliationAnomalyKind.BYTE_SIZE_MISMATCH.value] += 1
                _append_document_id(document_ids, ReconciliationAnomalyKind.BYTE_SIZE_MISMATCH, document.id)

    db_pairs: set[tuple[uuid.UUID, uuid.UUID]] = set()
    offset_id: uuid.UUID | None = None
    while True:
        stmt = select(BusinessOnboardingDocument.id, BusinessOnboardingDocument.application_id).order_by(
            BusinessOnboardingDocument.id.asc(),
        )
        if offset_id is not None:
            stmt = stmt.where(BusinessOnboardingDocument.id > offset_id)
        stmt = stmt.limit(DOCUMENT_LIST_BATCH_SIZE)
        rows = session.execute(stmt).all()
        if not rows:
            break
        for document_id, application_id in rows:
            offset_id = document_id
            db_pairs.add((application_id, document_id))

    cursor: str | None = None
    while True:
        try:
            page = storage.list_prefix(
                "private/onboarding",
                limit=STORAGE_LIST_BATCH_SIZE,
                cursor=cursor,
            )
        except StorageError:
            complete = False
            errors.append("storage_list_failed")
            break

        for key in page.keys:
            storage_keys_examined += 1
            parsed = parse_onboarding_document_object_key(key)
            if parsed is None:
                counts[ReconciliationAnomalyKind.STORAGE_ORPHAN_UNMATCHED.value] += 1
                continue
            application_id, document_id = parsed
            if (application_id, document_id) not in db_pairs:
                counts[ReconciliationAnomalyKind.STORAGE_ORPHAN_UNMATCHED.value] += 1
                _append_document_id(
                    document_ids,
                    ReconciliationAnomalyKind.STORAGE_ORPHAN_UNMATCHED,
                    document_id,
                )
                continue

        if page.next_cursor is None:
            break
        cursor = page.next_cursor

    return ReconciliationReport(
        run_id=run,
        complete=complete,
        documents_examined=documents_examined,
        storage_keys_examined=storage_keys_examined,
        counts_by_kind=counts,
        document_ids_by_kind={kind: tuple(ids) for kind, ids in document_ids.items()},
        errors=tuple(errors),
    )

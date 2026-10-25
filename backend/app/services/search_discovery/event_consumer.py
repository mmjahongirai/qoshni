"""In-process search index projection consumer (no message broker)."""

from __future__ import annotations

import uuid
from dataclasses import dataclass

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.db.models.business_onboarding import BusinessOnboardingApplication
from app.db.models.search_discovery import SearchIndexProjectionReceipt
from app.services.search_discovery.projector import project_application


@dataclass(frozen=True, slots=True)
class SearchIndexProjectionEvent:
    event_id: uuid.UUID
    application_id: uuid.UUID


def consume_search_index_projection_event(
    session: Session,
    event: SearchIndexProjectionEvent,
) -> bool:
    """Apply projection idempotently. Returns True when newly processed."""

    existing = session.get(SearchIndexProjectionReceipt, event.event_id)
    if existing is not None:
        return False

    application = session.get(BusinessOnboardingApplication, event.application_id)
    if application is None:
        receipt = SearchIndexProjectionReceipt(
            event_id=event.event_id,
            stable_id=f"missing:{event.application_id}",
        )
        session.add(receipt)
        session.flush()
        return True

    stable_id = project_application(session, application) or f"removed:{application.id}"
    session.add(
        SearchIndexProjectionReceipt(
            event_id=event.event_id,
            stable_id=stable_id,
        )
    )
    session.flush()
    return True


def list_projection_receipts(session: Session) -> list[SearchIndexProjectionReceipt]:
    return list(session.scalars(select(SearchIndexProjectionReceipt)).all())

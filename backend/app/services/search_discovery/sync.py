"""Synchronous hooks from authoritative domains into the search read model."""

from __future__ import annotations

import uuid

from sqlalchemy.orm import Session

from app.db.models.business_onboarding import BusinessOnboardingApplication
from app.services.search_discovery.projector import project_application, seed_category_rows


def sync_search_index_for_application(
    session: Session,
    application: BusinessOnboardingApplication,
) -> None:
    """Project one application in the same DB transaction (no message broker)."""

    project_application(session, application)
    seed_category_rows(session)

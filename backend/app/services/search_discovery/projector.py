"""Project onboarding applications into the search read model."""

from __future__ import annotations

import uuid
from datetime import datetime

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.db.models.business_onboarding import BusinessOnboardingApplication
from app.db.models.search_discovery import SearchIndexRecord, eligibility_from_verification_status
from app.domain.business_onboarding import VerificationStatus
from app.domain.search_discovery import SearchIndexEligibility, SearchIndexRecordKind
from app.services.search_discovery.branch_coordinate_projection import (
    sync_branch_coordinates_to_search_index,
)
from app.services.search_discovery.metadata import bump_catalog_generation


def stable_id_for_application(application_id: uuid.UUID) -> str:
    return f"business:onboarding:{application_id}"


def _display_title(application: BusinessOnboardingApplication) -> str:
    trade = (application.trade_display_name or "").strip()
    if trade:
        return trade
    legal = (application.legal_business_name or "").strip()
    return legal or "Business"


def project_application(
    session: Session,
    application: BusinessOnboardingApplication,
    *,
    bump_generation: bool = True,
) -> str | None:
    """Upsert or remove index row for one application. Returns stable_id if indexed."""

    stable_id = stable_id_for_application(application.id)
    eligibility = eligibility_from_verification_status(application.verification_status)
    if eligibility == SearchIndexEligibility.INELIGIBLE:
        existing = session.get(SearchIndexRecord, stable_id)
        if existing is not None:
            session.delete(existing)
            if bump_generation:
                bump_catalog_generation(session)
        return None

    source_updated = application.updated_at or application.created_at
    existing = session.get(SearchIndexRecord, stable_id)
    if existing is not None and existing.source_updated_at is not None:
        if source_updated is not None and source_updated < existing.source_updated_at:
            return stable_id

    subtitle = application.service_category or ""
    row = existing or SearchIndexRecord(
        stable_id=stable_id,
        kind=SearchIndexRecordKind.BUSINESS.value,
        title=_display_title(application),
        subtitle=subtitle,
        category_scope=application.service_category,
        eligibility_status=eligibility.value,
        source_application_id=application.id,
        source_updated_at=source_updated,
    )
    if existing is None:
        session.add(row)
    else:
        row.title = _display_title(application)
        row.subtitle = subtitle
        row.category_scope = application.service_category
        row.eligibility_status = eligibility.value
        row.source_updated_at = source_updated

    if bump_generation:
        bump_catalog_generation(session)
    session.flush()
    sync_branch_coordinates_to_search_index(
        session,
        application.id,
        bump_generation=False,
    )
    return stable_id


def seed_category_rows(session: Session) -> None:
    """Static category rows aligned with Flutter ServiceCategoryId names."""

    from app.domain.business_onboarding import BusinessServiceCategory

    labels = {
        BusinessServiceCategory.PHARMACY: "Pharmacy",
        BusinessServiceCategory.GROCERIES: "Groceries",
        BusinessServiceCategory.RESTAURANTS: "Restaurants",
        BusinessServiceCategory.SHOPS: "Shops",
        BusinessServiceCategory.MASTERS: "Masters",
        BusinessServiceCategory.RENT: "Rent",
    }
    changed = False
    for category, label in labels.items():
        stable_id = f"category:{category.value}"
        existing = session.get(SearchIndexRecord, stable_id)
        if existing is None:
            session.add(
                SearchIndexRecord(
                    stable_id=stable_id,
                    kind=SearchIndexRecordKind.CATEGORY.value,
                    title=label,
                    subtitle="Category",
                    category_scope=category.value,
                    eligibility_status=SearchIndexEligibility.ELIGIBLE.value,
                    source_application_id=None,
                    source_updated_at=None,
                )
            )
            changed = True
    if changed:
        bump_catalog_generation(session)
        session.flush()


def rebuild_from_verified_applications(session: Session) -> int:
    """Rebuild business rows from verified/suspended onboarding applications."""

    rows = session.scalars(select(BusinessOnboardingApplication)).all()
    count = 0
    for application in rows:
        status = VerificationStatus(application.verification_status)
        if status in {VerificationStatus.VERIFIED, VerificationStatus.SUSPENDED}:
            project_application(session, application, bump_generation=False)
            count += 1
    seed_category_rows(session)
    bump_catalog_generation(session)
    return count

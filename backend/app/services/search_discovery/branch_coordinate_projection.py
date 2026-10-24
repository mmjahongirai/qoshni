"""Project verified branch coordinates into the search read model."""

from __future__ import annotations

import uuid

from sqlalchemy.orm import Session

from app.db.models.branch_coordinates import BusinessOnboardingBranchCoordinate
from app.db.models.business_onboarding import BusinessOnboardingApplication
from app.db.models.search_discovery import SearchIndexRecord
from app.domain.branch_coordinates import BranchCoordinateVerificationStatus
from app.domain.business_onboarding import VerificationStatus
from app.domain.search_discovery import SearchIndexEligibility
from app.services.search_discovery.metadata import bump_catalog_generation
from app.services.search_discovery.projector import stable_id_for_application


def sync_branch_coordinates_to_search_index(
    session: Session,
    application_id: uuid.UUID,
    *,
    bump_generation: bool = True,
) -> None:
    stable_id = stable_id_for_application(application_id)
    index_row = session.get(SearchIndexRecord, stable_id)
    if index_row is None:
        return

    application = session.get(BusinessOnboardingApplication, application_id)
    coord = session.get(BusinessOnboardingBranchCoordinate, application_id)

    should_publish = (
        application is not None
        and VerificationStatus(application.verification_status) == VerificationStatus.VERIFIED
        and index_row.eligibility_status == SearchIndexEligibility.ELIGIBLE.value
        and coord is not None
        and coord.verification_status == BranchCoordinateVerificationStatus.VERIFIED.value
        and coord.verified_revision == coord.revision
    )

    if should_publish:
        index_row.branch_latitude = coord.latitude
        index_row.branch_longitude = coord.longitude
        index_row.branch_coordinate_revision = coord.revision
    else:
        index_row.branch_latitude = None
        index_row.branch_longitude = None
        index_row.branch_coordinate_revision = None

    if bump_generation:
        bump_catalog_generation(session)
    session.flush()

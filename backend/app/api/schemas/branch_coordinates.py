"""Branch coordinate API schemas."""

from __future__ import annotations

from datetime import datetime
from uuid import UUID

from pydantic import BaseModel, Field

from app.domain.branch_coordinates import BranchCoordinateSource, BranchCoordinateVerificationStatus


class BranchCoordinateView(BaseModel):
    application_id: UUID
    latitude: float
    longitude: float
    coordinate_source: BranchCoordinateSource
    verification_status: BranchCoordinateVerificationStatus
    revision: int
    verified_revision: int | None = None
    verified_at: datetime | None = None
    proposed_at: datetime
    updated_at: datetime


class BranchCoordinateProposeRequest(BaseModel):
    latitude: float
    longitude: float
    coordinate_source: BranchCoordinateSource = BranchCoordinateSource.OWNER_CONFIRMED_PIN
    expected_revision: int | None = None

"""Authoritative branch coordinates for verified onboarding applications."""

from __future__ import annotations

import uuid
from datetime import datetime

from sqlalchemy import (
    CheckConstraint,
    DateTime,
    Float,
    ForeignKey,
    Integer,
    String,
    Uuid,
    func,
)
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base
from enum import StrEnum

from app.domain.branch_coordinates import (
    MAX_LATITUDE,
    MAX_LONGITUDE,
    MIN_LATITUDE,
    MIN_LONGITUDE,
    BranchCoordinateSource,
    BranchCoordinateVerificationStatus,
)


def _in_values(column: str, enum_type: type[StrEnum]) -> str:
    values = ", ".join(f"'{member.value}'" for member in enum_type)
    return f"{column} IN ({values})"


class BusinessOnboardingBranchCoordinate(Base):
    """One coordinate record per onboarding application (primary public branch)."""

    __tablename__ = "business_onboarding_branch_coordinates"
    __table_args__ = (
        CheckConstraint(
            f"latitude >= {MIN_LATITUDE} AND latitude <= {MAX_LATITUDE}",
            name="branch_coordinate_latitude_valid",
        ),
        CheckConstraint(
            f"longitude >= {MIN_LONGITUDE} AND longitude <= {MAX_LONGITUDE}",
            name="branch_coordinate_longitude_valid",
        ),
        CheckConstraint(
            _in_values("coordinate_source", BranchCoordinateSource),
            name="branch_coordinate_source_valid",
        ),
        CheckConstraint(
            _in_values("verification_status", BranchCoordinateVerificationStatus),
            name="branch_coordinate_verification_valid",
        ),
    )

    application_id: Mapped[uuid.UUID] = mapped_column(
        Uuid,
        ForeignKey("business_onboarding_applications.id", ondelete="CASCADE"),
        primary_key=True,
    )
    latitude: Mapped[float] = mapped_column(Float, nullable=False)
    longitude: Mapped[float] = mapped_column(Float, nullable=False)
    coordinate_source: Mapped[str] = mapped_column(String(32), nullable=False)
    verification_status: Mapped[str] = mapped_column(String(16), nullable=False)
    revision: Mapped[int] = mapped_column(Integer, nullable=False, default=1, server_default="1")
    verified_revision: Mapped[int | None] = mapped_column(Integer, nullable=True)
    verified_by_user_id: Mapped[uuid.UUID | None] = mapped_column(Uuid, nullable=True)
    verified_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    proposed_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        server_default=func.now(),
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        server_default=func.now(),
        onupdate=func.now(),
    )

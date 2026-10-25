"""Derived search index read model (PostgreSQL / SQLite in tests)."""

from __future__ import annotations

import uuid
from datetime import datetime

from sqlalchemy import DateTime, Float, Index, Integer, String, Uuid, func  # noqa: F401 — Integer used by branch_coordinate_revision
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base
from app.domain.search_discovery import SearchIndexEligibility, SearchIndexRecordKind


class SearchIndexMetadata(Base):
    """Singleton metadata row for catalog generation bumps."""

    __tablename__ = "search_index_metadata"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    catalog_generation: Mapped[int] = mapped_column(Integer, nullable=False, default=1)
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        server_default=func.now(),
        onupdate=func.now(),
    )


class SearchIndexRecord(Base):
    """Denormalized searchable row — authoritative onboarding remains source of truth."""

    __tablename__ = "search_index_records"
    __table_args__ = (
        Index("ix_search_index_records_eligibility_stable_id", "eligibility_status", "stable_id"),
        Index("ix_search_index_records_category", "category_scope"),
    )

    stable_id: Mapped[str] = mapped_column(String(160), primary_key=True)
    kind: Mapped[str] = mapped_column(String(32), nullable=False)
    title: Mapped[str] = mapped_column(String(256), nullable=False)
    subtitle: Mapped[str] = mapped_column(String(512), nullable=False, default="")
    category_scope: Mapped[str | None] = mapped_column(String(32), nullable=True)
    eligibility_status: Mapped[str] = mapped_column(String(32), nullable=False)
    source_application_id: Mapped[uuid.UUID | None] = mapped_column(Uuid(), nullable=True)
    source_updated_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    branch_latitude: Mapped[float | None] = mapped_column(Float, nullable=True)
    branch_longitude: Mapped[float | None] = mapped_column(Float, nullable=True)
    branch_coordinate_revision: Mapped[int | None] = mapped_column(Integer, nullable=True)
    created_at: Mapped[datetime] = mapped_column(
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


class SearchIndexProjectionReceipt(Base):
    """Idempotent onboarding → index projection receipts."""

    __tablename__ = "search_index_projection_receipts"

    event_id: Mapped[uuid.UUID] = mapped_column(Uuid(), primary_key=True)
    stable_id: Mapped[str] = mapped_column(String(160), nullable=False)
    processed_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        server_default=func.now(),
    )


def eligibility_from_verification_status(status: str) -> SearchIndexEligibility:
    if status == "verified":
        return SearchIndexEligibility.ELIGIBLE
    if status == "suspended":
        return SearchIndexEligibility.SUSPENDED
    return SearchIndexEligibility.INELIGIBLE

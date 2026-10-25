"""User-owned saved places — separate from business branch coordinates."""

from __future__ import annotations

import uuid
from datetime import datetime

from sqlalchemy import CheckConstraint, DateTime, Float, ForeignKey, String, Uuid, func
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base
from app.domain.saved_places import (
    MAX_LATITUDE,
    MAX_LONGITUDE,
    MIN_LATITUDE,
    MIN_LONGITUDE,
    SAVED_PLACE_ADDRESS_MAX_LENGTH,
    SAVED_PLACE_LABEL_MAX_LENGTH,
)


class UserSavedPlace(Base):
    __tablename__ = "user_saved_places"
    __table_args__ = (
        CheckConstraint(
            "length(trim(label)) > 0",
            name="saved_place_label_not_blank",
        ),
        CheckConstraint(
            f"latitude >= {MIN_LATITUDE} AND latitude <= {MAX_LATITUDE}",
            name="saved_place_latitude_valid",
        ),
        CheckConstraint(
            f"longitude >= {MIN_LONGITUDE} AND longitude <= {MAX_LONGITUDE}",
            name="saved_place_longitude_valid",
        ),
    )

    id: Mapped[uuid.UUID] = mapped_column(Uuid, primary_key=True, default=uuid.uuid4)
    user_id: Mapped[uuid.UUID] = mapped_column(
        Uuid,
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    label: Mapped[str] = mapped_column(String(SAVED_PLACE_LABEL_MAX_LENGTH), nullable=False)
    address_description: Mapped[str | None] = mapped_column(
        String(SAVED_PLACE_ADDRESS_MAX_LENGTH),
        nullable=True,
    )
    latitude: Mapped[float] = mapped_column(Float, nullable=False)
    longitude: Mapped[float] = mapped_column(Float, nullable=False)
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

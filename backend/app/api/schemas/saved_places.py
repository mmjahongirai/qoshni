"""Saved places API schemas."""

from __future__ import annotations

from datetime import datetime
from uuid import UUID

from pydantic import BaseModel, Field

from app.domain.saved_places import SAVED_PLACE_ADDRESS_MAX_LENGTH, SAVED_PLACE_LABEL_MAX_LENGTH


class SavedPlaceView(BaseModel):
    id: UUID
    label: str
    latitude: float
    longitude: float
    address_description: str | None = None
    created_at: datetime
    updated_at: datetime


class SavedPlaceCreateRequest(BaseModel):
    label: str = Field(min_length=1, max_length=SAVED_PLACE_LABEL_MAX_LENGTH)
    latitude: float
    longitude: float
    address_description: str | None = Field(default=None, max_length=SAVED_PLACE_ADDRESS_MAX_LENGTH)


class SavedPlaceUpdateRequest(BaseModel):
    label: str | None = Field(default=None, min_length=1, max_length=SAVED_PLACE_LABEL_MAX_LENGTH)
    latitude: float | None = None
    longitude: float | None = None
    address_description: str | None = Field(default=None, max_length=SAVED_PLACE_ADDRESS_MAX_LENGTH)
    clear_address_description: bool = False


class SavedPlaceErrorDetail(BaseModel):
    code: str
    message: str


class SavedPlaceErrorResponse(BaseModel):
    error: SavedPlaceErrorDetail

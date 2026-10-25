"""CRUD for user-scoped saved places."""

from __future__ import annotations

import uuid
from dataclasses import dataclass
from enum import StrEnum

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.db.models.saved_places import UserSavedPlace
from app.domain.saved_places import (
    MAX_LATITUDE,
    MAX_LONGITUDE,
    MIN_LATITUDE,
    MIN_LONGITUDE,
    SAVED_PLACE_ADDRESS_MAX_LENGTH,
    SAVED_PLACE_LABEL_MAX_LENGTH,
)


class SavedPlaceErrorCode(StrEnum):
    NOT_FOUND = "not_found"
    VALIDATION_FAILED = "validation_failed"
    FORBIDDEN = "forbidden"


@dataclass(frozen=True, slots=True)
class SavedPlaceServiceError:
    code: SavedPlaceErrorCode
    message: str


def _validate_coordinates(latitude: float, longitude: float) -> SavedPlaceServiceError | None:
    if not (MIN_LATITUDE <= latitude <= MAX_LATITUDE):
        return SavedPlaceServiceError(
            code=SavedPlaceErrorCode.VALIDATION_FAILED,
            message="Latitude is out of range.",
        )
    if not (MIN_LONGITUDE <= longitude <= MAX_LONGITUDE):
        return SavedPlaceServiceError(
            code=SavedPlaceErrorCode.VALIDATION_FAILED,
            message="Longitude is out of range.",
        )
    return None


def _validate_label(label: str) -> SavedPlaceServiceError | None:
    trimmed = label.strip()
    if not trimmed:
        return SavedPlaceServiceError(
            code=SavedPlaceErrorCode.VALIDATION_FAILED,
            message="Label is required.",
        )
    if len(trimmed) > SAVED_PLACE_LABEL_MAX_LENGTH:
        return SavedPlaceServiceError(
            code=SavedPlaceErrorCode.VALIDATION_FAILED,
            message="Label is too long.",
        )
    return None


def _validate_address(address: str | None) -> SavedPlaceServiceError | None:
    if address is None:
        return None
    if len(address) > SAVED_PLACE_ADDRESS_MAX_LENGTH:
        return SavedPlaceServiceError(
            code=SavedPlaceErrorCode.VALIDATION_FAILED,
            message="Address description is too long.",
        )
    return None


def list_saved_places(session: Session, user_id: uuid.UUID) -> list[UserSavedPlace]:
    return list(
        session.scalars(
            select(UserSavedPlace)
            .where(UserSavedPlace.user_id == user_id)
            .order_by(UserSavedPlace.updated_at.desc())
        ).all()
    )


def create_saved_place(
    session: Session,
    user_id: uuid.UUID,
    *,
    label: str,
    latitude: float,
    longitude: float,
    address_description: str | None = None,
) -> UserSavedPlace | SavedPlaceServiceError:
    label_error = _validate_label(label)
    if label_error is not None:
        return label_error
    coord_error = _validate_coordinates(latitude, longitude)
    if coord_error is not None:
        return coord_error
    address_error = _validate_address(address_description)
    if address_error is not None:
        return address_error

    row = UserSavedPlace(
        user_id=user_id,
        label=label.strip(),
        latitude=latitude,
        longitude=longitude,
        address_description=address_description.strip() if address_description else None,
    )
    session.add(row)
    session.flush()
    return row


def get_saved_place_for_user(
    session: Session,
    user_id: uuid.UUID,
    place_id: uuid.UUID,
) -> UserSavedPlace | SavedPlaceServiceError:
    row = session.get(UserSavedPlace, place_id)
    if row is None:
        return SavedPlaceServiceError(
            code=SavedPlaceErrorCode.NOT_FOUND,
            message="Saved place not found.",
        )
    if row.user_id != user_id:
        return SavedPlaceServiceError(
            code=SavedPlaceErrorCode.NOT_FOUND,
            message="Saved place not found.",
        )
    return row


def update_saved_place(
    session: Session,
    user_id: uuid.UUID,
    place_id: uuid.UUID,
    *,
    label: str | None = None,
    latitude: float | None = None,
    longitude: float | None = None,
    address_description: str | None = None,
    clear_address_description: bool = False,
) -> UserSavedPlace | SavedPlaceServiceError:
    current = get_saved_place_for_user(session, user_id, place_id)
    if isinstance(current, SavedPlaceServiceError):
        return current

    if label is not None:
        label_error = _validate_label(label)
        if label_error is not None:
            return label_error
        current.label = label.strip()

    next_lat = latitude if latitude is not None else current.latitude
    next_lng = longitude if longitude is not None else current.longitude
    coord_error = _validate_coordinates(next_lat, next_lng)
    if coord_error is not None:
        return coord_error
    current.latitude = next_lat
    current.longitude = next_lng

    if clear_address_description:
        current.address_description = None
    elif address_description is not None:
        address_error = _validate_address(address_description)
        if address_error is not None:
            return address_error
        trimmed = address_description.strip()
        current.address_description = trimmed or None

    session.flush()
    return current


def delete_saved_place(
    session: Session,
    user_id: uuid.UUID,
    place_id: uuid.UUID,
) -> None | SavedPlaceServiceError:
    current = get_saved_place_for_user(session, user_id, place_id)
    if isinstance(current, SavedPlaceServiceError):
        return current
    session.delete(current)
    session.flush()
    return None

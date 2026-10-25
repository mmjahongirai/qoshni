"""Trusted branch coordinate vocabulary (Phase 17 WP3)."""

from enum import StrEnum
import math

MIN_LATITUDE = -90.0
MAX_LATITUDE = 90.0
MIN_LONGITUDE = -180.0
MAX_LONGITUDE = 180.0


class BranchCoordinateSource(StrEnum):
    """How coordinates entered the system — not proof of accuracy."""

    MANUAL_MAP_PIN = "manual_map_pin"
    OWNER_CONFIRMED_PIN = "owner_confirmed_pin"


class BranchCoordinateVerificationStatus(StrEnum):
    PROPOSED = "proposed"
    VERIFIED = "verified"
    REJECTED = "rejected"
    REVOKED = "revoked"


def validate_branch_coordinates(latitude: float, longitude: float) -> str | None:
    if not math.isfinite(latitude) or not math.isfinite(longitude):
        return "Coordinates must be finite numbers."
    if latitude < MIN_LATITUDE or latitude > MAX_LATITUDE:
        return "Latitude is out of range."
    if longitude < MIN_LONGITUDE or longitude > MAX_LONGITUDE:
        return "Longitude is out of range."
    return None

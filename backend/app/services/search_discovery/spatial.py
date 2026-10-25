"""Haversine distance — no PostGIS dependency in WP2."""

from __future__ import annotations

import math

_EARTH_RADIUS_METERS = 6_371_000.0


def haversine_meters(
    *,
    origin_latitude: float,
    origin_longitude: float,
    target_latitude: float,
    target_longitude: float,
) -> float:
    phi1 = math.radians(origin_latitude)
    phi2 = math.radians(target_latitude)
    d_phi = math.radians(target_latitude - origin_latitude)
    d_lambda = math.radians(target_longitude - origin_longitude)
    a = (
        math.sin(d_phi / 2) ** 2
        + math.cos(phi1) * math.cos(phi2) * math.sin(d_lambda / 2) ** 2
    )
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
    return _EARTH_RADIUS_METERS * c


def coordinates_are_valid(latitude: float | None, longitude: float | None) -> bool:
    if latitude is None or longitude is None:
        return False
    if not (-90.0 <= latitude <= 90.0 and -180.0 <= longitude <= 180.0):
        return False
    return True

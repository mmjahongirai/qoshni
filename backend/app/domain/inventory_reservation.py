"""Inventory reservation states (authoritative stock required)."""

from enum import StrEnum


class InventoryReservationStatus(StrEnum):
    HELD = "held"
    CONSUMED = "consumed"
    RELEASED = "released"
    EXPIRED = "expired"

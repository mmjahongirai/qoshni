"""Inventory reservation states (authoritative stock required)."""

from datetime import timedelta
from enum import StrEnum

# How long a placement hold reduces sellable stock. The hold is created while
# the order is ``pending_acceptance``. Checkout, cancel, and an owner inventory
# read call ``sweep_stale_reservations``. Operators can also call
# ``POST /internal/inventory/reservation-maintenance``.
INVENTORY_RESERVATION_TTL = timedelta(minutes=15)


class InventoryReservationStatus(StrEnum):
    HELD = "held"
    CONSUMED = "consumed"
    RELEASED = "released"
    EXPIRED = "expired"

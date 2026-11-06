"""Authoritative consumer catalog vocabulary (Phase 18 Closure WP1)."""

from enum import StrEnum

CATALOG_ITEM_STABLE_ID_MAX_LENGTH = 128
CATALOG_ITEM_TITLE_MAX_LENGTH = 256
CATALOG_ITEM_MAX_UNIT_PRICE_MINOR = 1_000_000_000
CATALOG_INITIAL_PRICING_REVISION = 1


class ConsumerCatalogOfferingKind(StrEnum):
    PRODUCT = "product"
    SERVICE = "service"


class ConsumerCatalogItemStatus(StrEnum):
    """Only ``active`` items are priceable; other states fail closed."""

    ACTIVE = "active"
    INACTIVE = "inactive"
    ARCHIVED = "archived"


class ConsumerCatalogInventoryEventKind(StrEnum):
    """Owner-caused on-hand changes. Reservations are not an owner event."""

    OPENED = "opened"
    REPLENISHED = "replenished"
    COUNT_CORRECTED = "count_corrected"


INVENTORY_EVENT_REASON_MAX_LENGTH = 256

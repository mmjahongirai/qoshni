"""Port for authoritative consumer catalog pricing and stock."""

from __future__ import annotations

from dataclasses import dataclass
from typing import Protocol


@dataclass(frozen=True, slots=True)
class CatalogLineAuthority:
    business_stable_id: str
    catalog_item_stable_id: str
    title_snapshot: str
    unit_price_minor: int
    currency_code: str
    available_quantity: int | None
    """``None`` means no authoritative stock source; placement must fail closed."""
    pricing_revision: int = 1


class ConsumerCatalogAuthority(Protocol):
    def is_operational(self) -> bool:
        """True when the backend may price and reserve against real catalog data."""

    def resolve_line(
        self,
        *,
        business_stable_id: str,
        catalog_item_stable_id: str,
        requested_quantity: int,
    ) -> CatalogLineAuthority | None:
        """Return authoritative line data or None when unknown/unpriced."""


class UnavailableConsumerCatalogAuthority:
    """Production default until the SQL catalog is explicitly enabled."""

    def is_operational(self) -> bool:
        return False

    def resolve_line(
        self,
        *,
        business_stable_id: str,
        catalog_item_stable_id: str,
        requested_quantity: int,
    ) -> CatalogLineAuthority | None:
        return None


def default_consumer_catalog_authority() -> ConsumerCatalogAuthority:
    return UnavailableConsumerCatalogAuthority()

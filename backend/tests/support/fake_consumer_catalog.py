"""Test-only consumer catalog authority (never used in production wiring)."""

from __future__ import annotations

from app.domain.checkout_limits import CHECKOUT_CURRENCY_UZS
from app.services.checkout.catalog_authority import CatalogLineAuthority
from app.services.checkout.inventory_reservation_service import InMemoryInventoryLedger, SkuKey


class FakeConsumerCatalogAuthority:
    def __init__(self, ledger: InMemoryInventoryLedger) -> None:
        self._ledger = ledger
        self._titles: dict[tuple[str, str], str] = {}
        self._prices: dict[tuple[str, str], int] = {}

    def seed(
        self,
        *,
        business_stable_id: str,
        catalog_item_stable_id: str,
        title: str,
        unit_price_minor: int,
        stock: int,
    ) -> None:
        key = (business_stable_id, catalog_item_stable_id)
        self._titles[key] = title
        self._prices[key] = unit_price_minor
        self._ledger.seed_stock(
            SkuKey(
                business_stable_id=business_stable_id,
                catalog_item_stable_id=catalog_item_stable_id,
            ),
            stock,
        )

    def is_operational(self) -> bool:
        return True

    def resolve_line(
        self,
        *,
        business_stable_id: str,
        catalog_item_stable_id: str,
        requested_quantity: int,
    ) -> CatalogLineAuthority | None:
        key = (business_stable_id, catalog_item_stable_id)
        if key not in self._prices:
            return None
        sku = SkuKey(
            business_stable_id=business_stable_id,
            catalog_item_stable_id=catalog_item_stable_id,
        )
        available = self._ledger.available(sku)
        return CatalogLineAuthority(
            business_stable_id=business_stable_id,
            catalog_item_stable_id=catalog_item_stable_id,
            title_snapshot=self._titles[key],
            unit_price_minor=self._prices[key],
            currency_code=CHECKOUT_CURRENCY_UZS,
            available_quantity=available,
        )

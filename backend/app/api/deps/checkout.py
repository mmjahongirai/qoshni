"""Checkout/order dependency wiring."""

from app.services.checkout.catalog_authority import (
    ConsumerCatalogAuthority,
    default_consumer_catalog_authority,
)


def get_consumer_catalog_authority() -> ConsumerCatalogAuthority:
    return default_consumer_catalog_authority()

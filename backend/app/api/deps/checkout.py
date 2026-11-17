"""Checkout/order dependency wiring."""

from fastapi import Depends
from sqlalchemy.orm import Session

from app.core.config import Settings, get_settings
from app.core.database import get_db
from app.services.checkout.catalog_authority import (
    ConsumerCatalogAuthority,
    default_consumer_catalog_authority,
)
from app.services.checkout.sql_catalog_authority import SqlConsumerCatalogAuthority


def get_consumer_catalog_authority(
    session: Session = Depends(get_db),
    settings: Settings = Depends(get_settings),
) -> ConsumerCatalogAuthority:
    if not settings.consumer_catalog_enabled:
        return default_consumer_catalog_authority()
    return SqlConsumerCatalogAuthority(session)

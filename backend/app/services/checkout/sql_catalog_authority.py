"""SQL-backed consumer catalog authority (Phase 18 Closure WP1)."""

from __future__ import annotations

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.db.models.business_onboarding import BusinessOnboardingApplication
from app.db.models.consumer_catalog import ConsumerCatalogInventory, ConsumerCatalogItem
from app.domain.business_onboarding import VerificationStatus
from app.domain.checkout_limits import CHECKOUT_CURRENCY_UZS
from app.domain.consumer_catalog import ConsumerCatalogItemStatus
from app.services.checkout.catalog_authority import CatalogLineAuthority
from app.services.search_discovery.stable_ids import application_id_from_stable_id


class SqlConsumerCatalogAuthority:
    """Prices lines only from active offerings of currently verified businesses.

    ``available_quantity`` is on-hand minus reserved when a balance row exists.
    A missing balance row stays ``None`` so placement fails closed instead of
    treating the item as zero or unlimited.
    """

    def __init__(self, session: Session) -> None:
        self._session = session

    def is_operational(self) -> bool:
        return True

    def resolve_line(
        self,
        *,
        business_stable_id: str,
        catalog_item_stable_id: str,
        requested_quantity: int,
    ) -> CatalogLineAuthority | None:
        application_id = application_id_from_stable_id(business_stable_id)
        if application_id is None:
            return None
        row = self._session.execute(
            select(ConsumerCatalogItem, ConsumerCatalogInventory)
            .join(
                BusinessOnboardingApplication,
                BusinessOnboardingApplication.id == ConsumerCatalogItem.business_application_id,
            )
            .outerjoin(
                ConsumerCatalogInventory,
                ConsumerCatalogInventory.catalog_item_id == ConsumerCatalogItem.id,
            )
            .where(
                ConsumerCatalogItem.business_application_id == application_id,
                ConsumerCatalogItem.catalog_item_stable_id == catalog_item_stable_id,
                ConsumerCatalogItem.status == ConsumerCatalogItemStatus.ACTIVE.value,
                ConsumerCatalogItem.currency_code == CHECKOUT_CURRENCY_UZS,
                BusinessOnboardingApplication.verification_status
                == VerificationStatus.VERIFIED.value,
            )
        ).one_or_none()
        if row is None:
            return None
        item, balance = row
        available = None
        if balance is not None:
            available = balance.quantity_on_hand - balance.reserved_quantity
        return CatalogLineAuthority(
            business_stable_id=business_stable_id,
            catalog_item_stable_id=item.catalog_item_stable_id,
            title_snapshot=item.title,
            unit_price_minor=item.unit_price_minor,
            currency_code=item.currency_code,
            available_quantity=available,
            pricing_revision=item.pricing_revision,
        )

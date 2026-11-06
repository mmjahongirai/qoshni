"""Owner-scoped writes to the authoritative consumer catalog."""

from __future__ import annotations

import uuid
from dataclasses import dataclass
from enum import StrEnum

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.db.models.business_onboarding import BusinessOnboardingApplication
from app.db.models.consumer_catalog import ConsumerCatalogItem
from app.domain.business_onboarding import VerificationStatus
from app.domain.checkout_limits import CHECKOUT_CURRENCY_UZS
from app.domain.consumer_catalog import (
    CATALOG_INITIAL_PRICING_REVISION,
    CATALOG_ITEM_MAX_UNIT_PRICE_MINOR,
    CATALOG_ITEM_STABLE_ID_MAX_LENGTH,
    CATALOG_ITEM_TITLE_MAX_LENGTH,
    ConsumerCatalogItemStatus,
    ConsumerCatalogOfferingKind,
)


class ConsumerCatalogWriteErrorCode(StrEnum):
    VALIDATION_FAILED = "validation_failed"
    BUSINESS_NOT_FOUND = "business_not_found"
    BUSINESS_NOT_VERIFIED = "business_not_verified"
    CATALOG_ITEM_EXISTS = "catalog_item_exists"
    CATALOG_ITEM_NOT_FOUND = "catalog_item_not_found"


@dataclass(frozen=True, slots=True)
class ConsumerCatalogWriteError:
    code: ConsumerCatalogWriteErrorCode
    message: str


def upsert_catalog_offering(
    session: Session,
    *,
    owner_user_id: uuid.UUID,
    business_application_id: uuid.UUID,
    catalog_item_stable_id: str,
    offering_kind: ConsumerCatalogOfferingKind,
    title: str,
    unit_price_minor: int,
    status: ConsumerCatalogItemStatus = ConsumerCatalogItemStatus.ACTIVE,
) -> ConsumerCatalogItem | ConsumerCatalogWriteError:
    """Create or update an offering; any price change bumps ``pricing_revision``.

    Ownership is enforced by ``owner_user_id``: a non-owner gets the same
    ``business_not_found`` as a missing business, so ownership is not disclosed.
    """
    item_id = catalog_item_stable_id.strip()
    clean_title = title.strip()
    if not item_id or len(item_id) > CATALOG_ITEM_STABLE_ID_MAX_LENGTH:
        return ConsumerCatalogWriteError(
            code=ConsumerCatalogWriteErrorCode.VALIDATION_FAILED,
            message="Catalog item identifier is invalid.",
        )
    if not clean_title or len(clean_title) > CATALOG_ITEM_TITLE_MAX_LENGTH:
        return ConsumerCatalogWriteError(
            code=ConsumerCatalogWriteErrorCode.VALIDATION_FAILED,
            message="Catalog item title is invalid.",
        )
    if (
        isinstance(unit_price_minor, bool)
        or not isinstance(unit_price_minor, int)
        or unit_price_minor < 0
        or unit_price_minor > CATALOG_ITEM_MAX_UNIT_PRICE_MINOR
    ):
        return ConsumerCatalogWriteError(
            code=ConsumerCatalogWriteErrorCode.VALIDATION_FAILED,
            message="Unit price must be a non-negative integer amount of UZS.",
        )

    application = session.get(BusinessOnboardingApplication, business_application_id)
    if application is None or application.owner_user_id != owner_user_id:
        return ConsumerCatalogWriteError(
            code=ConsumerCatalogWriteErrorCode.BUSINESS_NOT_FOUND,
            message="Business not found.",
        )
    if application.verification_status != VerificationStatus.VERIFIED.value:
        return ConsumerCatalogWriteError(
            code=ConsumerCatalogWriteErrorCode.BUSINESS_NOT_VERIFIED,
            message="Only verified businesses can publish catalog offerings.",
        )

    existing = session.execute(
        select(ConsumerCatalogItem).where(
            ConsumerCatalogItem.business_application_id == business_application_id,
            ConsumerCatalogItem.catalog_item_stable_id == item_id,
        )
    ).scalar_one_or_none()
    if existing is None:
        item = ConsumerCatalogItem(
            business_application_id=business_application_id,
            catalog_item_stable_id=item_id,
            offering_kind=offering_kind.value,
            title=clean_title,
            unit_price_minor=unit_price_minor,
            currency_code=CHECKOUT_CURRENCY_UZS,
            pricing_revision=CATALOG_INITIAL_PRICING_REVISION,
            status=status.value,
        )
        session.add(item)
        session.flush()
        return item

    if existing.unit_price_minor != unit_price_minor:
        existing.pricing_revision += 1
    existing.unit_price_minor = unit_price_minor
    existing.offering_kind = offering_kind.value
    existing.title = clean_title
    existing.status = status.value
    session.flush()
    return existing


def _owned_application(
    session: Session,
    *,
    owner_user_id: uuid.UUID,
    business_application_id: uuid.UUID,
) -> BusinessOnboardingApplication | ConsumerCatalogWriteError:
    application = session.get(BusinessOnboardingApplication, business_application_id)
    if application is None or application.owner_user_id != owner_user_id:
        return ConsumerCatalogWriteError(
            code=ConsumerCatalogWriteErrorCode.BUSINESS_NOT_FOUND,
            message="Business not found.",
        )
    if application.verification_status != VerificationStatus.VERIFIED.value:
        return ConsumerCatalogWriteError(
            code=ConsumerCatalogWriteErrorCode.BUSINESS_NOT_VERIFIED,
            message="Only verified businesses can manage catalog offerings.",
        )
    return application


def _owned_item(
    session: Session,
    *,
    owner_user_id: uuid.UUID,
    business_application_id: uuid.UUID,
    catalog_item_id: uuid.UUID,
) -> ConsumerCatalogItem | ConsumerCatalogWriteError:
    application = _owned_application(
        session,
        owner_user_id=owner_user_id,
        business_application_id=business_application_id,
    )
    if isinstance(application, ConsumerCatalogWriteError):
        return application
    item = session.get(ConsumerCatalogItem, catalog_item_id)
    if item is None or item.business_application_id != business_application_id:
        return ConsumerCatalogWriteError(
            code=ConsumerCatalogWriteErrorCode.CATALOG_ITEM_NOT_FOUND,
            message="Catalog item not found.",
        )
    return item


def create_catalog_offering(
    session: Session,
    *,
    owner_user_id: uuid.UUID,
    business_application_id: uuid.UUID,
    catalog_item_stable_id: str,
    offering_kind: ConsumerCatalogOfferingKind,
    title: str,
    unit_price_minor: int,
) -> ConsumerCatalogItem | ConsumerCatalogWriteError:
    """Create an offering. An existing stable id is a conflict, not an overwrite."""
    application = _owned_application(
        session,
        owner_user_id=owner_user_id,
        business_application_id=business_application_id,
    )
    if isinstance(application, ConsumerCatalogWriteError):
        return application
    item_id = catalog_item_stable_id.strip()
    existing = session.scalar(
        select(ConsumerCatalogItem).where(
            ConsumerCatalogItem.business_application_id == business_application_id,
            ConsumerCatalogItem.catalog_item_stable_id == item_id,
        )
    )
    if existing is not None:
        return ConsumerCatalogWriteError(
            code=ConsumerCatalogWriteErrorCode.CATALOG_ITEM_EXISTS,
            message="A catalog item with this identifier already exists.",
        )
    return upsert_catalog_offering(
        session,
        owner_user_id=owner_user_id,
        business_application_id=business_application_id,
        catalog_item_stable_id=item_id,
        offering_kind=offering_kind,
        title=title,
        unit_price_minor=unit_price_minor,
        status=ConsumerCatalogItemStatus.ACTIVE,
    )


def list_catalog_offerings(
    session: Session,
    *,
    owner_user_id: uuid.UUID,
    business_application_id: uuid.UUID,
) -> list[ConsumerCatalogItem] | ConsumerCatalogWriteError:
    application = _owned_application(
        session,
        owner_user_id=owner_user_id,
        business_application_id=business_application_id,
    )
    if isinstance(application, ConsumerCatalogWriteError):
        return application
    return list(
        session.scalars(
            select(ConsumerCatalogItem)
            .where(ConsumerCatalogItem.business_application_id == business_application_id)
            .order_by(ConsumerCatalogItem.created_at, ConsumerCatalogItem.catalog_item_stable_id)
        )
    )


def get_catalog_offering(
    session: Session,
    *,
    owner_user_id: uuid.UUID,
    business_application_id: uuid.UUID,
    catalog_item_id: uuid.UUID,
) -> ConsumerCatalogItem | ConsumerCatalogWriteError:
    return _owned_item(
        session,
        owner_user_id=owner_user_id,
        business_application_id=business_application_id,
        catalog_item_id=catalog_item_id,
    )


def set_catalog_offering_price(
    session: Session,
    *,
    owner_user_id: uuid.UUID,
    business_application_id: uuid.UUID,
    catalog_item_id: uuid.UUID,
    unit_price_minor: int,
) -> ConsumerCatalogItem | ConsumerCatalogWriteError:
    item = _owned_item(
        session,
        owner_user_id=owner_user_id,
        business_application_id=business_application_id,
        catalog_item_id=catalog_item_id,
    )
    if isinstance(item, ConsumerCatalogWriteError):
        return item
    if (
        isinstance(unit_price_minor, bool)
        or not isinstance(unit_price_minor, int)
        or unit_price_minor < 0
        or unit_price_minor > CATALOG_ITEM_MAX_UNIT_PRICE_MINOR
    ):
        return ConsumerCatalogWriteError(
            code=ConsumerCatalogWriteErrorCode.VALIDATION_FAILED,
            message="Unit price must be a non-negative integer amount of UZS.",
        )
    if item.unit_price_minor != unit_price_minor:
        item.unit_price_minor = unit_price_minor
        item.pricing_revision += 1
        session.flush()
    return item


def set_catalog_offering_status(
    session: Session,
    *,
    owner_user_id: uuid.UUID,
    business_application_id: uuid.UUID,
    catalog_item_id: uuid.UUID,
    status: ConsumerCatalogItemStatus,
) -> ConsumerCatalogItem | ConsumerCatalogWriteError:
    """Status changes do not bump ``pricing_revision``."""
    item = _owned_item(
        session,
        owner_user_id=owner_user_id,
        business_application_id=business_application_id,
        catalog_item_id=catalog_item_id,
    )
    if isinstance(item, ConsumerCatalogWriteError):
        return item
    item.status = status.value
    session.flush()
    return item

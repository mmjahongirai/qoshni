"""Authoritative consumer catalog offerings owned by verified onboarding businesses."""

from __future__ import annotations

import uuid
from datetime import datetime
from enum import StrEnum

from sqlalchemy import (
    CheckConstraint,
    DateTime,
    ForeignKey,
    Index,
    Integer,
    String,
    UniqueConstraint,
    Uuid,
    func,
)
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base
from app.domain.checkout_limits import CHECKOUT_CURRENCY_UZS
from app.domain.consumer_catalog import (
    CATALOG_INITIAL_PRICING_REVISION,
    CATALOG_ITEM_MAX_UNIT_PRICE_MINOR,
    CATALOG_ITEM_STABLE_ID_MAX_LENGTH,
    CATALOG_ITEM_TITLE_MAX_LENGTH,
    ConsumerCatalogInventoryEventKind,
    ConsumerCatalogItemStatus,
    ConsumerCatalogOfferingKind,
    INVENTORY_EVENT_REASON_MAX_LENGTH,
)


def _in_values(column: str, enum_type: type[StrEnum]) -> str:
    values = ", ".join(f"'{member.value}'" for member in enum_type)
    return f"{column} IN ({values})"


class ConsumerCatalogInventory(Base):
    """On-hand and reserved units for one catalog item.

    There is no implicit zero balance: a missing row means stock is not
    authoritative and checkout must fail closed. ``reserved_quantity`` is
    stored explicitly (0 when the balance is opened) so
    ``available = quantity_on_hand - reserved_quantity`` cannot drift.

    The row follows ``consumer_catalog_items``, which today points at a
    verified onboarding application. A future canonical Business Profile can
    replace that parent reference without rewriting inventory rows.
    """

    __tablename__ = "consumer_catalog_inventory"
    __table_args__ = (
        CheckConstraint(
            "quantity_on_hand >= 0",
            name="consumer_catalog_inventory_on_hand_non_negative",
        ),
        CheckConstraint(
            "reserved_quantity >= 0",
            name="consumer_catalog_inventory_reserved_non_negative",
        ),
        CheckConstraint(
            "reserved_quantity <= quantity_on_hand",
            name="consumer_catalog_inventory_reserved_within_on_hand",
        ),
    )

    catalog_item_id: Mapped[uuid.UUID] = mapped_column(
        Uuid,
        ForeignKey("consumer_catalog_items.id", ondelete="CASCADE"),
        primary_key=True,
    )
    quantity_on_hand: Mapped[int] = mapped_column(Integer, nullable=False)
    reserved_quantity: Mapped[int] = mapped_column(Integer, nullable=False)
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), onupdate=func.now(), nullable=False
    )


class ConsumerCatalogInventoryEvent(Base):
    """Append-only record of an owner change to on-hand quantity."""

    __tablename__ = "consumer_catalog_inventory_events"
    __table_args__ = (
        CheckConstraint(
            _in_values("kind", ConsumerCatalogInventoryEventKind),
            name="consumer_catalog_inventory_event_kind_valid",
        ),
        CheckConstraint(
            "length(trim(reason)) > 0",
            name="consumer_catalog_inventory_event_reason_not_blank",
        ),
    )

    id: Mapped[uuid.UUID] = mapped_column(Uuid, primary_key=True, default=uuid.uuid4)
    catalog_item_id: Mapped[uuid.UUID] = mapped_column(
        Uuid,
        ForeignKey("consumer_catalog_items.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    actor_user_id: Mapped[uuid.UUID] = mapped_column(
        Uuid,
        ForeignKey("users.id", ondelete="RESTRICT"),
        nullable=False,
    )
    kind: Mapped[str] = mapped_column(String(32), nullable=False)
    quantity_delta: Mapped[int] = mapped_column(Integer, nullable=False)
    quantity_on_hand_after: Mapped[int] = mapped_column(Integer, nullable=False)
    reserved_quantity_after: Mapped[int] = mapped_column(Integer, nullable=False)
    reason: Mapped[str] = mapped_column(String(INVENTORY_EVENT_REASON_MAX_LENGTH), nullable=False)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )


class InventoryMaintenanceRun(Base):
    """One attempt to expire stale reservation holds."""

    __tablename__ = "inventory_maintenance_runs"
    __table_args__ = (
        CheckConstraint(
            "outcome IN ('succeeded', 'failed')",
            name="inventory_maintenance_run_outcome_valid",
        ),
        CheckConstraint(
            "expired_count >= 0",
            name="inventory_maintenance_run_expired_count_non_negative",
        ),
    )

    id: Mapped[uuid.UUID] = mapped_column(Uuid, primary_key=True, default=uuid.uuid4)
    worker_id: Mapped[str] = mapped_column(String(64), nullable=False)
    outcome: Mapped[str] = mapped_column(String(16), nullable=False)
    expired_count: Mapped[int] = mapped_column(Integer, nullable=False)
    error_message: Mapped[str | None] = mapped_column(String(500), nullable=True)
    started_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    finished_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)


class ConsumerCatalogItem(Base):
    """One priceable product or service offering of a business.

    ``business_application_id`` is the business identity; the public
    ``business_stable_id`` is derived as ``business:onboarding:{id}``.
    """

    __tablename__ = "consumer_catalog_items"
    __table_args__ = (
        UniqueConstraint(
            "business_application_id",
            "catalog_item_stable_id",
            name="uq_consumer_catalog_items_business_item",
        ),
        CheckConstraint(
            f"unit_price_minor >= 0 AND unit_price_minor <= {CATALOG_ITEM_MAX_UNIT_PRICE_MINOR}",
            name="consumer_catalog_item_unit_price_bounds",
        ),
        CheckConstraint(
            f"currency_code = '{CHECKOUT_CURRENCY_UZS}'",
            name="consumer_catalog_item_currency_uzs",
        ),
        CheckConstraint(
            f"pricing_revision >= {CATALOG_INITIAL_PRICING_REVISION}",
            name="consumer_catalog_item_pricing_revision_positive",
        ),
        CheckConstraint(
            _in_values("offering_kind", ConsumerCatalogOfferingKind),
            name="consumer_catalog_item_offering_kind_valid",
        ),
        CheckConstraint(
            _in_values("status", ConsumerCatalogItemStatus),
            name="consumer_catalog_item_status_valid",
        ),
        CheckConstraint(
            "length(trim(catalog_item_stable_id)) > 0",
            name="consumer_catalog_item_stable_id_not_blank",
        ),
        CheckConstraint(
            "length(trim(title)) > 0",
            name="consumer_catalog_item_title_not_blank",
        ),
        Index(
            "ix_consumer_catalog_items_business_application_id_status",
            "business_application_id",
            "status",
        ),
    )

    id: Mapped[uuid.UUID] = mapped_column(Uuid, primary_key=True, default=uuid.uuid4)
    business_application_id: Mapped[uuid.UUID] = mapped_column(
        Uuid,
        ForeignKey("business_onboarding_applications.id", ondelete="CASCADE"),
        nullable=False,
    )
    catalog_item_stable_id: Mapped[str] = mapped_column(
        String(CATALOG_ITEM_STABLE_ID_MAX_LENGTH), nullable=False
    )
    offering_kind: Mapped[str] = mapped_column(String(16), nullable=False)
    title: Mapped[str] = mapped_column(String(CATALOG_ITEM_TITLE_MAX_LENGTH), nullable=False)
    unit_price_minor: Mapped[int] = mapped_column(Integer, nullable=False)
    currency_code: Mapped[str] = mapped_column(
        String(8),
        nullable=False,
        default=CHECKOUT_CURRENCY_UZS,
        server_default=CHECKOUT_CURRENCY_UZS,
    )
    pricing_revision: Mapped[int] = mapped_column(
        Integer,
        nullable=False,
        default=CATALOG_INITIAL_PRICING_REVISION,
        server_default=str(CATALOG_INITIAL_PRICING_REVISION),
    )
    status: Mapped[str] = mapped_column(
        String(16),
        nullable=False,
        default=ConsumerCatalogItemStatus.ACTIVE.value,
        server_default=ConsumerCatalogItemStatus.ACTIVE.value,
    )
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), onupdate=func.now(), nullable=False
    )

    def __repr__(self) -> str:
        return (
            f"ConsumerCatalogItem(id={self.id!r}, "
            f"business_application_id={self.business_application_id!r}, "
            f"catalog_item_stable_id={self.catalog_item_stable_id!r}, "
            f"pricing_revision={self.pricing_revision!r})"
        )

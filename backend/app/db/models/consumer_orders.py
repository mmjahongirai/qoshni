"""Durable consumer order, quote, idempotency and reservation models."""

from __future__ import annotations

import uuid
from datetime import datetime

from sqlalchemy import (
    CheckConstraint,
    DateTime,
    ForeignKey,
    Integer,
    String,
    UniqueConstraint,
    Uuid,
    func,
)
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base import Base


class CheckoutQuote(Base):
    __tablename__ = "checkout_quotes"
    __table_args__ = (
        CheckConstraint("subtotal_minor >= 0", name="checkout_quote_subtotal_non_negative"),
        CheckConstraint("total_minor >= 0", name="checkout_quote_total_non_negative"),
    )

    id: Mapped[uuid.UUID] = mapped_column(Uuid, primary_key=True, default=uuid.uuid4)
    buyer_user_id: Mapped[uuid.UUID] = mapped_column(
        Uuid, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True
    )
    request_fingerprint: Mapped[str] = mapped_column(String(128), nullable=False)
    fulfillment_type: Mapped[str] = mapped_column(String(32), nullable=False)
    currency_code: Mapped[str] = mapped_column(String(8), nullable=False)
    subtotal_minor: Mapped[int] = mapped_column(Integer, nullable=False)
    total_minor: Mapped[int] = mapped_column(Integer, nullable=False)
    pricing_revision: Mapped[int] = mapped_column(Integer, nullable=False)
    cart_revision: Mapped[int | None] = mapped_column(Integer, nullable=True)
    expires_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )

    lines: Mapped[list["CheckoutQuoteLine"]] = relationship(
        back_populates="quote",
        cascade="all, delete-orphan",
    )


class CheckoutQuoteLine(Base):
    __tablename__ = "checkout_quote_lines"
    __table_args__ = (
        CheckConstraint("quantity > 0", name="checkout_quote_line_quantity_positive"),
        CheckConstraint(
            "unit_price_minor >= 0",
            name="checkout_quote_line_unit_price_non_negative",
        ),
    )

    id: Mapped[uuid.UUID] = mapped_column(Uuid, primary_key=True, default=uuid.uuid4)
    quote_id: Mapped[uuid.UUID] = mapped_column(
        Uuid, ForeignKey("checkout_quotes.id", ondelete="CASCADE"), nullable=False, index=True
    )
    business_stable_id: Mapped[str] = mapped_column(String(128), nullable=False)
    catalog_item_stable_id: Mapped[str] = mapped_column(String(128), nullable=False)
    title_snapshot: Mapped[str] = mapped_column(String(256), nullable=False)
    quantity: Mapped[int] = mapped_column(Integer, nullable=False)
    unit_price_minor: Mapped[int] = mapped_column(Integer, nullable=False)
    line_subtotal_minor: Mapped[int] = mapped_column(Integer, nullable=False)
    currency_code: Mapped[str] = mapped_column(String(8), nullable=False)

    quote: Mapped[CheckoutQuote] = relationship(back_populates="lines")


class ConsumerOrder(Base):
    __tablename__ = "consumer_orders"
    __table_args__ = (
        CheckConstraint("subtotal_minor >= 0", name="consumer_order_subtotal_non_negative"),
        CheckConstraint("total_minor >= 0", name="consumer_order_total_non_negative"),
    )

    id: Mapped[uuid.UUID] = mapped_column(Uuid, primary_key=True, default=uuid.uuid4)
    buyer_user_id: Mapped[uuid.UUID] = mapped_column(
        Uuid, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True
    )
    checkout_correlation_id: Mapped[str] = mapped_column(String(128), nullable=False)
    checkout_quote_id: Mapped[uuid.UUID | None] = mapped_column(
        Uuid, ForeignKey("checkout_quotes.id", ondelete="SET NULL"), nullable=True
    )
    idempotency_key: Mapped[str] = mapped_column(String(128), nullable=False)
    status: Mapped[str] = mapped_column(String(32), nullable=False)
    payment_status: Mapped[str] = mapped_column(String(32), nullable=False)
    fulfillment_status: Mapped[str] = mapped_column(String(32), nullable=False)
    currency_code: Mapped[str] = mapped_column(String(8), nullable=False)
    subtotal_minor: Mapped[int] = mapped_column(Integer, nullable=False)
    total_minor: Mapped[int] = mapped_column(Integer, nullable=False)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), onupdate=func.now(), nullable=False
    )

    items: Mapped[list["ConsumerOrderItem"]] = relationship(
        back_populates="order",
        cascade="all, delete-orphan",
    )
    status_events: Mapped[list["ConsumerOrderStatusEvent"]] = relationship(
        back_populates="order",
        cascade="all, delete-orphan",
    )
    reservations: Mapped[list["InventoryReservation"]] = relationship(
        back_populates="order",
        cascade="all, delete-orphan",
    )


class ConsumerOrderItem(Base):
    __tablename__ = "consumer_order_items"
    __table_args__ = (
        CheckConstraint("quantity > 0", name="consumer_order_item_quantity_positive"),
    )

    id: Mapped[uuid.UUID] = mapped_column(Uuid, primary_key=True, default=uuid.uuid4)
    order_id: Mapped[uuid.UUID] = mapped_column(
        Uuid, ForeignKey("consumer_orders.id", ondelete="CASCADE"), nullable=False, index=True
    )
    business_stable_id: Mapped[str] = mapped_column(String(128), nullable=False)
    catalog_item_stable_id: Mapped[str] = mapped_column(String(128), nullable=False)
    title_snapshot: Mapped[str] = mapped_column(String(256), nullable=False)
    quantity: Mapped[int] = mapped_column(Integer, nullable=False)
    unit_price_minor: Mapped[int] = mapped_column(Integer, nullable=False)
    line_subtotal_minor: Mapped[int] = mapped_column(Integer, nullable=False)
    currency_code: Mapped[str] = mapped_column(String(8), nullable=False)

    order: Mapped[ConsumerOrder] = relationship(back_populates="items")


class ConsumerOrderStatusEvent(Base):
    __tablename__ = "consumer_order_status_events"

    id: Mapped[uuid.UUID] = mapped_column(Uuid, primary_key=True, default=uuid.uuid4)
    order_id: Mapped[uuid.UUID] = mapped_column(
        Uuid, ForeignKey("consumer_orders.id", ondelete="CASCADE"), nullable=False, index=True
    )
    from_status: Mapped[str | None] = mapped_column(String(32), nullable=True)
    to_status: Mapped[str] = mapped_column(String(32), nullable=False)
    reason: Mapped[str | None] = mapped_column(String(256), nullable=True)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )

    order: Mapped[ConsumerOrder] = relationship(back_populates="status_events")


class OrderIdempotencyRecord(Base):
    __tablename__ = "order_idempotency_records"
    __table_args__ = (
        UniqueConstraint(
            "buyer_user_id",
            "operation",
            "idempotency_key",
            name="uq_order_idempotency_buyer_operation_key",
        ),
    )

    id: Mapped[uuid.UUID] = mapped_column(Uuid, primary_key=True, default=uuid.uuid4)
    buyer_user_id: Mapped[uuid.UUID] = mapped_column(
        Uuid, ForeignKey("users.id", ondelete="CASCADE"), nullable=False
    )
    operation: Mapped[str] = mapped_column(String(64), nullable=False)
    idempotency_key: Mapped[str] = mapped_column(String(128), nullable=False)
    request_fingerprint: Mapped[str] = mapped_column(String(128), nullable=False)
    order_id: Mapped[uuid.UUID | None] = mapped_column(
        Uuid, ForeignKey("consumer_orders.id", ondelete="SET NULL"), nullable=True
    )
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )


class InventoryReservation(Base):
    __tablename__ = "inventory_reservations"
    __table_args__ = (
        CheckConstraint("quantity > 0", name="inventory_reservation_quantity_positive"),
    )

    id: Mapped[uuid.UUID] = mapped_column(Uuid, primary_key=True, default=uuid.uuid4)
    order_id: Mapped[uuid.UUID] = mapped_column(
        Uuid, ForeignKey("consumer_orders.id", ondelete="CASCADE"), nullable=False, index=True
    )
    business_stable_id: Mapped[str] = mapped_column(String(128), nullable=False)
    catalog_item_stable_id: Mapped[str] = mapped_column(String(128), nullable=False)
    quantity: Mapped[int] = mapped_column(Integer, nullable=False)
    status: Mapped[str] = mapped_column(String(16), nullable=False)
    expires_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), onupdate=func.now(), nullable=False
    )

    order: Mapped[ConsumerOrder] = relationship(back_populates="reservations")

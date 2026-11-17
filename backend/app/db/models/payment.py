"""Payments, holds, and payment idempotency (Phase 19 WP2).

Order placement idempotency stays in ``order_idempotency_records``.
"""

from __future__ import annotations

import uuid
from datetime import datetime
from enum import StrEnum

from sqlalchemy import (
    BigInteger,
    CheckConstraint,
    DateTime,
    ForeignKey,
    Index,
    String,
    UniqueConstraint,
    Uuid,
    func,
    text,
)
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base
from app.domain.payment import PaymentMethod, PaymentStatus, WalletHoldStatus


def _in_values(column: str, enum_type: type[StrEnum]) -> str:
    values = ", ".join(f"'{member.value}'" for member in enum_type)
    return f"{column} IN ({values})"


class Payment(Base):
    __tablename__ = "payments"
    __table_args__ = (
        CheckConstraint(_in_values("status", PaymentStatus), name="payment_status_valid"),
        CheckConstraint(_in_values("payment_method", PaymentMethod), name="payment_method_valid"),
        CheckConstraint("amount_minor > 0", name="payment_amount_positive"),
        CheckConstraint(
            "length(currency_code) = 3 AND currency_code = upper(currency_code)",
            name="payment_currency_code_iso",
        ),
        CheckConstraint(
            "length(trim(idempotency_key)) > 0",
            name="payment_idempotency_key_not_blank",
        ),
        Index(
            "uq_payments_one_open_per_order",
            "order_id",
            unique=True,
            sqlite_where=text("status IN ('pending', 'held')"),
            postgresql_where=text("status IN ('pending', 'held')"),
        ),
        Index("ix_payments_payer_user_id", "payer_user_id"),
        Index("ix_payments_order_id", "order_id"),
    )

    id: Mapped[uuid.UUID] = mapped_column(Uuid, primary_key=True, default=uuid.uuid4)
    order_id: Mapped[uuid.UUID] = mapped_column(
        Uuid, ForeignKey("consumer_orders.id", ondelete="RESTRICT"), nullable=False
    )
    payer_user_id: Mapped[uuid.UUID] = mapped_column(
        Uuid, ForeignKey("users.id", ondelete="RESTRICT"), nullable=False
    )
    payer_wallet_id: Mapped[uuid.UUID] = mapped_column(
        Uuid, ForeignKey("wallets.id", ondelete="RESTRICT"), nullable=False
    )
    payee_wallet_id: Mapped[uuid.UUID] = mapped_column(
        Uuid, ForeignKey("wallets.id", ondelete="RESTRICT"), nullable=False
    )
    amount_minor: Mapped[int] = mapped_column(BigInteger, nullable=False)
    currency_code: Mapped[str] = mapped_column(String(3), nullable=False)
    status: Mapped[str] = mapped_column(String(16), nullable=False)
    payment_method: Mapped[str] = mapped_column(String(16), nullable=False)
    idempotency_key: Mapped[str] = mapped_column(String(128), nullable=False)
    external_reference: Mapped[str | None] = mapped_column(String(128), nullable=True)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), onupdate=func.now(), nullable=False
    )


class WalletHold(Base):
    __tablename__ = "wallet_holds"
    __table_args__ = (
        UniqueConstraint("payment_id", name="uq_wallet_holds_payment_id"),
        CheckConstraint(_in_values("status", WalletHoldStatus), name="wallet_hold_status_valid"),
        CheckConstraint("amount_minor > 0", name="wallet_hold_amount_positive"),
        CheckConstraint(
            "length(currency_code) = 3 AND currency_code = upper(currency_code)",
            name="wallet_hold_currency_code_iso",
        ),
        Index("ix_wallet_holds_wallet_id", "wallet_id"),
        Index("ix_wallet_holds_order_id", "order_id"),
    )

    id: Mapped[uuid.UUID] = mapped_column(Uuid, primary_key=True, default=uuid.uuid4)
    wallet_id: Mapped[uuid.UUID] = mapped_column(
        Uuid, ForeignKey("wallets.id", ondelete="RESTRICT"), nullable=False
    )
    payment_id: Mapped[uuid.UUID] = mapped_column(
        Uuid, ForeignKey("payments.id", ondelete="RESTRICT"), nullable=False
    )
    order_id: Mapped[uuid.UUID] = mapped_column(
        Uuid, ForeignKey("consumer_orders.id", ondelete="RESTRICT"), nullable=False
    )
    amount_minor: Mapped[int] = mapped_column(BigInteger, nullable=False)
    currency_code: Mapped[str] = mapped_column(String(3), nullable=False)
    status: Mapped[str] = mapped_column(String(16), nullable=False)
    reason: Mapped[str] = mapped_column(String(256), nullable=False)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )
    expires_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    released_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)


class PaymentIdempotencyRecord(Base):
    __tablename__ = "payment_idempotency_records"
    __table_args__ = (
        UniqueConstraint(
            "buyer_user_id",
            "operation",
            "idempotency_key",
            name="uq_payment_idempotency_buyer_operation_key",
        ),
    )

    id: Mapped[uuid.UUID] = mapped_column(Uuid, primary_key=True, default=uuid.uuid4)
    buyer_user_id: Mapped[uuid.UUID] = mapped_column(
        Uuid, ForeignKey("users.id", ondelete="RESTRICT"), nullable=False
    )
    operation: Mapped[str] = mapped_column(String(64), nullable=False)
    idempotency_key: Mapped[str] = mapped_column(String(128), nullable=False)
    request_fingerprint: Mapped[str] = mapped_column(String(128), nullable=False)
    payment_id: Mapped[uuid.UUID] = mapped_column(
        Uuid, ForeignKey("payments.id", ondelete="RESTRICT"), nullable=False
    )
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )

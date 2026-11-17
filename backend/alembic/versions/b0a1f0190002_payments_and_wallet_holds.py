"""Phase 19 WP2 — payments, wallet holds, and payment idempotency.

Revision ID: b0a1f0190002
Revises: b0a1f0190001
Create Date: 2026-11-06 12:30:00.000000
"""

from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op

revision: str = "b0a1f0190002"
down_revision: Union[str, Sequence[str], None] = "b0a1f0190001"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None

_OPEN_PAYMENT = "status IN ('pending', 'held')"


def upgrade() -> None:
    op.create_table(
        "payments",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("order_id", sa.Uuid(), nullable=False),
        sa.Column("payer_user_id", sa.Uuid(), nullable=False),
        sa.Column("payer_wallet_id", sa.Uuid(), nullable=False),
        sa.Column("payee_wallet_id", sa.Uuid(), nullable=False),
        sa.Column("amount_minor", sa.BigInteger(), nullable=False),
        sa.Column("currency_code", sa.String(length=3), nullable=False),
        sa.Column("status", sa.String(length=16), nullable=False),
        sa.Column("payment_method", sa.String(length=16), nullable=False),
        sa.Column("idempotency_key", sa.String(length=128), nullable=False),
        sa.Column("external_reference", sa.String(length=128), nullable=True),
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("CURRENT_TIMESTAMP"),
            nullable=False,
        ),
        sa.Column(
            "updated_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("CURRENT_TIMESTAMP"),
            nullable=False,
        ),
        sa.CheckConstraint(
            "status IN ('pending', 'held', 'failed', 'released')",
            name="payment_status_valid",
        ),
        sa.CheckConstraint("payment_method IN ('wallet')", name="payment_method_valid"),
        sa.CheckConstraint("amount_minor > 0", name="payment_amount_positive"),
        sa.CheckConstraint(
            "length(currency_code) = 3 AND currency_code = upper(currency_code)",
            name="payment_currency_code_iso",
        ),
        sa.CheckConstraint(
            "length(trim(idempotency_key)) > 0",
            name="payment_idempotency_key_not_blank",
        ),
        sa.ForeignKeyConstraint(["order_id"], ["consumer_orders.id"], ondelete="RESTRICT"),
        sa.ForeignKeyConstraint(["payer_user_id"], ["users.id"], ondelete="RESTRICT"),
        sa.ForeignKeyConstraint(["payer_wallet_id"], ["wallets.id"], ondelete="RESTRICT"),
        sa.ForeignKeyConstraint(["payee_wallet_id"], ["wallets.id"], ondelete="RESTRICT"),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index("ix_payments_payer_user_id", "payments", ["payer_user_id"])
    op.create_index("ix_payments_order_id", "payments", ["order_id"])
    op.create_index(
        "uq_payments_one_open_per_order",
        "payments",
        ["order_id"],
        unique=True,
        postgresql_where=sa.text(_OPEN_PAYMENT),
        sqlite_where=sa.text(_OPEN_PAYMENT),
    )
    op.create_table(
        "wallet_holds",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("wallet_id", sa.Uuid(), nullable=False),
        sa.Column("payment_id", sa.Uuid(), nullable=False),
        sa.Column("order_id", sa.Uuid(), nullable=False),
        sa.Column("amount_minor", sa.BigInteger(), nullable=False),
        sa.Column("currency_code", sa.String(length=3), nullable=False),
        sa.Column("status", sa.String(length=16), nullable=False),
        sa.Column("reason", sa.String(length=256), nullable=False),
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("CURRENT_TIMESTAMP"),
            nullable=False,
        ),
        sa.Column("expires_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("released_at", sa.DateTime(timezone=True), nullable=True),
        sa.CheckConstraint(
            "status IN ('active', 'released', 'consumed')",
            name="wallet_hold_status_valid",
        ),
        sa.CheckConstraint("amount_minor > 0", name="wallet_hold_amount_positive"),
        sa.CheckConstraint(
            "length(currency_code) = 3 AND currency_code = upper(currency_code)",
            name="wallet_hold_currency_code_iso",
        ),
        sa.ForeignKeyConstraint(["wallet_id"], ["wallets.id"], ondelete="RESTRICT"),
        sa.ForeignKeyConstraint(["payment_id"], ["payments.id"], ondelete="RESTRICT"),
        sa.ForeignKeyConstraint(["order_id"], ["consumer_orders.id"], ondelete="RESTRICT"),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint("payment_id", name="uq_wallet_holds_payment_id"),
    )
    op.create_index("ix_wallet_holds_wallet_id", "wallet_holds", ["wallet_id"])
    op.create_index("ix_wallet_holds_order_id", "wallet_holds", ["order_id"])
    op.create_table(
        "payment_idempotency_records",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("buyer_user_id", sa.Uuid(), nullable=False),
        sa.Column("operation", sa.String(length=64), nullable=False),
        sa.Column("idempotency_key", sa.String(length=128), nullable=False),
        sa.Column("request_fingerprint", sa.String(length=128), nullable=False),
        sa.Column("payment_id", sa.Uuid(), nullable=False),
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("CURRENT_TIMESTAMP"),
            nullable=False,
        ),
        sa.ForeignKeyConstraint(["buyer_user_id"], ["users.id"], ondelete="RESTRICT"),
        sa.ForeignKeyConstraint(["payment_id"], ["payments.id"], ondelete="RESTRICT"),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint(
            "buyer_user_id",
            "operation",
            "idempotency_key",
            name="uq_payment_idempotency_buyer_operation_key",
        ),
    )


def downgrade() -> None:
    op.drop_table("payment_idempotency_records")
    op.drop_index("ix_wallet_holds_order_id", table_name="wallet_holds")
    op.drop_index("ix_wallet_holds_wallet_id", table_name="wallet_holds")
    op.drop_table("wallet_holds")
    op.drop_index("uq_payments_one_open_per_order", table_name="payments")
    op.drop_index("ix_payments_order_id", table_name="payments")
    op.drop_index("ix_payments_payer_user_id", table_name="payments")
    op.drop_table("payments")

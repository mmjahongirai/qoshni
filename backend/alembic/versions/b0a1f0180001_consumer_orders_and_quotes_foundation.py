"""Phase 18 WP3 — durable consumer orders, quotes, idempotency, reservations.

Revision ID: b0a1f0180001
Revises: b0a1f0170001
Create Date: 2026-10-25 01:00:00.000000

No product catalog FK — lines store stable catalog references plus immutable snapshots.
Operational placement still requires a future ConsumerCatalogAuthority implementation.
"""

from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op

revision: str = "b0a1f0180001"
down_revision: Union[str, Sequence[str], None] = "b0a1f0170001"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        "checkout_quotes",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("buyer_user_id", sa.Uuid(), nullable=False),
        sa.Column("request_fingerprint", sa.String(length=128), nullable=False),
        sa.Column("fulfillment_type", sa.String(length=32), nullable=False),
        sa.Column("currency_code", sa.String(length=8), nullable=False),
        sa.Column("subtotal_minor", sa.Integer(), nullable=False),
        sa.Column("total_minor", sa.Integer(), nullable=False),
        sa.Column("pricing_revision", sa.Integer(), nullable=False),
        sa.Column("cart_revision", sa.Integer(), nullable=True),
        sa.Column("expires_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.text("CURRENT_TIMESTAMP"), nullable=False),
        sa.CheckConstraint("subtotal_minor >= 0", name="checkout_quote_subtotal_non_negative"),
        sa.CheckConstraint("total_minor >= 0", name="checkout_quote_total_non_negative"),
        sa.ForeignKeyConstraint(["buyer_user_id"], ["users.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index("ix_checkout_quotes_buyer_user_id", "checkout_quotes", ["buyer_user_id"])

    op.create_table(
        "checkout_quote_lines",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("quote_id", sa.Uuid(), nullable=False),
        sa.Column("business_stable_id", sa.String(length=128), nullable=False),
        sa.Column("catalog_item_stable_id", sa.String(length=128), nullable=False),
        sa.Column("title_snapshot", sa.String(length=256), nullable=False),
        sa.Column("quantity", sa.Integer(), nullable=False),
        sa.Column("unit_price_minor", sa.Integer(), nullable=False),
        sa.Column("line_subtotal_minor", sa.Integer(), nullable=False),
        sa.Column("currency_code", sa.String(length=8), nullable=False),
        sa.CheckConstraint("quantity > 0", name="checkout_quote_line_quantity_positive"),
        sa.CheckConstraint("unit_price_minor >= 0", name="checkout_quote_line_unit_price_non_negative"),
        sa.ForeignKeyConstraint(["quote_id"], ["checkout_quotes.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index("ix_checkout_quote_lines_quote_id", "checkout_quote_lines", ["quote_id"])

    op.create_table(
        "consumer_orders",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("buyer_user_id", sa.Uuid(), nullable=False),
        sa.Column("checkout_correlation_id", sa.String(length=128), nullable=False),
        sa.Column("checkout_quote_id", sa.Uuid(), nullable=True),
        sa.Column("idempotency_key", sa.String(length=128), nullable=False),
        sa.Column("status", sa.String(length=32), nullable=False),
        sa.Column("payment_status", sa.String(length=32), nullable=False),
        sa.Column("fulfillment_status", sa.String(length=32), nullable=False),
        sa.Column("currency_code", sa.String(length=8), nullable=False),
        sa.Column("subtotal_minor", sa.Integer(), nullable=False),
        sa.Column("total_minor", sa.Integer(), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.text("CURRENT_TIMESTAMP"), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), server_default=sa.text("CURRENT_TIMESTAMP"), nullable=False),
        sa.CheckConstraint("subtotal_minor >= 0", name="consumer_order_subtotal_non_negative"),
        sa.CheckConstraint("total_minor >= 0", name="consumer_order_total_non_negative"),
        sa.ForeignKeyConstraint(["buyer_user_id"], ["users.id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(["checkout_quote_id"], ["checkout_quotes.id"], ondelete="SET NULL"),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index("ix_consumer_orders_buyer_user_id", "consumer_orders", ["buyer_user_id"])

    op.create_table(
        "consumer_order_items",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("order_id", sa.Uuid(), nullable=False),
        sa.Column("business_stable_id", sa.String(length=128), nullable=False),
        sa.Column("catalog_item_stable_id", sa.String(length=128), nullable=False),
        sa.Column("title_snapshot", sa.String(length=256), nullable=False),
        sa.Column("quantity", sa.Integer(), nullable=False),
        sa.Column("unit_price_minor", sa.Integer(), nullable=False),
        sa.Column("line_subtotal_minor", sa.Integer(), nullable=False),
        sa.Column("currency_code", sa.String(length=8), nullable=False),
        sa.CheckConstraint("quantity > 0", name="consumer_order_item_quantity_positive"),
        sa.ForeignKeyConstraint(["order_id"], ["consumer_orders.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index("ix_consumer_order_items_order_id", "consumer_order_items", ["order_id"])

    op.create_table(
        "consumer_order_status_events",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("order_id", sa.Uuid(), nullable=False),
        sa.Column("from_status", sa.String(length=32), nullable=True),
        sa.Column("to_status", sa.String(length=32), nullable=False),
        sa.Column("reason", sa.String(length=256), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.text("CURRENT_TIMESTAMP"), nullable=False),
        sa.ForeignKeyConstraint(["order_id"], ["consumer_orders.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index(
        "ix_consumer_order_status_events_order_id",
        "consumer_order_status_events",
        ["order_id"],
    )

    op.create_table(
        "order_idempotency_records",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("buyer_user_id", sa.Uuid(), nullable=False),
        sa.Column("operation", sa.String(length=64), nullable=False),
        sa.Column("idempotency_key", sa.String(length=128), nullable=False),
        sa.Column("request_fingerprint", sa.String(length=128), nullable=False),
        sa.Column("order_id", sa.Uuid(), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.text("CURRENT_TIMESTAMP"), nullable=False),
        sa.ForeignKeyConstraint(["buyer_user_id"], ["users.id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(["order_id"], ["consumer_orders.id"], ondelete="SET NULL"),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint(
            "buyer_user_id",
            "operation",
            "idempotency_key",
            name="uq_order_idempotency_buyer_operation_key",
        ),
    )

    op.create_table(
        "inventory_reservations",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("order_id", sa.Uuid(), nullable=False),
        sa.Column("business_stable_id", sa.String(length=128), nullable=False),
        sa.Column("catalog_item_stable_id", sa.String(length=128), nullable=False),
        sa.Column("quantity", sa.Integer(), nullable=False),
        sa.Column("status", sa.String(length=16), nullable=False),
        sa.Column("expires_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.text("CURRENT_TIMESTAMP"), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), server_default=sa.text("CURRENT_TIMESTAMP"), nullable=False),
        sa.CheckConstraint("quantity > 0", name="inventory_reservation_quantity_positive"),
        sa.ForeignKeyConstraint(["order_id"], ["consumer_orders.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index("ix_inventory_reservations_order_id", "inventory_reservations", ["order_id"])


def downgrade() -> None:
    op.drop_index("ix_inventory_reservations_order_id", table_name="inventory_reservations")
    op.drop_table("inventory_reservations")
    op.drop_table("order_idempotency_records")
    op.drop_index("ix_consumer_order_status_events_order_id", table_name="consumer_order_status_events")
    op.drop_table("consumer_order_status_events")
    op.drop_index("ix_consumer_order_items_order_id", table_name="consumer_order_items")
    op.drop_table("consumer_order_items")
    op.drop_index("ix_consumer_orders_buyer_user_id", table_name="consumer_orders")
    op.drop_table("consumer_orders")
    op.drop_index("ix_checkout_quote_lines_quote_id", table_name="checkout_quote_lines")
    op.drop_table("checkout_quote_lines")
    op.drop_index("ix_checkout_quotes_buyer_user_id", table_name="checkout_quotes")
    op.drop_table("checkout_quotes")

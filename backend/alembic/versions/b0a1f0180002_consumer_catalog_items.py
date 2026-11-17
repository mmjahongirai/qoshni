"""Phase 18 Closure WP1 — authoritative consumer catalog items.

Revision ID: b0a1f0180002
Revises: b0a1f0180001
Create Date: 2026-11-03 21:00:00.000000

Adds ``consumer_catalog_items`` (owned by verified onboarding businesses) and records
the catalog pricing revision each quote line was priced against.
"""

from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op

revision: str = "b0a1f0180002"
down_revision: Union[str, Sequence[str], None] = "b0a1f0180001"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        "consumer_catalog_items",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("business_application_id", sa.Uuid(), nullable=False),
        sa.Column("catalog_item_stable_id", sa.String(length=128), nullable=False),
        sa.Column("offering_kind", sa.String(length=16), nullable=False),
        sa.Column("title", sa.String(length=256), nullable=False),
        sa.Column("unit_price_minor", sa.Integer(), nullable=False),
        sa.Column("currency_code", sa.String(length=8), server_default="UZS", nullable=False),
        sa.Column("pricing_revision", sa.Integer(), server_default="1", nullable=False),
        sa.Column("status", sa.String(length=16), server_default="active", nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.text("CURRENT_TIMESTAMP"), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), server_default=sa.text("CURRENT_TIMESTAMP"), nullable=False),
        sa.CheckConstraint(
            "unit_price_minor >= 0 AND unit_price_minor <= 1000000000",
            name="consumer_catalog_item_unit_price_bounds",
        ),
        sa.CheckConstraint("currency_code = 'UZS'", name="consumer_catalog_item_currency_uzs"),
        sa.CheckConstraint("pricing_revision >= 1", name="consumer_catalog_item_pricing_revision_positive"),
        sa.CheckConstraint(
            "offering_kind IN ('product', 'service')",
            name="consumer_catalog_item_offering_kind_valid",
        ),
        sa.CheckConstraint(
            "status IN ('active', 'inactive', 'archived')",
            name="consumer_catalog_item_status_valid",
        ),
        sa.CheckConstraint(
            "length(trim(catalog_item_stable_id)) > 0",
            name="consumer_catalog_item_stable_id_not_blank",
        ),
        sa.CheckConstraint("length(trim(title)) > 0", name="consumer_catalog_item_title_not_blank"),
        sa.ForeignKeyConstraint(
            ["business_application_id"],
            ["business_onboarding_applications.id"],
            ondelete="CASCADE",
        ),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint(
            "business_application_id",
            "catalog_item_stable_id",
            name="uq_consumer_catalog_items_business_item",
        ),
    )
    op.create_index(
        "ix_consumer_catalog_items_business_application_id_status",
        "consumer_catalog_items",
        ["business_application_id", "status"],
    )
    op.add_column(
        "checkout_quote_lines",
        sa.Column("catalog_pricing_revision", sa.Integer(), nullable=True),
    )


def downgrade() -> None:
    op.drop_column("checkout_quote_lines", "catalog_pricing_revision")
    op.drop_index(
        "ix_consumer_catalog_items_business_application_id_status",
        table_name="consumer_catalog_items",
    )
    op.drop_table("consumer_catalog_items")

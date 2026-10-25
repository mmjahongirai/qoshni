"""Search index read model foundation.

Revision ID: b0a1f0150001
Revises: b0a1f0140001
Create Date: 2026-10-24 16:00:00.000000
"""

from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op

revision: str = "b0a1f0150001"
down_revision: Union[str, Sequence[str], None] = "b0a1f0140001"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        "search_index_metadata",
        sa.Column("id", sa.Integer(), autoincrement=True, nullable=False),
        sa.Column("catalog_generation", sa.Integer(), nullable=False, server_default="1"),
        sa.Column("updated_at", sa.DateTime(timezone=True), server_default=sa.text("CURRENT_TIMESTAMP"), nullable=False),
        sa.PrimaryKeyConstraint("id"),
    )
    op.execute(sa.text("INSERT INTO search_index_metadata (catalog_generation) VALUES (1)"))

    op.create_table(
        "search_index_records",
        sa.Column("stable_id", sa.String(length=160), nullable=False),
        sa.Column("kind", sa.String(length=32), nullable=False),
        sa.Column("title", sa.String(length=256), nullable=False),
        sa.Column("subtitle", sa.String(length=512), nullable=False, server_default=""),
        sa.Column("category_scope", sa.String(length=32), nullable=True),
        sa.Column("eligibility_status", sa.String(length=32), nullable=False),
        sa.Column("source_application_id", sa.Uuid(), nullable=True),
        sa.Column("source_updated_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.text("CURRENT_TIMESTAMP"), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), server_default=sa.text("CURRENT_TIMESTAMP"), nullable=False),
        sa.PrimaryKeyConstraint("stable_id"),
    )
    op.create_index(
        "ix_search_index_records_eligibility_stable_id",
        "search_index_records",
        ["eligibility_status", "stable_id"],
    )
    op.create_index("ix_search_index_records_category", "search_index_records", ["category_scope"])

    op.create_table(
        "search_index_projection_receipts",
        sa.Column("event_id", sa.Uuid(), nullable=False),
        sa.Column("stable_id", sa.String(length=160), nullable=False),
        sa.Column("processed_at", sa.DateTime(timezone=True), server_default=sa.text("CURRENT_TIMESTAMP"), nullable=False),
        sa.PrimaryKeyConstraint("event_id"),
    )


def downgrade() -> None:
    op.drop_table("search_index_projection_receipts")
    op.drop_index("ix_search_index_records_category", table_name="search_index_records")
    op.drop_index("ix_search_index_records_eligibility_stable_id", table_name="search_index_records")
    op.drop_table("search_index_records")
    op.drop_table("search_index_metadata")

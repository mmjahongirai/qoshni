"""Location WP2 — saved places and optional search-index branch coordinates.

Revision ID: b0a1f0160001
Revises: b0a1f0150001
Create Date: 2026-10-24 22:00:00.000000

PostGIS is not required; branch coordinates are plain floats for haversine filtering.
"""

from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op

revision: str = "b0a1f0160001"
down_revision: Union[str, Sequence[str], None] = "b0a1f0150001"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        "user_saved_places",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("user_id", sa.Uuid(), nullable=False),
        sa.Column("label", sa.String(length=80), nullable=False),
        sa.Column("address_description", sa.String(length=256), nullable=True),
        sa.Column("latitude", sa.Float(), nullable=False),
        sa.Column("longitude", sa.Float(), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.text("CURRENT_TIMESTAMP"), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), server_default=sa.text("CURRENT_TIMESTAMP"), nullable=False),
        sa.CheckConstraint("length(trim(label)) > 0", name="saved_place_label_not_blank"),
        sa.CheckConstraint("latitude >= -90.0 AND latitude <= 90.0", name="saved_place_latitude_valid"),
        sa.CheckConstraint("longitude >= -180.0 AND longitude <= 180.0", name="saved_place_longitude_valid"),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index("ix_user_saved_places_user_id", "user_saved_places", ["user_id"])

    op.add_column("search_index_records", sa.Column("branch_latitude", sa.Float(), nullable=True))
    op.add_column("search_index_records", sa.Column("branch_longitude", sa.Float(), nullable=True))


def downgrade() -> None:
    op.drop_column("search_index_records", "branch_longitude")
    op.drop_column("search_index_records", "branch_latitude")
    op.drop_index("ix_user_saved_places_user_id", table_name="user_saved_places")
    op.drop_table("user_saved_places")

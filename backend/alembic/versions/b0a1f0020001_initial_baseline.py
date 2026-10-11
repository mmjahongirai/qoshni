"""Initial baseline revision anchor.

Revision ID: b0a1f0020001
Revises:
Create Date: 2026-04-11 00:00:00.000000

PostGIS may already be enabled on managed Supabase projects. This revision
does not create extensions, business tables, or other application schema.
"""

from typing import Sequence, Union

# revision identifiers, used by Alembic.
revision: str = "b0a1f0020001"
down_revision: Union[str, Sequence[str], None] = None
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Upgrade schema."""
    pass


def downgrade() -> None:
    """Downgrade schema."""
    pass

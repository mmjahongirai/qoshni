"""Platform role assignment foundation for business onboarding reviewers.

Revision ID: b0a1f0110001
Revises: b0a1f0100001
Create Date: 2026-10-15 15:55:00.000000

Creates user_platform_role_assignments with partial unique active grants.
No privileged role rows are seeded.
"""

from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op

revision: str = "b0a1f0110001"
down_revision: Union[str, Sequence[str], None] = "b0a1f0100001"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None

_ROLES = ("business_onboarding_reviewer",)
_GRANT_SOURCES = ("operator_control_plane", "role_admin_api")
_REVOCATION_REASONS = (
    "operator_revocation",
    "superseded_by_new_grant",
    "security_action",
    "role_admin_api",
)

_ACTIVE_WHERE = "revoked_at IS NULL"


def _tz() -> sa.DateTime:
    return sa.DateTime(timezone=True)


def _in_list(column: str, values: tuple[str, ...]) -> str:
    joined = ", ".join(f"'{value}'" for value in values)
    return f"{column} IN ({joined})"


def upgrade() -> None:
    op.create_table(
        "user_platform_role_assignments",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("user_id", sa.Uuid(), nullable=False),
        sa.Column("role", sa.String(length=48), nullable=False),
        sa.Column("granted_at", _tz(), server_default=sa.func.now(), nullable=False),
        sa.Column("expires_at", _tz(), nullable=True),
        sa.Column("revoked_at", _tz(), nullable=True),
        sa.Column("revocation_reason", sa.String(length=48), nullable=True),
        sa.Column("granted_by_user_id", sa.Uuid(), nullable=True),
        sa.Column("grant_source", sa.String(length=48), nullable=False),
        sa.Column("grant_reference", sa.String(length=128), nullable=True),
        sa.CheckConstraint(
            _in_list("role", _ROLES),
            name=op.f("ck_user_platform_role_assignments_role_valid"),
        ),
        sa.CheckConstraint(
            _in_list("grant_source", _GRANT_SOURCES),
            name=op.f("ck_user_platform_role_assignments_grant_source_valid"),
        ),
        sa.CheckConstraint(
            f"revocation_reason IS NULL OR {_in_list('revocation_reason', _REVOCATION_REASONS)}",
            name=op.f("ck_user_platform_role_assignments_revocation_reason_valid"),
        ),
        sa.CheckConstraint(
            "(revoked_at IS NULL) = (revocation_reason IS NULL)",
            name=op.f("ck_user_platform_role_assignments_revocation_consistent"),
        ),
        sa.CheckConstraint(
            "expires_at IS NULL OR expires_at >= granted_at",
            name=op.f("ck_user_platform_role_assignments_expires_at_not_before_granted_at"),
        ),
        sa.CheckConstraint(
            "revoked_at IS NULL OR revoked_at >= granted_at",
            name=op.f("ck_user_platform_role_assignments_revoked_at_not_before_granted_at"),
        ),
        sa.CheckConstraint(
            "grant_reference IS NULL OR length(trim(grant_reference)) > 0",
            name=op.f("ck_user_platform_role_assignments_grant_reference_not_blank"),
        ),
        sa.CheckConstraint(
            "grant_reference IS NULL OR grant_reference = trim(grant_reference)",
            name=op.f("ck_user_platform_role_assignments_grant_reference_trimmed"),
        ),
        sa.ForeignKeyConstraint(
            ["user_id"],
            ["users.id"],
            name=op.f("fk_user_platform_role_assignments_user_id_users"),
            ondelete="CASCADE",
        ),
        sa.ForeignKeyConstraint(
            ["granted_by_user_id"],
            ["users.id"],
            name=op.f("fk_user_platform_role_assignments_granted_by_user_id_users"),
            ondelete="SET NULL",
        ),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_user_platform_role_assignments")),
    )
    op.create_index(
        op.f("ix_user_platform_role_assignments_user_id_role_granted_at"),
        "user_platform_role_assignments",
        ["user_id", "role", "granted_at"],
    )
    op.create_index(
        op.f("uq_user_platform_role_assignment_active"),
        "user_platform_role_assignments",
        ["user_id", "role"],
        unique=True,
        sqlite_where=sa.text(_ACTIVE_WHERE),
        postgresql_where=sa.text(_ACTIVE_WHERE),
    )


def downgrade() -> None:
    op.drop_index(
        op.f("uq_user_platform_role_assignment_active"),
        table_name="user_platform_role_assignments",
    )
    op.drop_index(
        op.f("ix_user_platform_role_assignments_user_id_role_granted_at"),
        table_name="user_platform_role_assignments",
    )
    op.drop_table("user_platform_role_assignments")

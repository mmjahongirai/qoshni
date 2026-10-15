"""Race-safe active registration duplicate protection.

Revision ID: b0a1f0090001
Revises: b0a1f0080001
Create Date: 2026-10-15 10:20:00.000000

Adds a partial unique index on (registration_jurisdiction, registration_identifier)
for active verification statuses and requires stored identifiers to be trimmed.
"""

from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op

revision: str = "b0a1f0090001"
down_revision: Union[str, Sequence[str], None] = "b0a1f0080001"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None

_ACTIVE_STATUSES = ("submitted", "under_review", "verified", "suspended")

_PARTIAL_WHERE = (
    "verification_status IN ('submitted', 'under_review', 'verified', 'suspended') "
    "AND registration_identifier IS NOT NULL "
    "AND length(trim(registration_identifier)) > 0"
)


def _preflight_no_active_registration_duplicates(connection: sa.Connection) -> None:
    duplicates = connection.execute(
        sa.text(
            """
            SELECT registration_jurisdiction, registration_identifier, COUNT(*) AS row_count
            FROM business_onboarding_applications
            WHERE verification_status IN ('submitted', 'under_review', 'verified', 'suspended')
              AND registration_identifier IS NOT NULL
              AND length(trim(registration_identifier)) > 0
            GROUP BY registration_jurisdiction, registration_identifier
            HAVING COUNT(*) > 1
            """,
        ),
    ).fetchall()
    if duplicates:
        raise RuntimeError(
            "Cannot add uq_business_onboarding_active_registration: "
            "duplicate active registration identifiers already exist. "
            "Resolve conflicts manually before upgrading.",
        )


def upgrade() -> None:
    connection = op.get_bind()
    _preflight_no_active_registration_duplicates(connection)

    with op.batch_alter_table("business_onboarding_applications") as batch_op:
        batch_op.create_check_constraint(
            op.f("ck_business_onboarding_applications_registration_identifier_trimmed"),
            "registration_identifier IS NULL OR registration_identifier = trim(registration_identifier)",
        )

    op.create_index(
        "uq_business_onboarding_active_registration",
        "business_onboarding_applications",
        ["registration_jurisdiction", "registration_identifier"],
        unique=True,
        postgresql_where=sa.text(_PARTIAL_WHERE),
        sqlite_where=sa.text(_PARTIAL_WHERE),
    )


def downgrade() -> None:
    op.drop_index(
        "uq_business_onboarding_active_registration",
        table_name="business_onboarding_applications",
    )
    with op.batch_alter_table("business_onboarding_applications") as batch_op:
        batch_op.drop_constraint(
            op.f("ck_business_onboarding_applications_registration_identifier_trimmed"),
            type_="check",
        )

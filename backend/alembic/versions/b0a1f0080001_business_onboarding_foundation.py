"""Business onboarding and verification audit foundation.

Revision ID: b0a1f0080001
Revises: b0a1f0070001
Create Date: 2026-10-14 21:30:00.000000

Creates business_onboarding_applications and business_onboarding_audit_events.
Enum literals are written explicitly so this revision stays stable if Python
enums evolve.
"""

from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op

revision: str = "b0a1f0080001"
down_revision: Union[str, Sequence[str], None] = "b0a1f0070001"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None

_SERVICE_CATEGORIES = ("groceries", "restaurants", "pharmacy", "shops", "masters", "rent")
_STATUSES = ("draft", "submitted", "under_review", "verified", "rejected", "suspended")
_REJECTION_CODES = (
    "incomplete_information",
    "registration_mismatch",
    "jurisdiction_unsupported",
    "policy_violation",
    "other",
)
_AUDIT_EVENT_TYPES = (
    "application_created",
    "draft_updated",
    "submitted",
    "status_changed",
    "reinstatement_requested",
)
_AUDIT_ACTOR_ROLES = ("owner", "reviewer", "system")


def _tz() -> sa.DateTime:
    return sa.DateTime(timezone=True)


def _in_list(column: str, values: tuple[str, ...]) -> str:
    joined = ", ".join(f"'{value}'" for value in values)
    return f"{column} IN ({joined})"


def upgrade() -> None:
    op.create_table(
        "business_onboarding_applications",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("owner_user_id", sa.Uuid(), nullable=False),
        sa.Column("legal_business_name", sa.String(length=256), nullable=True),
        sa.Column("trade_display_name", sa.String(length=128), nullable=True),
        sa.Column("service_category", sa.String(length=32), nullable=True),
        sa.Column(
            "registration_jurisdiction",
            sa.String(length=2),
            server_default="UZ",
            nullable=False,
        ),
        sa.Column("registration_identifier", sa.String(length=64), nullable=True),
        sa.Column("tax_identifier", sa.String(length=64), nullable=True),
        sa.Column("business_contact_email", sa.String(length=320), nullable=True),
        sa.Column(
            "verification_status",
            sa.String(length=32),
            server_default="draft",
            nullable=False,
        ),
        sa.Column("rejection_reason_code", sa.String(length=48), nullable=True),
        sa.Column("submitted_at", _tz(), nullable=True),
        sa.Column("reviewed_at", _tz(), nullable=True),
        sa.Column("created_at", _tz(), server_default=sa.func.now(), nullable=False),
        sa.Column("updated_at", _tz(), server_default=sa.func.now(), nullable=False),
        sa.CheckConstraint(
            "(service_category IS NULL OR "
            + _in_list("service_category", _SERVICE_CATEGORIES)
            + ")",
            name=op.f("ck_business_onboarding_applications_service_category_valid"),
        ),
        sa.CheckConstraint(
            _in_list("verification_status", _STATUSES),
            name=op.f("ck_business_onboarding_applications_verification_status_valid"),
        ),
        sa.CheckConstraint(
            "rejection_reason_code IS NULL OR "
            + _in_list("rejection_reason_code", _REJECTION_CODES),
            name=op.f("ck_business_onboarding_applications_rejection_reason_code_valid"),
        ),
        sa.CheckConstraint(
            "length(registration_jurisdiction) = 2",
            name=op.f("ck_business_onboarding_applications_registration_jurisdiction_iso_alpha2"),
        ),
        sa.CheckConstraint(
            "legal_business_name IS NULL OR length(trim(legal_business_name)) > 0",
            name=op.f("ck_business_onboarding_applications_legal_business_name_not_blank"),
        ),
        sa.CheckConstraint(
            "trade_display_name IS NULL OR length(trim(trade_display_name)) > 0",
            name=op.f("ck_business_onboarding_applications_trade_display_name_not_blank"),
        ),
        sa.CheckConstraint(
            "registration_identifier IS NULL OR length(trim(registration_identifier)) > 0",
            name=op.f("ck_business_onboarding_applications_registration_identifier_not_blank"),
        ),
        sa.CheckConstraint(
            "tax_identifier IS NULL OR length(trim(tax_identifier)) > 0",
            name=op.f("ck_business_onboarding_applications_tax_identifier_not_blank"),
        ),
        sa.CheckConstraint(
            "business_contact_email IS NULL OR length(trim(business_contact_email)) > 0",
            name=op.f("ck_business_onboarding_applications_business_contact_email_not_blank"),
        ),
        sa.CheckConstraint(
            "(verification_status != 'rejected') OR (rejection_reason_code IS NOT NULL)",
            name=op.f("ck_business_onboarding_applications_rejected_requires_reason_code"),
        ),
        sa.CheckConstraint(
            "(verification_status = 'rejected') OR (rejection_reason_code IS NULL)",
            name=op.f("ck_business_onboarding_applications_reason_code_only_when_rejected"),
        ),
        sa.CheckConstraint(
            "(verification_status = 'draft') OR (submitted_at IS NOT NULL)",
            name=op.f("ck_business_onboarding_applications_submitted_timestamp_when_not_draft"),
        ),
        sa.ForeignKeyConstraint(
            ["owner_user_id"],
            ["users.id"],
            name=op.f("fk_business_onboarding_applications_owner_user_id_users"),
            ondelete="CASCADE",
        ),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_business_onboarding_applications")),
    )
    op.create_index(
        op.f("ix_business_onboarding_applications_owner_user_id_created_at"),
        "business_onboarding_applications",
        ["owner_user_id", "created_at"],
    )
    op.create_index(
        op.f("ix_business_onboarding_applications_verification_status_updated_at"),
        "business_onboarding_applications",
        ["verification_status", "updated_at"],
    )
    op.create_index(
        op.f("ix_business_onboarding_applications_registration_jurisdiction_registration_identifier"),
        "business_onboarding_applications",
        ["registration_jurisdiction", "registration_identifier"],
    )

    op.create_table(
        "business_onboarding_audit_events",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("application_id", sa.Uuid(), nullable=False),
        sa.Column("event_type", sa.String(length=48), nullable=False),
        sa.Column("from_status", sa.String(length=32), nullable=True),
        sa.Column("to_status", sa.String(length=32), nullable=True),
        sa.Column("actor_role", sa.String(length=16), nullable=True),
        sa.Column("actor_user_id", sa.Uuid(), nullable=True),
        sa.Column("correlation_id", sa.String(length=64), nullable=True),
        sa.Column("details", sa.JSON(), nullable=True),
        sa.Column("occurred_at", _tz(), server_default=sa.func.now(), nullable=False),
        sa.CheckConstraint(
            _in_list("event_type", _AUDIT_EVENT_TYPES),
            name=op.f("ck_business_onboarding_audit_events_event_type_valid"),
        ),
        sa.CheckConstraint(
            "actor_role IS NULL OR " + _in_list("actor_role", _AUDIT_ACTOR_ROLES),
            name=op.f("ck_business_onboarding_audit_events_actor_role_valid"),
        ),
        sa.CheckConstraint(
            "from_status IS NULL OR " + _in_list("from_status", _STATUSES),
            name=op.f("ck_business_onboarding_audit_events_from_status_valid"),
        ),
        sa.CheckConstraint(
            "to_status IS NULL OR " + _in_list("to_status", _STATUSES),
            name=op.f("ck_business_onboarding_audit_events_to_status_valid"),
        ),
        sa.ForeignKeyConstraint(
            ["application_id"],
            ["business_onboarding_applications.id"],
            name=op.f("fk_business_onboarding_audit_events_application_id_business_onboarding_applications"),
            ondelete="CASCADE",
        ),
        sa.ForeignKeyConstraint(
            ["actor_user_id"],
            ["users.id"],
            name=op.f("fk_business_onboarding_audit_events_actor_user_id_users"),
            ondelete="SET NULL",
        ),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_business_onboarding_audit_events")),
    )
    op.create_index(
        op.f("ix_business_onboarding_audit_events_application_id_occurred_at"),
        "business_onboarding_audit_events",
        ["application_id", "occurred_at"],
    )
    op.create_index(
        op.f("ix_business_onboarding_audit_events_event_type_occurred_at"),
        "business_onboarding_audit_events",
        ["event_type", "occurred_at"],
    )


def downgrade() -> None:
    op.drop_table("business_onboarding_audit_events")
    op.drop_table("business_onboarding_applications")

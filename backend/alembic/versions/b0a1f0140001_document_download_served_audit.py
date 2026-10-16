"""Add document_download_served onboarding audit event type.

Revision ID: b0a1f0140001
Revises: b0a1f0130001
Create Date: 2026-10-16 15:30:00.000000
"""

from typing import Sequence, Union

from alembic import op
from sqlalchemy import text

revision: str = "b0a1f0140001"
down_revision: Union[str, Sequence[str], None] = "b0a1f0130001"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None

_AUDIT_EVENT_TYPES = (
    "application_created",
    "draft_updated",
    "submitted",
    "status_changed",
    "reinstatement_requested",
    "document_registered",
    "document_upload_completed",
    "document_upload_failed",
    "document_deleted",
    "document_reconciliation_detected",
    "document_reconciliation_resolved",
    "document_download_served",
)

_PRE_DOWNLOAD_EVENT_TYPES = (
    "application_created",
    "draft_updated",
    "submitted",
    "status_changed",
    "reinstatement_requested",
    "document_registered",
    "document_upload_completed",
    "document_upload_failed",
    "document_deleted",
    "document_reconciliation_detected",
    "document_reconciliation_resolved",
)


def _in_list(column: str, values: tuple[str, ...]) -> str:
    joined = ", ".join(f"'{value}'" for value in values)
    return f"{column} IN ({joined})"


def upgrade() -> None:
    constraint_name = op.f("ck_business_onboarding_audit_events_event_type_valid")
    with op.batch_alter_table("business_onboarding_audit_events", schema=None) as batch_op:
        batch_op.drop_constraint(constraint_name, type_="check")
        batch_op.create_check_constraint(
            constraint_name,
            _in_list("event_type", _AUDIT_EVENT_TYPES),
        )


def downgrade() -> None:
    connection = op.get_bind()
    blocked_count = connection.execute(
        text(
            "SELECT COUNT(*) FROM business_onboarding_audit_events "
            "WHERE event_type = 'document_download_served'",
        ),
    ).scalar()
    if blocked_count:
        raise RuntimeError(
            "Cannot downgrade b0a1f0140001: "
            f"{blocked_count} business_onboarding_audit_events row(s) use "
            "event_type 'document_download_served'. Archive or migrate those "
            "audit events before removing this event type from the schema.",
        )

    constraint_name = op.f("ck_business_onboarding_audit_events_event_type_valid")
    with op.batch_alter_table("business_onboarding_audit_events", schema=None) as batch_op:
        batch_op.drop_constraint(constraint_name, type_="check")
        batch_op.create_check_constraint(
            constraint_name,
            _in_list("event_type", _PRE_DOWNLOAD_EVENT_TYPES),
        )

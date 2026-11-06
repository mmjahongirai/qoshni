"""Operator trigger and health view for stale reservation cleanup."""

from __future__ import annotations

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.api.deps.reviewer import require_business_onboarding_reviewer
from app.api.schemas.business_catalog import (
    ReservationMaintenanceRunView,
    ReservationMaintenanceStatusView,
)
from app.core.database import get_db
from app.services.auth.principal import BusinessOnboardingReviewerPrincipal
from app.services.checkout.reservation_maintenance import (
    reservation_maintenance_status,
    sweep_stale_reservations,
)

router = APIRouter(prefix="/internal/inventory", tags=["inventory-maintenance"])


def _status_view(session: Session) -> ReservationMaintenanceStatusView:
    status = reservation_maintenance_status(session)
    return ReservationMaintenanceStatusView(
        overdue_held_count=status.overdue_held_count,
        oldest_overdue_expires_at=status.oldest_overdue_expires_at,
        last_run_finished_at=status.last_run_finished_at,
        last_run_outcome=status.last_run_outcome,
        last_expired_count=status.last_expired_count,
        last_error_message=status.last_error_message,
    )


@router.get("/reservation-maintenance", response_model=ReservationMaintenanceStatusView)
def get_reservation_maintenance(
    _: BusinessOnboardingReviewerPrincipal = Depends(require_business_onboarding_reviewer),
    session: Session = Depends(get_db),
) -> ReservationMaintenanceStatusView:
    return _status_view(session)


@router.post("/reservation-maintenance", response_model=ReservationMaintenanceRunView)
def post_reservation_maintenance(
    principal: BusinessOnboardingReviewerPrincipal = Depends(require_business_onboarding_reviewer),
    session: Session = Depends(get_db),
) -> ReservationMaintenanceRunView:
    expired = sweep_stale_reservations(
        session,
        worker_id=f"reviewer:{principal.user_id}",
        record=True,
    )
    session.commit()
    return ReservationMaintenanceRunView(expired_count=expired, status=_status_view(session))

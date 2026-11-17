"""Business-owner order decisions that already exist on the state machine."""

from __future__ import annotations

import uuid

from fastapi import APIRouter, Depends
from fastapi.responses import JSONResponse
from pydantic import BaseModel, ConfigDict, Field
from sqlalchemy.orm import Session

from app.api.deps.access import get_current_principal
from app.api.schemas.order_placement import (
    OrderLineSnapshotView,
    OrderPlacementErrorResponse,
    PlaceOrderResponse,
)
from app.core.database import get_db
from app.services.auth.principal import AuthenticatedPrincipal
from app.services.checkout.sql_order_repository import (
    OrderRejectionOutcome,
    SqlOrderLifecycleService,
)

router = APIRouter(
    prefix="/business/onboarding/applications/{application_id}/orders",
    tags=["business-orders"],
)


class OrderRejectionRequest(BaseModel):
    model_config = ConfigDict(extra="forbid")

    reason: str | None = Field(default=None, max_length=256)


def _order_response(record, *, replay: bool) -> PlaceOrderResponse:
    return PlaceOrderResponse(
        order_id=record.order_id,
        status=record.status,
        payment_status=record.payment_status,
        fulfillment_status=record.fulfillment_status,
        currency_code=record.currency_code,
        subtotal_minor=record.subtotal_minor,
        total_minor=record.total_minor,
        checkout_correlation_id=record.checkout_correlation_id,
        idempotent_replay=replay,
        created_at=record.created_at,
        lines=[
            OrderLineSnapshotView(
                business_stable_id=line.business_stable_id,
                catalog_item_stable_id=line.catalog_item_stable_id,
                title_snapshot=line.title_snapshot,
                quantity=line.quantity,
                unit_price_minor=line.unit_price_minor,
                line_subtotal_minor=line.line_subtotal_minor,
                currency_code=line.currency_code,
            )
            for line in record.lines
        ],
    )


@router.post(
    "/{order_id}/rejection",
    response_model=PlaceOrderResponse,
    responses={
        404: {"model": OrderPlacementErrorResponse},
        409: {"model": OrderPlacementErrorResponse},
    },
)
def post_reject_order(
    application_id: uuid.UUID,
    order_id: uuid.UUID,
    body: OrderRejectionRequest | None = None,
    principal: AuthenticatedPrincipal = Depends(get_current_principal),
    session: Session = Depends(get_db),
) -> PlaceOrderResponse | JSONResponse:
    reason = "business_rejected" if body is None or not body.reason else body.reason
    result = SqlOrderLifecycleService(session).reject_order(
        owner_user_id=principal.user_id,
        business_application_id=application_id,
        order_id=order_id,
        reason=reason,
    )
    if result.outcome == OrderRejectionOutcome.NOT_FOUND or result.record is None:
        session.rollback()
        status = 404 if result.outcome == OrderRejectionOutcome.NOT_FOUND else 409
        return JSONResponse(
            status_code=status,
            content=OrderPlacementErrorResponse(
                code=result.outcome.value,
                message=(
                    "Order not found."
                    if result.outcome == OrderRejectionOutcome.NOT_FOUND
                    else "This order cannot be rejected."
                ),
            ).model_dump(),
        )
    session.commit()
    return _order_response(
        result.record,
        replay=result.outcome == OrderRejectionOutcome.REPLAY,
    )

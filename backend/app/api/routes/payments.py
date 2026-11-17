"""Buyer payment creation and owner read. No release, refund, or settlement."""

from __future__ import annotations

import uuid
from typing import NoReturn

from fastapi import APIRouter, Depends, Header, HTTPException, status
from sqlalchemy.orm import Session

from app.api.deps.access import get_current_principal
from app.api.schemas.payment import (
    CreatePaymentRequest,
    PaymentErrorResponse,
    PaymentView,
    WalletHoldListResponse,
    WalletHoldView,
)
from app.core.database import get_db
from app.db.models.payment import Payment, WalletHold
from app.domain.payment import PaymentErrorCode, PaymentStatus, WalletHoldStatus
from app.services.auth.principal import AuthenticatedPrincipal
from app.services.wallet.payment_service import (
    PaymentError,
    PaymentResult,
    create_payment,
    get_payment,
    list_payment_holds,
)

router = APIRouter(prefix="/payments", tags=["payments"])

_STATUS = {
    PaymentErrorCode.VALIDATION_FAILED.value: 422,
    PaymentErrorCode.ORDER_NOT_FOUND.value: status.HTTP_404_NOT_FOUND,
    PaymentErrorCode.ORDER_NOT_PAYABLE.value: status.HTTP_409_CONFLICT,
    PaymentErrorCode.PAYMENT_ALREADY_EXISTS.value: status.HTTP_409_CONFLICT,
    PaymentErrorCode.INSUFFICIENT_BALANCE.value: status.HTTP_409_CONFLICT,
    PaymentErrorCode.IDEMPOTENCY_CONFLICT.value: status.HTTP_409_CONFLICT,
    PaymentErrorCode.CURRENCY_MISMATCH.value: 422,
    PaymentErrorCode.WALLET_NOT_FOUND.value: status.HTTP_404_NOT_FOUND,
    PaymentErrorCode.BUSINESS_WALLET_UNAVAILABLE.value: status.HTTP_409_CONFLICT,
    PaymentErrorCode.PAYMENT_NOT_FOUND.value: status.HTTP_404_NOT_FOUND,
}


def _fail(error: PaymentError) -> NoReturn:
    raise HTTPException(
        status_code=_STATUS.get(error.code.value, 422),
        detail=PaymentErrorResponse(code=error.code.value, message=error.message).model_dump(),
    )


def _payment_view(result: PaymentResult) -> PaymentView:
    return PaymentView(
        payment_id=result.payment.id,
        order_id=result.payment.order_id,
        amount_minor=result.payment.amount_minor,
        currency_code=result.payment.currency_code,
        status=PaymentStatus(result.payment.status),
        hold_id=result.hold.id,
        created_at=result.payment.created_at,
        idempotent_replay=result.idempotent_replay,
    )


def _stored_view(payment: Payment, hold: WalletHold) -> PaymentView:
    return _payment_view(PaymentResult(payment=payment, hold=hold, idempotent_replay=False))


@router.post("", response_model=PaymentView, status_code=status.HTTP_201_CREATED)
def post_payment(
    body: CreatePaymentRequest,
    principal: AuthenticatedPrincipal = Depends(get_current_principal),
    session: Session = Depends(get_db),
    idempotency_key: str | None = Header(default=None, alias="Idempotency-Key"),
) -> PaymentView:
    if idempotency_key is None:
        _fail(
            PaymentError(
                code=PaymentErrorCode.VALIDATION_FAILED,
                message="Idempotency key is required.",
            )
        )
    result = create_payment(
        session,
        buyer_user_id=principal.user_id,
        order_id=body.order_id,
        payment_method=body.payment_method,
        idempotency_key=idempotency_key,
    )
    if isinstance(result, PaymentError):
        session.rollback()
        _fail(result)
    session.commit()
    return _payment_view(result)


@router.get("/{payment_id}", response_model=PaymentView)
def get_one_payment(
    payment_id: uuid.UUID,
    principal: AuthenticatedPrincipal = Depends(get_current_principal),
    session: Session = Depends(get_db),
) -> PaymentView:
    payment = get_payment(session, actor_user_id=principal.user_id, payment_id=payment_id)
    if isinstance(payment, PaymentError):
        _fail(payment)
    holds = list_payment_holds(session, actor_user_id=principal.user_id, payment_id=payment_id)
    if isinstance(holds, PaymentError) or not holds:
        _fail(
            PaymentError(
                code=PaymentErrorCode.PAYMENT_NOT_FOUND,
                message="Payment not found.",
            )
        )
    return _stored_view(payment, holds[0])


@router.get("/{payment_id}/holds", response_model=WalletHoldListResponse)
def get_payment_holds(
    payment_id: uuid.UUID,
    principal: AuthenticatedPrincipal = Depends(get_current_principal),
    session: Session = Depends(get_db),
) -> WalletHoldListResponse:
    holds = list_payment_holds(session, actor_user_id=principal.user_id, payment_id=payment_id)
    if isinstance(holds, PaymentError):
        _fail(holds)
    return WalletHoldListResponse(
        holds=[
            WalletHoldView(
                hold_id=hold.id,
                payment_id=hold.payment_id,
                order_id=hold.order_id,
                wallet_id=hold.wallet_id,
                amount_minor=hold.amount_minor,
                currency_code=hold.currency_code,
                status=WalletHoldStatus(hold.status),
                reason=hold.reason,
                created_at=hold.created_at,
            )
            for hold in holds
        ]
    )

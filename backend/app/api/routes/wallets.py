"""Read and idempotently open wallets. There is no public ledger mutation."""

from __future__ import annotations

import uuid
from typing import NoReturn

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.api.deps.access import get_current_principal
from app.api.schemas.wallet import WalletErrorResponse, WalletView
from app.core.database import get_db
from app.db.models.wallet import Wallet
from app.domain.wallet import WalletOwnerType, WalletStatus
from app.services.auth.principal import AuthenticatedPrincipal
from app.services.wallet.wallet_service import (
    WalletAccessError,
    WalletAccessErrorCode,
    get_or_create_business_wallet,
    get_or_create_user_wallet,
)

router = APIRouter(tags=["wallets"])

_STATUS = {
    WalletAccessErrorCode.BUSINESS_NOT_FOUND.value: status.HTTP_404_NOT_FOUND,
    WalletAccessErrorCode.BUSINESS_NOT_VERIFIED.value: status.HTTP_403_FORBIDDEN,
    WalletAccessErrorCode.CURRENCY_MISMATCH.value: 422,
}


def _fail(error: WalletAccessError) -> NoReturn:
    raise HTTPException(
        status_code=_STATUS.get(error.code.value, 422),
        detail=WalletErrorResponse(code=error.code.value, message=error.message).model_dump(),
    )


def _view(wallet: Wallet) -> WalletView:
    return WalletView(
        wallet_id=wallet.id,
        owner_type=WalletOwnerType(wallet.owner_type),
        owner_id=wallet.owner_id,
        currency_code=wallet.currency_code,
        available_minor=wallet.available_minor,
        hold_minor=wallet.hold_minor,
        pending_minor=wallet.pending_minor,
        status=WalletStatus(wallet.status),
    )


@router.get("/wallets/me", response_model=WalletView)
def get_my_wallet(
    principal: AuthenticatedPrincipal = Depends(get_current_principal),
    session: Session = Depends(get_db),
) -> WalletView:
    result = get_or_create_user_wallet(session, user_id=principal.user_id)
    if isinstance(result, WalletAccessError):
        session.rollback()
        _fail(result)
    session.commit()
    return _view(result)


@router.get(
    "/business/onboarding/applications/{application_id}/wallet",
    response_model=WalletView,
)
def get_business_wallet(
    application_id: uuid.UUID,
    principal: AuthenticatedPrincipal = Depends(get_current_principal),
    session: Session = Depends(get_db),
) -> WalletView:
    result = get_or_create_business_wallet(
        session,
        owner_user_id=principal.user_id,
        business_application_id=application_id,
    )
    if isinstance(result, WalletAccessError):
        session.rollback()
        _fail(result)
    session.commit()
    return _view(result)

"""Open and read wallets. Creation is idempotent for one owner and currency.

Business wallets use the onboarding application UUID. A Flutter business
profile id is not an owner. Courier wallets are not part of this service.
"""

from __future__ import annotations

import uuid
from dataclasses import dataclass
from enum import StrEnum

from sqlalchemy import select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from app.db.models.business_onboarding import BusinessOnboardingApplication
from app.db.models.wallet import Wallet
from app.domain.business_onboarding import VerificationStatus
from app.domain.wallet import (
    AUTHORITATIVE_CURRENCY,
    PLATFORM_WALLET_ID,
    PLATFORM_WALLET_OWNER_ID,
    WalletOwnerType,
    WalletStatus,
)


class WalletAccessErrorCode(StrEnum):
    BUSINESS_NOT_FOUND = "business_not_found"
    BUSINESS_NOT_VERIFIED = "business_not_verified"
    CURRENCY_MISMATCH = "currency_mismatch"


@dataclass(frozen=True, slots=True)
class WalletAccessError:
    code: WalletAccessErrorCode
    message: str


def _find_wallet(
    session: Session,
    *,
    owner_type: WalletOwnerType,
    owner_id: uuid.UUID,
    currency_code: str,
) -> Wallet | None:
    return session.scalar(
        select(Wallet).where(
            Wallet.owner_type == owner_type.value,
            Wallet.owner_id == owner_id,
            Wallet.currency_code == currency_code,
        )
    )


def get_wallet(
    session: Session,
    *,
    owner_type: WalletOwnerType,
    owner_id: uuid.UUID,
    currency_code: str = AUTHORITATIVE_CURRENCY,
) -> Wallet | None:
    if owner_type is WalletOwnerType.PLATFORM:
        owner_id = PLATFORM_WALLET_OWNER_ID
    return _find_wallet(
        session,
        owner_type=owner_type,
        owner_id=owner_id,
        currency_code=currency_code,
    )


def get_or_create_wallet(
    session: Session,
    *,
    owner_type: WalletOwnerType,
    owner_id: uuid.UUID,
    currency_code: str = AUTHORITATIVE_CURRENCY,
    wallet_id: uuid.UUID | None = None,
) -> Wallet | WalletAccessError:
    """Return the existing wallet or insert one. A second call does not insert another row."""

    if currency_code != AUTHORITATIVE_CURRENCY:
        return WalletAccessError(
            code=WalletAccessErrorCode.CURRENCY_MISMATCH,
            message="Only the authoritative currency can be opened.",
        )
    if owner_type is WalletOwnerType.PLATFORM:
        owner_id = PLATFORM_WALLET_OWNER_ID
        wallet_id = PLATFORM_WALLET_ID
    existing = _find_wallet(
        session,
        owner_type=owner_type,
        owner_id=owner_id,
        currency_code=currency_code,
    )
    if existing is not None:
        return existing

    wallet = Wallet(
        id=wallet_id or uuid.uuid4(),
        owner_type=owner_type.value,
        owner_id=owner_id,
        currency_code=currency_code,
        available_minor=0,
        hold_minor=0,
        pending_minor=0,
        status=WalletStatus.ACTIVE.value,
    )
    try:
        with session.begin_nested():
            session.add(wallet)
            session.flush()
    except IntegrityError:
        found = _find_wallet(
            session,
            owner_type=owner_type,
            owner_id=owner_id,
            currency_code=currency_code,
        )
        if found is None and owner_type is WalletOwnerType.PLATFORM:
            found = session.scalar(
                select(Wallet).where(
                    Wallet.owner_type == WalletOwnerType.PLATFORM.value,
                    Wallet.currency_code == currency_code,
                )
            )
        if found is None:
            raise
        return found
    return wallet


def get_or_create_user_wallet(session: Session, *, user_id: uuid.UUID) -> Wallet | WalletAccessError:
    return get_or_create_wallet(
        session,
        owner_type=WalletOwnerType.USER,
        owner_id=user_id,
    )


def get_or_create_business_wallet(
    session: Session,
    *,
    owner_user_id: uuid.UUID,
    business_application_id: uuid.UUID,
) -> Wallet | WalletAccessError:
    """Open the application wallet. A non-owner receives the same not-found result as a missing application."""

    application = session.get(BusinessOnboardingApplication, business_application_id)
    if application is None or application.owner_user_id != owner_user_id:
        return WalletAccessError(
            code=WalletAccessErrorCode.BUSINESS_NOT_FOUND,
            message="Business not found.",
        )
    if application.verification_status != VerificationStatus.VERIFIED.value:
        return WalletAccessError(
            code=WalletAccessErrorCode.BUSINESS_NOT_VERIFIED,
            message="Only verified businesses can open a wallet.",
        )
    return get_or_create_wallet(
        session,
        owner_type=WalletOwnerType.BUSINESS_APPLICATION,
        owner_id=business_application_id,
    )


def ensure_platform_wallet(session: Session) -> Wallet | WalletAccessError:
    return get_or_create_wallet(
        session,
        owner_type=WalletOwnerType.PLATFORM,
        owner_id=PLATFORM_WALLET_OWNER_ID,
        wallet_id=PLATFORM_WALLET_ID,
    )

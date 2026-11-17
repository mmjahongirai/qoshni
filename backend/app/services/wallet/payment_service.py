"""Create a wallet hold for an unpaid order.

The payable amount is ``consumer_orders.total_minor``. A successful hold moves
the buyer's available balance into hold and leaves the business wallet unchanged.
Inventory reservations are not touched.

PostgreSQL locks the order with ``SELECT … FOR UPDATE``. The wallet lock is the
WP1 posting lock. Other dialects claim the order with a conditional
``payment_status`` update. SQLite coverage does not verify PostgreSQL concurrency.
"""

from __future__ import annotations

import hashlib
import json
import uuid
from dataclasses import dataclass
from datetime import UTC, datetime

from sqlalchemy import select, update
from sqlalchemy.exc import IntegrityError, OperationalError
from sqlalchemy.orm import Session

from app.db.models.business_onboarding import BusinessOnboardingApplication
from app.db.models.consumer_orders import ConsumerOrder
from app.db.models.payment import Payment, PaymentIdempotencyRecord, WalletHold
from app.db.models.wallet import Wallet
from app.domain.business_onboarding import VerificationStatus
from app.domain.order_lifecycle import ConsumerOrderPaymentStatus, ConsumerOrderStatus
from app.domain.payment import (
    PAYMENT_HOLD_REASON,
    PAYMENT_OPERATION,
    PaymentErrorCode,
    PaymentMethod,
    PaymentStatus,
    WalletHoldStatus,
)
from app.domain.wallet import (
    AUTHORITATIVE_CURRENCY,
    LedgerAccountType,
    LedgerDirection,
    WalletOwnerType,
    WalletStatus,
)
from app.services.search_discovery.stable_ids import application_id_from_stable_id
from app.services.wallet.ledger_service import (
    LedgerLeg,
    WalletPostingError,
    WalletPostingErrorCode,
    post_balanced_movement,
)
from app.services.wallet.wallet_service import get_or_create_user_wallet

_PAYABLE_ORDER_STATUSES = {
    ConsumerOrderStatus.PENDING_ACCEPTANCE.value,
    ConsumerOrderStatus.ACCEPTED.value,
}


@dataclass(frozen=True, slots=True)
class PaymentError:
    code: PaymentErrorCode
    message: str


@dataclass(frozen=True, slots=True)
class PaymentResult:
    payment: Payment
    hold: WalletHold
    idempotent_replay: bool


def payment_request_fingerprint(*, order_id: uuid.UUID, payment_method: PaymentMethod) -> str:
    canonical = json.dumps(
        {"order_id": str(order_id), "payment_method": payment_method.value},
        sort_keys=True,
        separators=(",", ":"),
    )
    return hashlib.sha256(canonical.encode("utf-8")).hexdigest()


def _locks_rows(session: Session) -> bool:
    return session.get_bind().dialect.name == "postgresql"


def _find_idempotency(
    session: Session,
    *,
    buyer_user_id: uuid.UUID,
    idempotency_key: str,
) -> PaymentIdempotencyRecord | None:
    return session.scalar(
        select(PaymentIdempotencyRecord).where(
            PaymentIdempotencyRecord.buyer_user_id == buyer_user_id,
            PaymentIdempotencyRecord.operation == PAYMENT_OPERATION,
            PaymentIdempotencyRecord.idempotency_key == idempotency_key,
        )
    )


def _replay(
    session: Session,
    record: PaymentIdempotencyRecord,
    *,
    fingerprint: str,
) -> PaymentResult | PaymentError:
    if record.request_fingerprint != fingerprint:
        return PaymentError(
            code=PaymentErrorCode.IDEMPOTENCY_CONFLICT,
            message="Idempotency key was already used with a different request.",
        )
    payment = session.get(Payment, record.payment_id)
    hold = session.scalar(select(WalletHold).where(WalletHold.payment_id == record.payment_id))
    if payment is None or hold is None:
        return PaymentError(
            code=PaymentErrorCode.VALIDATION_FAILED,
            message="Idempotency record is corrupt.",
        )
    return PaymentResult(payment=payment, hold=hold, idempotent_replay=True)


def _payee_application_id(order: ConsumerOrder) -> uuid.UUID | None:
    application_ids = {
        application_id_from_stable_id(item.business_stable_id) for item in order.items
    }
    if None in application_ids or len(application_ids) != 1:
        return None
    found = application_ids.pop()
    return found if isinstance(found, uuid.UUID) else None


def _load_order(session: Session, order_id: uuid.UUID) -> ConsumerOrder | None:
    statement = select(ConsumerOrder).where(ConsumerOrder.id == order_id)
    if _locks_rows(session):
        statement = statement.with_for_update()
    return session.scalar(statement)


def _claim_order_payment(session: Session, order: ConsumerOrder, moment: datetime) -> bool:
    result = session.execute(
        update(ConsumerOrder)
        .where(
            ConsumerOrder.id == order.id,
            ConsumerOrder.buyer_user_id == order.buyer_user_id,
            ConsumerOrder.payment_status == ConsumerOrderPaymentStatus.UNPAID.value,
            ConsumerOrder.status.in_(tuple(_PAYABLE_ORDER_STATUSES)),
        )
        .values(
            payment_status=ConsumerOrderPaymentStatus.PAYMENT_PENDING.value,
            updated_at=moment,
        )
        .execution_options(synchronize_session=False)
    )
    session.expire(order)
    return result.rowcount == 1


def _apply_payment(
    session: Session,
    *,
    buyer_user_id: uuid.UUID,
    order_id: uuid.UUID,
    payment_method: PaymentMethod,
    idempotency_key: str,
    fingerprint: str,
) -> PaymentResult | PaymentError:
    order = _load_order(session, order_id)
    if order is None or order.buyer_user_id != buyer_user_id:
        return PaymentError(
            code=PaymentErrorCode.ORDER_NOT_FOUND,
            message="Order not found.",
        )
    if order.status not in _PAYABLE_ORDER_STATUSES:
        return PaymentError(
            code=PaymentErrorCode.ORDER_NOT_PAYABLE,
            message="This order cannot be paid.",
        )
    if order.payment_status != ConsumerOrderPaymentStatus.UNPAID.value:
        return PaymentError(
            code=PaymentErrorCode.PAYMENT_ALREADY_EXISTS,
            message="This order already has a payment.",
        )
    if order.currency_code != AUTHORITATIVE_CURRENCY:
        return PaymentError(
            code=PaymentErrorCode.CURRENCY_MISMATCH,
            message="Order currency is not authoritative.",
        )
    if isinstance(order.total_minor, bool) or not isinstance(order.total_minor, int) or order.total_minor <= 0:
        return PaymentError(
            code=PaymentErrorCode.ORDER_NOT_PAYABLE,
            message="Order total cannot be paid.",
        )
    application_id = _payee_application_id(order)
    if application_id is None:
        return PaymentError(
            code=PaymentErrorCode.ORDER_NOT_PAYABLE,
            message="Order payee could not be resolved.",
        )
    application = session.get(BusinessOnboardingApplication, application_id)
    payee = session.scalar(
        select(Wallet).where(
            Wallet.owner_type == WalletOwnerType.BUSINESS_APPLICATION.value,
            Wallet.owner_id == application_id,
            Wallet.currency_code == order.currency_code,
        )
    )
    if (
        application is None
        or application.verification_status != VerificationStatus.VERIFIED.value
        or payee is None
        or payee.status != WalletStatus.ACTIVE.value
    ):
        return PaymentError(
            code=PaymentErrorCode.BUSINESS_WALLET_UNAVAILABLE,
            message="The business wallet is not available.",
        )
    payer = get_or_create_user_wallet(session, user_id=buyer_user_id)
    if not isinstance(payer, Wallet) or payer.status != WalletStatus.ACTIVE.value:
        return PaymentError(
            code=PaymentErrorCode.WALLET_NOT_FOUND,
            message="Payer wallet is not available.",
        )
    if payer.currency_code != order.currency_code:
        return PaymentError(
            code=PaymentErrorCode.CURRENCY_MISMATCH,
            message="Payer wallet currency does not match the order.",
        )

    payee_before = (payee.available_minor, payee.hold_minor, payee.pending_minor)
    payment_id = uuid.uuid4()
    hold_id = uuid.uuid4()
    posted = post_balanced_movement(
        session,
        currency_code=order.currency_code,
        reference=f"payment:{payment_id}",
        legs=[
            LedgerLeg(
                payer.id,
                LedgerAccountType.AVAILABLE,
                LedgerDirection.DEBIT,
                order.total_minor,
            ),
            LedgerLeg(
                payer.id,
                LedgerAccountType.HOLD,
                LedgerDirection.CREDIT,
                order.total_minor,
            ),
        ],
    )
    if isinstance(posted, WalletPostingError):
        if posted.code is WalletPostingErrorCode.INSUFFICIENT_BALANCE:
            return PaymentError(
                code=PaymentErrorCode.INSUFFICIENT_BALANCE,
                message="The wallet balance cannot cover this payment.",
            )
        if posted.code is WalletPostingErrorCode.CURRENCY_MISMATCH:
            return PaymentError(
                code=PaymentErrorCode.CURRENCY_MISMATCH,
                message=posted.message,
            )
        return PaymentError(
            code=PaymentErrorCode.WALLET_NOT_FOUND,
            message=posted.message,
        )
    session.refresh(payee)
    if (payee.available_minor, payee.hold_minor, payee.pending_minor) != payee_before:
        return PaymentError(
            code=PaymentErrorCode.VALIDATION_FAILED,
            message="Business wallet balances must stay unchanged.",
        )

    now = datetime.now(UTC)
    payment = Payment(
        id=payment_id,
        order_id=order.id,
        payer_user_id=buyer_user_id,
        payer_wallet_id=payer.id,
        payee_wallet_id=payee.id,
        amount_minor=order.total_minor,
        currency_code=order.currency_code,
        status=PaymentStatus.HELD.value,
        payment_method=payment_method.value,
        idempotency_key=idempotency_key,
    )
    hold = WalletHold(
        id=hold_id,
        wallet_id=payer.id,
        payment_id=payment_id,
        order_id=order.id,
        amount_minor=order.total_minor,
        currency_code=order.currency_code,
        status=WalletHoldStatus.ACTIVE.value,
        reason=PAYMENT_HOLD_REASON,
    )
    session.add(payment)
    session.add(hold)
    if not _claim_order_payment(session, order, now):
        return PaymentError(
            code=PaymentErrorCode.PAYMENT_ALREADY_EXISTS,
            message="This order already has a payment.",
        )
    session.add(
        PaymentIdempotencyRecord(
            buyer_user_id=buyer_user_id,
            operation=PAYMENT_OPERATION,
            idempotency_key=idempotency_key,
            request_fingerprint=fingerprint,
            payment_id=payment_id,
        )
    )
    session.flush()
    return PaymentResult(payment=payment, hold=hold, idempotent_replay=False)


def _conflict_after_integrity(
    session: Session,
    exc: IntegrityError,
    *,
    buyer_user_id: uuid.UUID,
    idempotency_key: str,
    fingerprint: str,
) -> PaymentError | PaymentResult:
    text = str(getattr(exc, "orig", exc)).lower()
    session.expire_all()
    if "payment_idempotency" in text or "uq_payment_idempotency" in text:
        existing = _find_idempotency(
            session,
            buyer_user_id=buyer_user_id,
            idempotency_key=idempotency_key,
        )
        if existing is not None:
            return _replay(session, existing, fingerprint=fingerprint)
    if "uq_payments_one_open_per_order" in text or "payments" in text:
        return PaymentError(
            code=PaymentErrorCode.PAYMENT_ALREADY_EXISTS,
            message="This order already has a payment.",
        )
    return PaymentError(
        code=PaymentErrorCode.PAYMENT_ALREADY_EXISTS,
        message="This payment could not be stored.",
    )


def _replay_if_recorded(
    session: Session,
    error: PaymentError,
    *,
    buyer_user_id: uuid.UUID,
    idempotency_key: str,
    fingerprint: str,
) -> PaymentError | PaymentResult:
    """Return the stored result when a parallel request with this key committed first.

    The first idempotency lookup runs before the order lock. A same-key request
    that waited on that lock then sees the paid order. The winner's record was
    committed with the order update, so it is visible here.
    """

    if error.code is not PaymentErrorCode.PAYMENT_ALREADY_EXISTS:
        return error
    recorded = _find_idempotency(
        session,
        buyer_user_id=buyer_user_id,
        idempotency_key=idempotency_key,
    )
    if recorded is None:
        return error
    return _replay(session, recorded, fingerprint=fingerprint)


def _queue_sqlite_writer(session: Session) -> None:
    """Take SQLite's write lock before any read.

    A deferred transaction reads first and then upgrades. Two of those upgrade
    attempts deadlock until ``database is locked``. ``BEGIN IMMEDIATE`` makes
    the second payment wait, then observe the committed balance.
    """

    if _locks_rows(session) or session.in_transaction():
        return
    session.connection().exec_driver_sql("BEGIN IMMEDIATE")


def create_payment(
    session: Session,
    *,
    buyer_user_id: uuid.UUID,
    order_id: uuid.UUID,
    payment_method: PaymentMethod,
    idempotency_key: str,
) -> PaymentResult | PaymentError:
    key = idempotency_key.strip()
    if not key or len(key) > 128:
        return PaymentError(
            code=PaymentErrorCode.VALIDATION_FAILED,
            message="Idempotency key is required.",
        )
    fingerprint = payment_request_fingerprint(order_id=order_id, payment_method=payment_method)
    _queue_sqlite_writer(session)
    existing = _find_idempotency(session, buyer_user_id=buyer_user_id, idempotency_key=key)
    if existing is not None:
        return _replay(session, existing, fingerprint=fingerprint)

    for _attempt in range(3):
        _queue_sqlite_writer(session)
        savepoint = session.begin_nested()
        try:
            outcome = _apply_payment(
                session,
                buyer_user_id=buyer_user_id,
                order_id=order_id,
                payment_method=payment_method,
                idempotency_key=key,
                fingerprint=fingerprint,
            )
            if isinstance(outcome, PaymentError):
                savepoint.rollback()
                return _replay_if_recorded(
                    session,
                    outcome,
                    buyer_user_id=buyer_user_id,
                    idempotency_key=key,
                    fingerprint=fingerprint,
                )
            savepoint.commit()
            return outcome
        except IntegrityError as exc:
            if savepoint.is_active:
                savepoint.rollback()
            conflict = _conflict_after_integrity(
                session,
                exc,
                buyer_user_id=buyer_user_id,
                idempotency_key=key,
                fingerprint=fingerprint,
            )
            if isinstance(conflict, PaymentError):
                return _replay_if_recorded(
                    session,
                    conflict,
                    buyer_user_id=buyer_user_id,
                    idempotency_key=key,
                    fingerprint=fingerprint,
                )
            return conflict
        except OperationalError:
            if savepoint.is_active:
                savepoint.rollback()
            session.rollback()
            continue
    return _replay_if_recorded(
        session,
        PaymentError(
            code=PaymentErrorCode.PAYMENT_ALREADY_EXISTS,
            message="This payment could not be stored.",
        ),
        buyer_user_id=buyer_user_id,
        idempotency_key=key,
        fingerprint=fingerprint,
    )


def get_payment(
    session: Session,
    *,
    actor_user_id: uuid.UUID,
    payment_id: uuid.UUID,
) -> Payment | PaymentError:
    payment = session.get(Payment, payment_id)
    if payment is None or not _actor_can_read(session, actor_user_id=actor_user_id, payment=payment):
        return PaymentError(
            code=PaymentErrorCode.PAYMENT_NOT_FOUND,
            message="Payment not found.",
        )
    return payment


def list_payment_holds(
    session: Session,
    *,
    actor_user_id: uuid.UUID,
    payment_id: uuid.UUID,
) -> list[WalletHold] | PaymentError:
    payment = get_payment(session, actor_user_id=actor_user_id, payment_id=payment_id)
    if isinstance(payment, PaymentError):
        return payment
    return list(session.scalars(select(WalletHold).where(WalletHold.payment_id == payment.id)))


def _actor_can_read(session: Session, *, actor_user_id: uuid.UUID, payment: Payment) -> bool:
    if payment.payer_user_id == actor_user_id:
        return True
    payee = session.get(Wallet, payment.payee_wallet_id)
    if payee is None or payee.owner_type != WalletOwnerType.BUSINESS_APPLICATION.value:
        return False
    application = session.get(BusinessOnboardingApplication, payee.owner_id)
    return application is not None and application.owner_user_id == actor_user_id

"""Consumer order lifecycle (payment and fulfilment are separate concerns)."""

from enum import StrEnum


class ConsumerOrderStatus(StrEnum):
    """Authoritative purchase record status — not payment capture."""

    PENDING_ACCEPTANCE = "pending_acceptance"
    ACCEPTED = "accepted"
    REJECTED = "rejected"
    CANCELLED = "cancelled"
    EXPIRED = "expired"


class ConsumerOrderPaymentStatus(StrEnum):
    UNPAID = "unpaid"
    PAYMENT_PENDING = "payment_pending"
    PAID = "paid"


class ConsumerOrderFulfillmentStatus(StrEnum):
    NOT_STARTED = "not_started"
    IN_PROGRESS = "in_progress"
    FULFILLED = "fulfilled"

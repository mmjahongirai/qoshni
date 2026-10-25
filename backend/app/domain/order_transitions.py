"""Validated consumer order status transitions."""

from app.domain.order_lifecycle import ConsumerOrderStatus

_ALLOWED: dict[ConsumerOrderStatus, set[ConsumerOrderStatus]] = {
    ConsumerOrderStatus.PENDING_ACCEPTANCE: {
        ConsumerOrderStatus.ACCEPTED,
        ConsumerOrderStatus.REJECTED,
        ConsumerOrderStatus.CANCELLED,
        ConsumerOrderStatus.EXPIRED,
    },
    ConsumerOrderStatus.ACCEPTED: set(),
    ConsumerOrderStatus.REJECTED: set(),
    ConsumerOrderStatus.CANCELLED: set(),
    ConsumerOrderStatus.EXPIRED: set(),
}


def can_transition(
    current: ConsumerOrderStatus,
    target: ConsumerOrderStatus,
) -> bool:
    return target in _ALLOWED.get(current, set())

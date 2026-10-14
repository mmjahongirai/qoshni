"""OTP delivery provider contract (SMS gateway integration is out of scope)."""

from __future__ import annotations

from dataclasses import dataclass
from typing import Protocol, runtime_checkable


@dataclass(frozen=True, slots=True)
class OtpDeliveryResult:
    """Provider accepted the delivery request (not proof the SMS was delivered)."""

    accepted: bool
    provider_reference: str | None = None


@runtime_checkable
class OtpDeliveryProvider(Protocol):
    async def send_otp(
        self,
        *,
        phone_e164: str,
        purpose: str,
        code_length: int,
        code: str,
    ) -> OtpDeliveryResult:
        """Request delivery of ``code`` to ``phone_e164``.

        Implementations must never log or persist ``code``. The ``code`` argument
        exists so real providers can transmit it; tests may capture it in memory.
        """


class UnconfiguredOtpDeliveryProvider:
    """Default runtime provider when no SMS gateway is configured."""

    async def send_otp(
        self,
        *,
        phone_e164: str,
        purpose: str,
        code_length: int,
        code: str,
    ) -> OtpDeliveryResult:
        _ = (phone_e164, purpose, code_length, code)
        return OtpDeliveryResult(accepted=False)

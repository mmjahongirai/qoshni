"""Test-only OTP provider. Never import from application runtime code."""

from __future__ import annotations

from dataclasses import dataclass, field

from app.services.auth.otp_provider import OtpDeliveryResult


@dataclass
class FakeOtpProvider:
    """Captures the last OTP in memory for deterministic verification tests."""

    accept_delivery: bool = True
    last_code: str | None = field(default=None, init=False)
    delivery_calls: int = field(default=0, init=False)

    async def send_otp(
        self,
        *,
        phone_e164: str,
        purpose: str,
        code_length: int,
        code: str,
    ) -> OtpDeliveryResult:
        _ = (phone_e164, purpose, code_length)
        self.delivery_calls += 1
        if not self.accept_delivery:
            return OtpDeliveryResult(accepted=False)
        self.last_code = code
        return OtpDeliveryResult(accepted=True, provider_reference="test")

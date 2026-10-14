"""Authentication-related FastAPI dependencies."""

from app.services.auth.otp_provider import OtpDeliveryProvider, UnconfiguredOtpDeliveryProvider

_default_provider = UnconfiguredOtpDeliveryProvider()


def get_otp_delivery_provider() -> OtpDeliveryProvider:
    """Return the runtime OTP delivery provider (SMS gateway when configured)."""

    return _default_provider

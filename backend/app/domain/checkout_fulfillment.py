"""Checkout fulfillment request values."""

from enum import StrEnum


class CheckoutFulfillmentType(StrEnum):
    PICKUP = "pickup"
    DELIVERY = "delivery"
    SERVICE_AT_LOCATION = "service_at_location"

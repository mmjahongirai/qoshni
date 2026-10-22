enum BusinessDeliveryExceptionStatus {
  open,
  resolved,
  dismissed,
}

bool businessDeliveryExceptionStatusTerminal(
  BusinessDeliveryExceptionStatus status,
) {
  return status == BusinessDeliveryExceptionStatus.resolved ||
      status == BusinessDeliveryExceptionStatus.dismissed;
}

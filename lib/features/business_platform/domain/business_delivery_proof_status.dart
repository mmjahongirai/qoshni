enum BusinessDeliveryProofStatus {
  pending,
  verified,
  rejected,
  superseded,
}

bool businessDeliveryProofStatusTerminal(BusinessDeliveryProofStatus status) {
  return status == BusinessDeliveryProofStatus.verified ||
      status == BusinessDeliveryProofStatus.rejected ||
      status == BusinessDeliveryProofStatus.superseded;
}

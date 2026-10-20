enum BusinessDeliveryTaskStatus {
  created,
  readyForPickup,
  assigned,
  pickedUp,
  inTransit,
  delivered,
  failed,
  cancelled,
}

bool businessDeliveryTaskStatusTerminal(BusinessDeliveryTaskStatus status) {
  return status == BusinessDeliveryTaskStatus.delivered ||
      status == BusinessDeliveryTaskStatus.cancelled;
}

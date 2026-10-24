enum QoshniNotificationDispatchOutcome {
  deliveredToInbox,
  simulatedChannelDelivered,
  suppressedByPolicy,
  duplicateIdempotencyReference,
  validationFailed,
  simulatedChannelFailure,
  inboxPersistFailure,
  coordinatorFailure,
}

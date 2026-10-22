enum BusinessFulfillmentHistoryAction {
  created,
  draftUpdated,
  activated,
  archived,
}

class BusinessFulfillmentHistoryEvent {
  const BusinessFulfillmentHistoryEvent({
    required this.eventId,
    required this.configurationId,
    required this.action,
    this.previousRevision,
    this.newRevision,
    required this.recordedAt,
    this.reason,
  });

  final String eventId;
  final String configurationId;
  final BusinessFulfillmentHistoryAction action;
  final int? previousRevision;
  final int? newRevision;
  final DateTime recordedAt;
  final String? reason;
}

enum BusinessCatalogPriceHistoryAction {
  created,
  draftUpdated,
  activated,
  archived,
  revisionCreated,
}

class BusinessCatalogPriceHistoryEvent {
  const BusinessCatalogPriceHistoryEvent({
    required this.eventId,
    required this.priceId,
    required this.action,
    this.previousAmountSom,
    this.newAmountSom,
    this.previousRevision,
    this.newRevision,
    required this.recordedAt,
    this.reason,
  });

  final String eventId;
  final String priceId;
  final BusinessCatalogPriceHistoryAction action;
  final int? previousAmountSom;
  final int? newAmountSom;
  final int? previousRevision;
  final int? newRevision;
  final DateTime recordedAt;
  final String? reason;
}

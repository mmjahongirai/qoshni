enum BusinessCatalogPromoCodeHistoryAction {
  created,
  draftUpdated,
  activated,
  archived,
  revisionCreated,
}

class BusinessCatalogPromoCodeHistoryEvent {
  const BusinessCatalogPromoCodeHistoryEvent({
    required this.eventId,
    required this.promoCodeId,
    required this.action,
    this.previousRevision,
    this.newRevision,
    required this.recordedAt,
    this.reason,
  });

  final String eventId;
  final String promoCodeId;
  final BusinessCatalogPromoCodeHistoryAction action;
  final int? previousRevision;
  final int? newRevision;
  final DateTime recordedAt;
  final String? reason;
}

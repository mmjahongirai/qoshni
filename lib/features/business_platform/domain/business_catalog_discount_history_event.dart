enum BusinessCatalogDiscountHistoryAction {
  created,
  draftUpdated,
  activated,
  archived,
  revisionCreated,
}

class BusinessCatalogDiscountHistoryEvent {
  const BusinessCatalogDiscountHistoryEvent({
    required this.eventId,
    required this.discountRuleId,
    required this.action,
    this.previousRevision,
    this.newRevision,
    this.previousPercentBasisPoints,
    this.newPercentBasisPoints,
    this.previousFixedAmountSom,
    this.newFixedAmountSom,
    required this.recordedAt,
    this.reason,
  });

  final String eventId;
  final String discountRuleId;
  final BusinessCatalogDiscountHistoryAction action;
  final int? previousRevision;
  final int? newRevision;
  final int? previousPercentBasisPoints;
  final int? newPercentBasisPoints;
  final int? previousFixedAmountSom;
  final int? newFixedAmountSom;
  final DateTime recordedAt;
  final String? reason;
}

class BusinessCatalogResourceCapacityEvent {
  const BusinessCatalogResourceCapacityEvent({
    required this.eventId,
    required this.resourceId,
    required this.totalBefore,
    required this.totalAfter,
    required this.reason,
    required this.recordedAt,
  });

  final String eventId;
  final String resourceId;
  final int totalBefore;
  final int totalAfter;
  final String reason;
  final DateTime recordedAt;
}

enum BusinessCatalogInventoryAdjustmentKind {
  onHandDelta,
  reservedDelta,
}

class BusinessCatalogInventoryAdjustmentEvent {
  const BusinessCatalogInventoryAdjustmentEvent({
    required this.eventId,
    required this.inventoryItemId,
    required this.kind,
    required this.delta,
    required this.onHandBefore,
    required this.onHandAfter,
    required this.reservedBefore,
    required this.reservedAfter,
    required this.reason,
    required this.recordedAt,
  });

  final String eventId;
  final String inventoryItemId;
  final BusinessCatalogInventoryAdjustmentKind kind;
  final int delta;
  final int onHandBefore;
  final int onHandAfter;
  final int reservedBefore;
  final int reservedAfter;
  final String reason;
  final DateTime recordedAt;
}

class BusinessCatalogInventoryAdjustmentInput {
  const BusinessCatalogInventoryAdjustmentInput({
    required this.kind,
    required this.delta,
    required this.reason,
  });

  final BusinessCatalogInventoryAdjustmentKind kind;
  final int delta;
  final String reason;
}

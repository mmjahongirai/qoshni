class BusinessCatalogInventoryReservationReconciliationLine {
  const BusinessCatalogInventoryReservationReconciliationLine({
    required this.inventoryItemId,
    required this.expectedReservedQuantity,
    required this.actualReservedQuantity,
  });

  final String inventoryItemId;
  final int expectedReservedQuantity;
  final int actualReservedQuantity;

  int get delta => actualReservedQuantity - expectedReservedQuantity;
}

class BusinessCatalogInventoryReservationReconciliationReport {
  const BusinessCatalogInventoryReservationReconciliationReport({
    required this.checkedAt,
    required this.discrepancies,
    required this.isDemoAuditOnly,
  });

  final DateTime checkedAt;
  final List<BusinessCatalogInventoryReservationReconciliationLine> discrepancies;
  final bool isDemoAuditOnly;

  bool get hasDiscrepancies => discrepancies.isNotEmpty;
}

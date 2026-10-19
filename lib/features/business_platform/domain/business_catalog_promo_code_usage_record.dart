enum BusinessCatalogPromoCodeUsageStatus {
  previewRecorded,
  demoRedemption,
}

class BusinessCatalogPromoCodeUsageRecord {
  const BusinessCatalogPromoCodeUsageRecord({
    required this.usageRecordId,
    required this.promoCodeId,
    required this.demoCustomerReference,
    required this.demoRedemptionReference,
    required this.status,
    required this.recordedAt,
  });

  final String usageRecordId;
  final String promoCodeId;
  final String demoCustomerReference;
  final String demoRedemptionReference;
  final BusinessCatalogPromoCodeUsageStatus status;
  final DateTime recordedAt;
}

import 'package:qoshni/features/business_platform/domain/business_catalog_price_status.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_promo_code.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_promo_code_history_event.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_promo_code_usage_record.dart';

class CatalogPromoUsageSnapshot {
  const CatalogPromoUsageSnapshot({
    required this.totalUses,
    required this.usesForCustomer,
  });

  final int totalUses;
  final int usesForCustomer;
}

enum BusinessCatalogPromoCodeSaveResult {
  success,
  notFound,
  invalidCode,
  duplicateCode,
  invalidEffectiveRange,
  invalidBranch,
  invalidDiscountLink,
  discountLinkInactive,
  discountIntervalMismatch,
  activeImmutable,
  notDraft,
  failure,
}

enum BusinessCatalogPromoCodeStatusChangeResult {
  success,
  notFound,
  notDraft,
  invalidEffectiveRange,
  invalidDiscountLink,
  discountLinkInactive,
  discountIntervalMismatch,
  failure,
}

abstract class BusinessCatalogPromoCodeRepository {
  String get businessScopeId;

  List<BusinessCatalogPromoCode> listForCurrentScope({
    String? branchId,
    BusinessCatalogPriceStatus? status,
    bool includeArchived = false,
  });

  BusinessCatalogPromoCode? findById(String promoCodeId);

  BusinessCatalogPromoCode? findByNormalizedCode(String normalizedCode);

  BusinessCatalogPromoCodeSaveResult createDraft(
    BusinessCatalogPromoCodeInput input,
  );

  BusinessCatalogPromoCodeSaveResult updateDraft({
    required String promoCodeId,
    required BusinessCatalogPromoCodeInput input,
  });

  BusinessCatalogPromoCodeSaveResult createRevisionFromPromo({
    required String sourcePromoCodeId,
    required BusinessCatalogPromoCodeInput input,
  });

  BusinessCatalogPromoCodeStatusChangeResult activatePromoCode(
    String promoCodeId,
  );

  BusinessCatalogPromoCodeStatusChangeResult archivePromoCode(
    String promoCodeId,
  );

  List<BusinessCatalogPromoCodeHistoryEvent> promoHistory(String promoCodeId);

  List<BusinessCatalogPromoCodeUsageRecord> usageRecords(String promoCodeId);

  CatalogPromoUsageSnapshot usageSnapshot({
    required String promoCodeId,
    String? demoCustomerReference,
  });
}

import 'package:qoshni/features/business_platform/domain/business_catalog_listing_kind.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_price.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_price_history_event.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_price_status.dart';

enum BusinessCatalogPricingSaveResult {
  success,
  notFound,
  invalidAmount,
  invalidCurrency,
  invalidEffectiveRange,
  invalidListing,
  invalidBranch,
  invalidVariant,
  activeImmutable,
  activeIntervalOverlap,
  notDraft,
  failure,
}

enum BusinessCatalogPricingStatusChangeResult {
  success,
  notFound,
  notDraft,
  invalidEffectiveRange,
  activeIntervalOverlap,
  failure,
}

abstract class BusinessCatalogPricingRepository {
  String get businessScopeId;

  List<BusinessCatalogPrice> listForCurrentScope({
    String? branchId,
    BusinessCatalogListingKind? listingKind,
    BusinessCatalogPriceStatus? status,
    bool includeArchived = false,
  });

  BusinessCatalogPrice? findById(String priceId);

  List<BusinessCatalogPrice> findForListingTarget({
    required String branchId,
    required BusinessCatalogListingKind listingKind,
    required String listingId,
    String? variantId,
  });

  BusinessCatalogPricingSaveResult createDraft(BusinessCatalogPriceInput input);

  BusinessCatalogPricingSaveResult updateDraft({
    required String priceId,
    required BusinessCatalogPriceInput input,
  });

  BusinessCatalogPricingSaveResult createRevisionFromPrice({
    required String sourcePriceId,
    required BusinessCatalogPriceInput input,
  });

  BusinessCatalogPricingStatusChangeResult activatePrice(String priceId);

  BusinessCatalogPricingStatusChangeResult archivePrice(String priceId);

  List<BusinessCatalogPriceHistoryEvent> priceHistory(String priceId);

  List<BusinessCatalogPrice> activePricesOverlappingTarget({
    required String branchId,
    required BusinessCatalogListingKind listingKind,
    required String listingId,
    String? variantId,
    required DateTime effectiveFrom,
    DateTime? effectiveUntil,
    String? excludePriceId,
  });
}

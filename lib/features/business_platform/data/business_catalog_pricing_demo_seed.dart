import 'package:qoshni/features/business_platform/data/business_catalog_inventory_demo_seed.dart';
import 'package:qoshni/features/business_platform/data/business_catalog_product_demo_seed.dart';
import 'package:qoshni/features/business_platform/data/business_catalog_product_variant_demo_seed.dart';
import 'package:qoshni/features/business_platform/data/business_catalog_service_demo_seed.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_listing_kind.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_price.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_price_status.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_product.dart';

const String kDemoCatalogPriceBreadBaseTashkentId =
    'demo-catalog-price-bread-base-tashkent';
const String kDemoCatalogPriceBreadVariantTashkentId =
    'demo-catalog-price-bread-variant-tashkent';
const String kDemoCatalogPricePackingServiceId =
    'demo-catalog-price-packing-service';
const String kDemoCatalogPricePlovDraftId = 'demo-catalog-price-plov-draft';
const String kDemoCatalogPriceBreadSamarkandSeasonalId =
    'demo-catalog-price-bread-samarkand-seasonal';

/// Fixed UTC anchors for deterministic resolver and UI preview tests.
final DateTime kDemoCatalogPricingEpoch =
    DateTime.utc(2025, 1, 1, 0, 0, 0);
final DateTime kDemoCatalogPricingSeasonalFrom =
    DateTime.utc(2025, 6, 1, 0, 0, 0);
final DateTime kDemoCatalogPricingSeasonalUntil =
    DateTime.utc(2025, 12, 1, 0, 0, 0);

List<BusinessCatalogPrice> buildDemoCatalogPrices({
  required String businessScopeId,
}) {
  return [
    BusinessCatalogPrice(
      priceId: kDemoCatalogPriceBreadBaseTashkentId,
      businessScopeId: businessScopeId,
      branchId: kDemoBranchTashkentCenterId,
      listingKind: BusinessCatalogListingKind.product,
      listingId: kDemoCatalogProductBreadId,
      amountSom: 8000,
      currencyCode: kBusinessCatalogPriceCurrencyUzs,
      status: BusinessCatalogPriceStatus.active,
      effectiveFrom: kDemoCatalogPricingEpoch,
      revision: 1,
      dataSource: BusinessCatalogProductDataSource.demoSeed,
      createdAt: kDemoCatalogPricingEpoch,
      updatedAt: kDemoCatalogPricingEpoch,
    ),
    BusinessCatalogPrice(
      priceId: kDemoCatalogPriceBreadVariantTashkentId,
      businessScopeId: businessScopeId,
      branchId: kDemoBranchTashkentCenterId,
      listingKind: BusinessCatalogListingKind.product,
      listingId: kDemoCatalogProductBreadId,
      variantId: kDemoCatalogVariantBreadStandardId,
      amountSom: 8500,
      currencyCode: kBusinessCatalogPriceCurrencyUzs,
      status: BusinessCatalogPriceStatus.active,
      effectiveFrom: kDemoCatalogPricingEpoch,
      revision: 1,
      dataSource: BusinessCatalogProductDataSource.demoSeed,
      createdAt: kDemoCatalogPricingEpoch,
      updatedAt: kDemoCatalogPricingEpoch,
    ),
    BusinessCatalogPrice(
      priceId: kDemoCatalogPricePackingServiceId,
      businessScopeId: businessScopeId,
      branchId: kDemoBranchTashkentCenterId,
      listingKind: BusinessCatalogListingKind.service,
      listingId: kDemoCatalogServicePackingId,
      amountSom: 50000,
      currencyCode: kBusinessCatalogPriceCurrencyUzs,
      status: BusinessCatalogPriceStatus.active,
      effectiveFrom: kDemoCatalogPricingEpoch,
      revision: 1,
      dataSource: BusinessCatalogProductDataSource.demoSeed,
      createdAt: kDemoCatalogPricingEpoch,
      updatedAt: kDemoCatalogPricingEpoch,
    ),
    BusinessCatalogPrice(
      priceId: kDemoCatalogPricePlovDraftId,
      businessScopeId: businessScopeId,
      branchId: kDemoBranchTashkentCenterId,
      listingKind: BusinessCatalogListingKind.product,
      listingId: kDemoCatalogProductPlovId,
      amountSom: 25000,
      currencyCode: kBusinessCatalogPriceCurrencyUzs,
      status: BusinessCatalogPriceStatus.draft,
      effectiveFrom: kDemoCatalogPricingEpoch,
      revision: 1,
      dataSource: BusinessCatalogProductDataSource.demoSeed,
      createdAt: kDemoCatalogPricingEpoch,
      updatedAt: kDemoCatalogPricingEpoch,
    ),
    BusinessCatalogPrice(
      priceId: kDemoCatalogPriceBreadSamarkandSeasonalId,
      businessScopeId: businessScopeId,
      branchId: kDemoBranchSamarkandId,
      listingKind: BusinessCatalogListingKind.product,
      listingId: kDemoCatalogProductBreadId,
      amountSom: 7500,
      currencyCode: kBusinessCatalogPriceCurrencyUzs,
      status: BusinessCatalogPriceStatus.active,
      effectiveFrom: kDemoCatalogPricingSeasonalFrom,
      effectiveUntil: kDemoCatalogPricingSeasonalUntil,
      revision: 1,
      dataSource: BusinessCatalogProductDataSource.demoSeed,
      createdAt: kDemoCatalogPricingSeasonalFrom,
      updatedAt: kDemoCatalogPricingSeasonalFrom,
    ),
  ];
}

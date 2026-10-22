import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/features/business_platform/data/business_catalog_inventory_demo_seed.dart';
import 'package:qoshni/features/business_platform/data/business_catalog_pricing_demo_seed.dart';
import 'package:qoshni/features/business_platform/data/business_catalog_product_demo_seed.dart';
import 'package:qoshni/features/business_platform/data/business_catalog_product_variant_demo_seed.dart';
import 'package:qoshni/features/business_platform/data/business_catalog_service_demo_seed.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_listing_kind.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_price.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_pricing_resolver.dart';

void main() {
  const scope = 'session-owner-profile-demo';
  late List<BusinessCatalogPrice> prices;

  setUp(() {
    prices = buildDemoCatalogPrices(businessScopeId: scope);
  });

  test('variant-specific price beats base listing price', () {
    final result = resolveCatalogPrice(
      prices: prices,
      listingKind: BusinessCatalogListingKind.product,
      listingId: kDemoCatalogProductBreadId,
      branchId: kDemoBranchTashkentCenterId,
      variantId: kDemoCatalogVariantBreadStandardId,
      asOf: kDemoCatalogPricingEpoch,
    );
    expect(result.status, CatalogPriceResolutionStatus.found);
    expect(result.price!.amountSom, 8500);
  });

  test('falls back to base listing when variant price missing', () {
    final result = resolveCatalogPrice(
      prices: prices,
      listingKind: BusinessCatalogListingKind.product,
      listingId: kDemoCatalogProductBreadId,
      branchId: kDemoBranchSamarkandId,
      variantId: kDemoCatalogVariantBreadStandardId,
      asOf: kDemoCatalogPricingSeasonalFrom.add(const Duration(days: 1)),
    );
    expect(result.status, CatalogPriceResolutionStatus.found);
    expect(result.price!.amountSom, 7500);
  });

  test('seasonal window boundaries', () {
    final before = resolveCatalogPrice(
      prices: prices,
      listingKind: BusinessCatalogListingKind.product,
      listingId: kDemoCatalogProductBreadId,
      branchId: kDemoBranchSamarkandId,
      asOf: kDemoCatalogPricingSeasonalFrom.subtract(const Duration(days: 1)),
    );
    expect(before.status, CatalogPriceResolutionStatus.notFound);

    final atEnd = resolveCatalogPrice(
      prices: prices,
      listingKind: BusinessCatalogListingKind.product,
      listingId: kDemoCatalogProductBreadId,
      branchId: kDemoBranchSamarkandId,
      asOf: kDemoCatalogPricingSeasonalUntil,
    );
    expect(atEnd.status, CatalogPriceResolutionStatus.notFound);
  });

  test('draft prices are ignored', () {
    final result = resolveCatalogPrice(
      prices: prices,
      listingKind: BusinessCatalogListingKind.product,
      listingId: kDemoCatalogProductPlovId,
      branchId: kDemoBranchTashkentCenterId,
      asOf: kDemoCatalogPricingEpoch,
    );
    expect(result.status, CatalogPriceResolutionStatus.notFound);
  });

  test('ambiguous when multiple active base prices overlap', () {
    final base = prices.firstWhere(
      (p) => p.priceId == kDemoCatalogPriceBreadBaseTashkentId,
    );
    final duplicate = BusinessCatalogPrice(
      priceId: 'demo-duplicate-base',
      businessScopeId: base.businessScopeId,
      branchId: base.branchId,
      listingKind: base.listingKind,
      listingId: base.listingId,
      variantId: base.variantId,
      amountSom: base.amountSom,
      currencyCode: base.currencyCode,
      status: base.status,
      effectiveFrom: base.effectiveFrom,
      effectiveUntil: base.effectiveUntil,
      revision: base.revision,
      dataSource: base.dataSource,
      createdAt: base.createdAt,
      updatedAt: base.updatedAt,
    );
    final list = [...prices, duplicate];
    final result = resolveCatalogPrice(
      prices: list,
      listingKind: BusinessCatalogListingKind.product,
      listingId: kDemoCatalogProductBreadId,
      branchId: kDemoBranchTashkentCenterId,
      asOf: kDemoCatalogPricingEpoch,
    );
    expect(result.status, CatalogPriceResolutionStatus.ambiguous);
    expect(result.candidatePriceIds, hasLength(2));
  });

  test('deterministic resolution for stable inputs', () {
    final a = resolveCatalogPrice(
      prices: prices,
      listingKind: BusinessCatalogListingKind.service,
      listingId: kDemoCatalogServicePackingId,
      branchId: kDemoBranchTashkentCenterId,
      asOf: kDemoCatalogPricingEpoch,
    );
    final b = resolveCatalogPrice(
      prices: prices,
      listingKind: BusinessCatalogListingKind.service,
      listingId: kDemoCatalogServicePackingId,
      branchId: kDemoBranchTashkentCenterId,
      asOf: kDemoCatalogPricingEpoch,
    );
    expect(a.price!.priceId, b.price!.priceId);
    expect(a.price!.amountSom, 50000);
  });
}

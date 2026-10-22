import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/features/business_platform/data/business_catalog_discount_demo_seed.dart';
import 'package:qoshni/features/business_platform/data/business_catalog_inventory_demo_seed.dart';
import 'package:qoshni/features/business_platform/data/business_catalog_pricing_demo_seed.dart';
import 'package:qoshni/features/business_platform/data/business_catalog_product_demo_seed.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_discount_rule.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_discount_target_scope.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_discount_type.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_listing_kind.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_price_status.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_product.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_discount_resolver.dart';

void main() {
  const scope = 'session-owner-profile-demo';
  late List<BusinessCatalogDiscountRule> rules;

  setUp(() {
    rules = buildDemoCatalogDiscountRules(businessScopeId: scope);
  });

  test('applies bread percent discount at epoch', () {
    final result = resolveCatalogDiscount(
      rules: rules,
      listingKind: BusinessCatalogListingKind.product,
      listingId: kDemoCatalogProductBreadId,
      branchId: kDemoBranchTashkentCenterId,
      basePriceAmountSom: 8000,
      asOf: kDemoCatalogPricingEpoch,
    );
    expect(result.status, CatalogDiscountResolutionStatus.applied);
    expect(result.appliedRuleId, kDemoCatalogDiscountBreadPercentId);
    expect(result.discountAmountSom, 800);
    expect(result.finalAmountSom, 7200);
  });

  test('min basket requires subtotal', () {
    final without = resolveCatalogDiscount(
      rules: rules,
      listingKind: BusinessCatalogListingKind.product,
      listingId: kDemoCatalogProductBreadId,
      branchId: kDemoBranchTashkentCenterId,
      basePriceAmountSom: 8000,
      asOf: kDemoCatalogPricingEpoch,
    );
    expect(without.appliedRuleId, kDemoCatalogDiscountBreadPercentId);

    final withWide = resolveCatalogDiscount(
      rules: rules,
      listingKind: BusinessCatalogListingKind.product,
      listingId: kDemoCatalogProductBreadId,
      branchId: kDemoBranchTashkentCenterId,
      basePriceAmountSom: 8000,
      qualifyingSubtotalAmountSom: 100000,
      asOf: kDemoCatalogPricingEpoch,
    );
    expect(withWide.appliedRuleId, kDemoCatalogDiscountMinBasketWideId);
    expect(withWide.discountAmountSom, 400);
  });

  test('draft and expired rules ignored', () {
    final draftOnly = rules
        .where((r) => r.discountRuleId == kDemoCatalogDiscountPlovDraftId)
        .toList();
    expect(
      resolveCatalogDiscount(
        rules: draftOnly,
        listingKind: BusinessCatalogListingKind.product,
        listingId: kDemoCatalogProductPlovId,
        branchId: kDemoBranchTashkentCenterId,
        basePriceAmountSom: 25000,
        asOf: kDemoCatalogPricingEpoch,
      ).status,
      CatalogDiscountResolutionStatus.notApplied,
    );

    final expired = resolveCatalogDiscount(
      rules: rules,
      listingKind: BusinessCatalogListingKind.product,
      listingId: kDemoCatalogProductBreadId,
      branchId: kDemoBranchTashkentCenterId,
      basePriceAmountSom: 8000,
      asOf: kDemoCatalogPricingEpoch,
    );
    expect(expired.appliedRuleId, isNot(kDemoCatalogDiscountBreadExpiredId));
  });

  test('priority tie yields ambiguous', () {
    final tie = BusinessCatalogDiscountRule(
      discountRuleId: 'demo-tie',
      businessScopeId: scope,
      branchId: kDemoBranchTashkentCenterId,
      targetScope: BusinessCatalogDiscountTargetScope.product,
      listingId: kDemoCatalogProductBreadId,
      discountType: BusinessCatalogDiscountType.fixedAmount,
      fixedAmountSom: 500,
      status: BusinessCatalogPriceStatus.active,
      effectiveFrom: kDemoCatalogPricingEpoch,
      priority: 100,
      revision: 1,
      dataSource: BusinessCatalogProductDataSource.demoSeed,
      createdAt: kDemoCatalogPricingEpoch,
      updatedAt: kDemoCatalogPricingEpoch,
    );
    final result = resolveCatalogDiscount(
      rules: [...rules, tie],
      listingKind: BusinessCatalogListingKind.product,
      listingId: kDemoCatalogProductBreadId,
      branchId: kDemoBranchTashkentCenterId,
      basePriceAmountSom: 8000,
      asOf: kDemoCatalogPricingEpoch,
    );
    expect(result.status, CatalogDiscountResolutionStatus.ambiguous);
    expect(result.candidateRuleIds, hasLength(2));
  });
}

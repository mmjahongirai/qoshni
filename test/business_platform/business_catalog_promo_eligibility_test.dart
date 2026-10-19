import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/features/business_platform/data/business_catalog_discount_demo_seed.dart';
import 'package:qoshni/features/business_platform/data/business_catalog_inventory_demo_seed.dart';
import 'package:qoshni/features/business_platform/data/business_catalog_pricing_demo_seed.dart';
import 'package:qoshni/features/business_platform/data/business_catalog_product_demo_seed.dart';
import 'package:qoshni/features/business_platform/data/business_catalog_promo_code_demo_seed.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_discount_rule.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_listing_kind.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_promo_code.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_catalog_promo_code_repository.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_promo_eligibility.dart';

void main() {
  const scope = 'demo-business-scope';
  late List<BusinessCatalogPromoCode> promos;
  late List<BusinessCatalogDiscountRule> discounts;

  setUp(() {
    promos = buildDemoCatalogPromoCodes(businessScopeId: scope);
    discounts = buildDemoCatalogDiscountRules(businessScopeId: scope);
  });

  BusinessCatalogPromoCode? promoForCode(String code) {
    final normalized = code.trim().toUpperCase();
    for (final p in promos) {
      if (p.normalizedCode == normalized) {
        return p;
      }
    }
    return null;
  }

  BusinessCatalogDiscountRule? discountForPromo(BusinessCatalogPromoCode promo) {
    for (final d in discounts) {
      if (d.discountRuleId == promo.discountRuleId) {
        return d;
      }
    }
    return null;
  }

  CatalogPromoCodeEligibilityResult evaluate({
    required String code,
    String branchId = kDemoBranchTashkentCenterId,
    DateTime? asOf,
    int? base,
    int? subtotal,
    String? customerRef,
    BusinessCatalogPromoCode? promoOverride,
    BusinessCatalogDiscountRule? discountOverride,
    CatalogPromoUsageSnapshot? snapshot,
  }) {
    final promo = promoOverride ?? promoForCode(code);
    final linked = discountOverride ??
        (promo == null ? null : discountForPromo(promo));
    return evaluateCatalogPromoCodeEligibility(
      enteredCode: code,
      businessScopeId: scope,
      branchId: branchId,
      listingKind: BusinessCatalogListingKind.product,
      listingId: kDemoCatalogProductBreadId,
      asOf: asOf ?? kDemoCatalogPricingEpoch,
      basePriceAmountSom: base,
      qualifyingSubtotalAmountSom: subtotal,
      demoCustomerReference: customerRef,
      promo: promo,
      linkedDiscount: linked,
      usageSnapshot: snapshot,
    );
  }

  test('NON10 eligible with linked bread discount', () {
    final result = evaluate(code: 'NON10', base: 8000);
    expect(result.status, CatalogPromoCodeEligibilityStatus.eligible);
    expect(result.discountRuleId, kDemoCatalogDiscountBreadPercentId);
    expect(result.discountAmountSom, 800);
  });

  test('invalid and inactive promos rejected', () {
    expect(
      evaluate(code: 'UNKNOWN', base: 8000).status,
      CatalogPromoCodeEligibilityStatus.invalidCode,
    );
    expect(
      evaluate(code: 'DRAFT1', base: 8000).status,
      CatalogPromoCodeEligibilityStatus.inactive,
    );
    expect(
      evaluate(code: 'RETIRED', base: 8000).status,
      CatalogPromoCodeEligibilityStatus.inactive,
    );
  });

  test('effective interval boundaries', () {
    expect(
      evaluate(code: 'LATER', base: 8000).status,
      CatalogPromoCodeEligibilityStatus.notYetValid,
    );
    expect(
      evaluate(code: 'OLD', base: 8000).status,
      CatalogPromoCodeEligibilityStatus.expired,
    );
  });

  test('minimum basket promo and linked discount', () {
    expect(
      evaluate(code: 'WIDE5', base: 8000).status,
      CatalogPromoCodeEligibilityStatus.minimumBasketNotMet,
    );
    expect(
      evaluate(code: 'WIDE5', base: 8000, subtotal: 120000).status,
      CatalogPromoCodeEligibilityStatus.eligible,
    );
  });

  test('usage limits', () {
    expect(
      evaluate(
        code: 'MAXED',
        base: 8000,
        snapshot: const CatalogPromoUsageSnapshot(totalUses: 2, usesForCustomer: 0),
      ).status,
      CatalogPromoCodeEligibilityStatus.totalUsageLimitReached,
    );
    expect(
      evaluate(
        code: 'ALICE1',
        base: 8000,
        customerRef: kDemoPromoCustomerAlice,
        snapshot: const CatalogPromoUsageSnapshot(totalUses: 1, usesForCustomer: 1),
      ).status,
      CatalogPromoCodeEligibilityStatus.customerUsageLimitReached,
    );
    expect(
      evaluate(
        code: 'ALICE1',
        base: 8000,
        snapshot: const CatalogPromoUsageSnapshot(totalUses: 1, usesForCustomer: 1),
      ).status,
      CatalogPromoCodeEligibilityStatus.eligible,
    );
  });

  test('base price required', () {
    expect(
      evaluate(code: 'NON10').status,
      CatalogPromoCodeEligibilityStatus.basePriceRequired,
    );
  });

  test('inactive linked discount', () {
    final promo = promos.firstWhere((p) => p.promoCodeId == kDemoCatalogPromoNon10Id);
    final draftDiscount =
        discounts.firstWhere((d) => d.discountRuleId == kDemoCatalogDiscountPlovDraftId);
    expect(
      evaluate(
        code: 'NON10',
        base: 8000,
        promoOverride: promo,
        discountOverride: draftDiscount,
      ).status,
      CatalogPromoCodeEligibilityStatus.discountRuleUnavailable,
    );
  });
}

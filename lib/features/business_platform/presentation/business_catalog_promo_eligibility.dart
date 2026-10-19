import 'package:qoshni/features/business_platform/domain/business_catalog_discount_rule.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_listing_kind.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_price_status.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_promo_code.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_catalog_promo_code_repository.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_discount_resolver.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_discount_validation.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_promo_code_validation.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_pricing_validation.dart';

enum CatalogPromoCodeEligibilityStatus {
  eligible,
  invalidCode,
  inactive,
  notYetValid,
  expired,
  scopeMismatch,
  discountRuleUnavailable,
  minimumBasketNotMet,
  totalUsageLimitReached,
  customerUsageLimitReached,
  noApplicableDiscount,
  basePriceRequired,
}

class CatalogPromoCodeEligibilityResult {
  const CatalogPromoCodeEligibilityResult._({
    required this.status,
    this.promoCodeId,
    this.discountRuleId,
    this.baseAmountSom,
    this.discountAmountSom,
    this.finalAmountSom,
  });

  const CatalogPromoCodeEligibilityResult.ineligible(
    CatalogPromoCodeEligibilityStatus status,
  ) : this._(status: status);

  const CatalogPromoCodeEligibilityResult.eligible({
    required String promoCodeId,
    required String discountRuleId,
    required int baseAmountSom,
    required int discountAmountSom,
  }) : this._(
          status: CatalogPromoCodeEligibilityStatus.eligible,
          promoCodeId: promoCodeId,
          discountRuleId: discountRuleId,
          baseAmountSom: baseAmountSom,
          discountAmountSom: discountAmountSom,
          finalAmountSom: baseAmountSom - discountAmountSom,
        );

  final CatalogPromoCodeEligibilityStatus status;
  final String? promoCodeId;
  final String? discountRuleId;
  final int? baseAmountSom;
  final int? discountAmountSom;
  final int? finalAmountSom;
}

CatalogPromoCodeEligibilityResult evaluateCatalogPromoCodeEligibility({
  required String enteredCode,
  required String businessScopeId,
  required String branchId,
  required BusinessCatalogListingKind listingKind,
  required String listingId,
  String? variantId,
  required DateTime asOf,
  int? basePriceAmountSom,
  int? qualifyingSubtotalAmountSom,
  String? demoCustomerReference,
  BusinessCatalogPromoCode? promo,
  BusinessCatalogDiscountRule? linkedDiscount,
  CatalogPromoUsageSnapshot? usageSnapshot,
}) {
  final normalized = catalogPromoCodeNormalize(enteredCode);
  if (normalized == null) {
    return const CatalogPromoCodeEligibilityResult.ineligible(
      CatalogPromoCodeEligibilityStatus.invalidCode,
    );
  }
  if (promo == null || promo.normalizedCode != normalized) {
    return const CatalogPromoCodeEligibilityResult.ineligible(
      CatalogPromoCodeEligibilityStatus.invalidCode,
    );
  }
  if (promo.businessScopeId != businessScopeId) {
    return const CatalogPromoCodeEligibilityResult.ineligible(
      CatalogPromoCodeEligibilityStatus.scopeMismatch,
    );
  }
  final promoBranch = promo.branchId?.trim();
  if (promoBranch != null &&
      promoBranch.isNotEmpty &&
      promoBranch != branchId.trim()) {
    return const CatalogPromoCodeEligibilityResult.ineligible(
      CatalogPromoCodeEligibilityStatus.scopeMismatch,
    );
  }

  switch (promo.status) {
    case BusinessCatalogPriceStatus.draft:
    case BusinessCatalogPriceStatus.archived:
      return const CatalogPromoCodeEligibilityResult.ineligible(
        CatalogPromoCodeEligibilityStatus.inactive,
      );
    case BusinessCatalogPriceStatus.active:
      break;
  }

  if (asOf.toUtc().isBefore(promo.effectiveFrom.toUtc())) {
    return const CatalogPromoCodeEligibilityResult.ineligible(
      CatalogPromoCodeEligibilityStatus.notYetValid,
    );
  }
  if (promo.effectiveUntil != null &&
      !asOf.toUtc().isBefore(promo.effectiveUntil!.toUtc())) {
    return const CatalogPromoCodeEligibilityResult.ineligible(
      CatalogPromoCodeEligibilityStatus.expired,
    );
  }

  if (linkedDiscount == null ||
      linkedDiscount.discountRuleId != promo.discountRuleId) {
    return const CatalogPromoCodeEligibilityResult.ineligible(
      CatalogPromoCodeEligibilityStatus.discountRuleUnavailable,
    );
  }
  if (linkedDiscount.status != BusinessCatalogPriceStatus.active) {
    return const CatalogPromoCodeEligibilityResult.ineligible(
      CatalogPromoCodeEligibilityStatus.discountRuleUnavailable,
    );
  }
  if (!catalogPriceEffectiveAt(
    effectiveFrom: linkedDiscount.effectiveFrom,
    effectiveUntil: linkedDiscount.effectiveUntil,
    asOf: asOf,
  )) {
    return const CatalogPromoCodeEligibilityResult.ineligible(
      CatalogPromoCodeEligibilityStatus.discountRuleUnavailable,
    );
  }

  if (!catalogDiscountRuleMatchesListing(
    rule: linkedDiscount,
    listingKind: listingKind,
    listingId: listingId,
    variantId: variantId,
  )) {
    return const CatalogPromoCodeEligibilityResult.ineligible(
      CatalogPromoCodeEligibilityStatus.noApplicableDiscount,
    );
  }

  if (linkedDiscount.branchId != branchId.trim()) {
    return const CatalogPromoCodeEligibilityResult.ineligible(
      CatalogPromoCodeEligibilityStatus.scopeMismatch,
    );
  }

  final promoMin = promo.minimumBasketAmountSom;
  if (promoMin != null) {
    if (qualifyingSubtotalAmountSom == null ||
        qualifyingSubtotalAmountSom < promoMin) {
      return const CatalogPromoCodeEligibilityResult.ineligible(
        CatalogPromoCodeEligibilityStatus.minimumBasketNotMet,
      );
    }
  }

  final discountMin = linkedDiscount.minimumBasketAmountSom;
  if (discountMin != null) {
    if (qualifyingSubtotalAmountSom == null ||
        qualifyingSubtotalAmountSom < discountMin) {
      return const CatalogPromoCodeEligibilityResult.ineligible(
        CatalogPromoCodeEligibilityStatus.minimumBasketNotMet,
      );
    }
  }

  final snapshot = usageSnapshot ??
      const CatalogPromoUsageSnapshot(totalUses: 0, usesForCustomer: 0);
  if (promo.maxTotalUses != null && snapshot.totalUses >= promo.maxTotalUses!) {
    return const CatalogPromoCodeEligibilityResult.ineligible(
      CatalogPromoCodeEligibilityStatus.totalUsageLimitReached,
    );
  }
  if (promo.maxUsesPerCustomer != null) {
    final customerRef = demoCustomerReference?.trim();
    if (customerRef != null &&
        customerRef.isNotEmpty &&
        snapshot.usesForCustomer >= promo.maxUsesPerCustomer!) {
      return const CatalogPromoCodeEligibilityResult.ineligible(
        CatalogPromoCodeEligibilityStatus.customerUsageLimitReached,
      );
    }
  }

  if (basePriceAmountSom == null) {
    return const CatalogPromoCodeEligibilityResult.ineligible(
      CatalogPromoCodeEligibilityStatus.basePriceRequired,
    );
  }

  final discountAmount = catalogDiscountComputeAmount(
    rule: linkedDiscount,
    basePriceAmountSom: basePriceAmountSom,
  );

  return CatalogPromoCodeEligibilityResult.eligible(
    promoCodeId: promo.promoCodeId,
    discountRuleId: linkedDiscount.discountRuleId,
    baseAmountSom: basePriceAmountSom,
    discountAmountSom: discountAmount,
  );
}

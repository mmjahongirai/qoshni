import 'package:qoshni/features/business_platform/domain/business_catalog_discount_rule.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_discount_target_scope.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_listing_kind.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_price_status.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_discount_validation.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_pricing_validation.dart';

enum CatalogDiscountResolutionStatus {
  applied,
  notApplied,
  ambiguous,
}

enum CatalogDiscountNotAppliedReason {
  noEligibleRule,
  minimumBasketNotMet,
  ambiguousRules,
}

class CatalogDiscountResolution {
  const CatalogDiscountResolution._({
    required this.status,
    required this.baseAmountSom,
    required this.discountAmountSom,
    required this.finalAmountSom,
    this.appliedRuleId,
    this.notAppliedReason,
    this.candidateRuleIds = const [],
  });

  CatalogDiscountResolution.notApplied({
    required int baseAmountSom,
    required CatalogDiscountNotAppliedReason reason,
    List<String> candidateRuleIds = const [],
  }) : this._(
          status: candidateRuleIds.isNotEmpty &&
                  reason == CatalogDiscountNotAppliedReason.ambiguousRules
              ? CatalogDiscountResolutionStatus.ambiguous
              : CatalogDiscountResolutionStatus.notApplied,
          baseAmountSom: baseAmountSom,
          discountAmountSom: 0,
          finalAmountSom: baseAmountSom,
          notAppliedReason: reason,
          candidateRuleIds: candidateRuleIds,
        );

  const CatalogDiscountResolution.applied({
    required int baseAmountSom,
    required int discountAmountSom,
    required String appliedRuleId,
  }) : this._(
          status: CatalogDiscountResolutionStatus.applied,
          baseAmountSom: baseAmountSom,
          discountAmountSom: discountAmountSom,
          finalAmountSom: baseAmountSom - discountAmountSom,
          appliedRuleId: appliedRuleId,
        );

  final CatalogDiscountResolutionStatus status;
  final int baseAmountSom;
  final int discountAmountSom;
  final int finalAmountSom;
  final String? appliedRuleId;
  final CatalogDiscountNotAppliedReason? notAppliedReason;
  final List<String> candidateRuleIds;
}

bool catalogDiscountRuleMatchesListing({
  required BusinessCatalogDiscountRule rule,
  required BusinessCatalogListingKind listingKind,
  required String listingId,
  String? variantId,
}) {
  switch (rule.targetScope) {
    case BusinessCatalogDiscountTargetScope.businessWide:
      return true;
    case BusinessCatalogDiscountTargetScope.product:
      if (listingKind != BusinessCatalogListingKind.product) {
        return false;
      }
      if (rule.listingId?.trim() != listingId.trim()) {
        return false;
      }
      final ruleVariant = rule.variantId?.trim();
      if (ruleVariant != null && ruleVariant.isNotEmpty) {
        return variantId?.trim() == ruleVariant;
      }
      return true;
    case BusinessCatalogDiscountTargetScope.service:
      if (listingKind != BusinessCatalogListingKind.service) {
        return false;
      }
      return rule.listingId?.trim() == listingId.trim();
  }
}

CatalogDiscountResolution resolveCatalogDiscount({
  required Iterable<BusinessCatalogDiscountRule> rules,
  required BusinessCatalogListingKind listingKind,
  required String listingId,
  required String branchId,
  String? variantId,
  required int basePriceAmountSom,
  int? qualifyingSubtotalAmountSom,
  required DateTime asOf,
}) {
  final branch = branchId.trim();
  final listing = listingId.trim();

  bool isActiveEligible(BusinessCatalogDiscountRule rule) {
    if (rule.status != BusinessCatalogPriceStatus.active) {
      return false;
    }
    if (rule.branchId != branch) {
      return false;
    }
    if (!catalogPriceEffectiveAt(
      effectiveFrom: rule.effectiveFrom,
      effectiveUntil: rule.effectiveUntil,
      asOf: asOf,
    )) {
      return false;
    }
    if (!catalogDiscountRuleMatchesListing(
      rule: rule,
      listingKind: listingKind,
      listingId: listing,
      variantId: variantId,
    )) {
      return false;
    }
    final minimum = rule.minimumBasketAmountSom;
    if (minimum != null) {
      if (qualifyingSubtotalAmountSom == null ||
          qualifyingSubtotalAmountSom < minimum) {
        return false;
      }
    }
    return true;
  }

  final eligible = rules.where(isActiveEligible).toList(growable: false);
  if (eligible.isEmpty) {
    return CatalogDiscountResolution.notApplied(
      baseAmountSom: basePriceAmountSom,
      reason: CatalogDiscountNotAppliedReason.noEligibleRule,
    );
  }

  final maxPriority = eligible.map((r) => r.priority).reduce((a, b) => a > b ? a : b);
  final top = eligible.where((r) => r.priority == maxPriority).toList();
  if (top.length > 1) {
    final ids = top.map((r) => r.discountRuleId).toList()..sort();
    return CatalogDiscountResolution.notApplied(
      baseAmountSom: basePriceAmountSom,
      reason: CatalogDiscountNotAppliedReason.ambiguousRules,
      candidateRuleIds: ids,
    );
  }

  final winner = top.single;
  final discountAmount = catalogDiscountComputeAmount(
    rule: winner,
    basePriceAmountSom: basePriceAmountSom,
  );
  return CatalogDiscountResolution.applied(
    baseAmountSom: basePriceAmountSom,
    discountAmountSom: discountAmount,
    appliedRuleId: winner.discountRuleId,
  );
}

import 'package:qoshni/features/business_platform/domain/business_catalog_discount_rule.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_discount_target_scope.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_discount_type.dart';

bool catalogDiscountPercentBasisPointsValid(int basisPoints) {
  return basisPoints > 0 && basisPoints <= kBusinessCatalogDiscountBasisPointsMax;
}

bool catalogDiscountFixedAmountValid(int amountSom) => amountSom >= 0;

bool catalogDiscountMinimumBasketValid(int? minimumBasketAmountSom) {
  if (minimumBasketAmountSom == null) {
    return true;
  }
  return minimumBasketAmountSom >= 0;
}

String? catalogDiscountInputValidationError(
  BusinessCatalogDiscountRuleInput input,
) {
  switch (input.targetScope) {
    case BusinessCatalogDiscountTargetScope.businessWide:
      final listing = input.listingId?.trim();
      final variant = input.variantId?.trim();
      if ((listing != null && listing.isNotEmpty) ||
          (variant != null && variant.isNotEmpty)) {
        return 'invalid_target';
      }
    case BusinessCatalogDiscountTargetScope.product:
      final listing = input.listingId?.trim();
      if (listing == null || listing.isEmpty) {
        return 'invalid_target';
      }
    case BusinessCatalogDiscountTargetScope.service:
      final listing = input.listingId?.trim();
      if (listing == null || listing.isEmpty) {
        return 'invalid_target';
      }
      final variant = input.variantId?.trim();
      if (variant != null && variant.isNotEmpty) {
        return 'variant_on_service';
      }
  }

  switch (input.discountType) {
    case BusinessCatalogDiscountType.percentage:
      final bp = input.percentBasisPoints;
      if (bp == null || !catalogDiscountPercentBasisPointsValid(bp)) {
        return 'invalid_discount_value';
      }
    case BusinessCatalogDiscountType.fixedAmount:
      final fixed = input.fixedAmountSom;
      if (fixed == null || !catalogDiscountFixedAmountValid(fixed)) {
        return 'invalid_discount_value';
      }
  }

  if (!catalogDiscountMinimumBasketValid(input.minimumBasketAmountSom)) {
    return 'invalid_minimum_basket';
  }

  return null;
}

String catalogDiscountTargetKey({
  required String branchId,
  required BusinessCatalogDiscountTargetScope targetScope,
  String? listingId,
  String? variantId,
}) {
  final listing = listingId?.trim() ?? '';
  final variant = variantId?.trim() ?? '';
  return '${branchId.trim()}|${targetScope.name}|$listing|$variant';
}

/// Half-up rounding to whole UZS som: `(base * basisPoints + 5000) ~/ 10000`.
int catalogDiscountAmountFromPercent({
  required int basePriceAmountSom,
  required int percentBasisPoints,
}) {
  if (basePriceAmountSom <= 0 || percentBasisPoints <= 0) {
    return 0;
  }
  return (basePriceAmountSom * percentBasisPoints + 5000) ~/ 10000;
}

int catalogDiscountAmountFromFixed({
  required int basePriceAmountSom,
  required int fixedAmountSom,
}) {
  if (fixedAmountSom <= 0) {
    return 0;
  }
  return fixedAmountSom > basePriceAmountSom ? basePriceAmountSom : fixedAmountSom;
}

int catalogDiscountComputeAmount({
  required BusinessCatalogDiscountRule rule,
  required int basePriceAmountSom,
}) {
  switch (rule.discountType) {
    case BusinessCatalogDiscountType.percentage:
      return catalogDiscountAmountFromPercent(
        basePriceAmountSom: basePriceAmountSom,
        percentBasisPoints: rule.percentBasisPoints ?? 0,
      );
    case BusinessCatalogDiscountType.fixedAmount:
      return catalogDiscountAmountFromFixed(
        basePriceAmountSom: basePriceAmountSom,
        fixedAmountSom: rule.fixedAmountSom ?? 0,
      );
  }
}

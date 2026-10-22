import 'package:qoshni/features/business_platform/domain/business_catalog_discount_rule.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_price_status.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_promo_code.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_pricing_validation.dart';

final RegExp kCatalogPromoCodeFormat = RegExp(r'^[A-Z0-9_-]+$');

String? catalogPromoCodeNormalize(String rawCode) {
  final trimmed = rawCode.trim();
  if (trimmed.isEmpty) {
    return null;
  }
  final normalized = trimmed.toUpperCase();
  if (!kCatalogPromoCodeFormat.hasMatch(normalized)) {
    return null;
  }
  return normalized;
}

bool catalogPromoLimitsValid({
  int? maxTotalUses,
  int? maxUsesPerCustomer,
  int? minimumBasketAmountSom,
}) {
  if (maxTotalUses != null && maxTotalUses < 0) {
    return false;
  }
  if (maxUsesPerCustomer != null && maxUsesPerCustomer < 0) {
    return false;
  }
  if (minimumBasketAmountSom != null && minimumBasketAmountSom < 0) {
    return false;
  }
  return true;
}

String? catalogPromoCodeInputValidationError(BusinessCatalogPromoCodeInput input) {
  if (catalogPromoCodeNormalize(input.code) == null) {
    return 'invalid_code';
  }
  if (!catalogPriceEffectiveRangeValid(
    effectiveFrom: input.effectiveFrom,
    effectiveUntil: input.effectiveUntil,
  )) {
    return 'invalid_effective_range';
  }
  if (!catalogPromoLimitsValid(
    maxTotalUses: input.maxTotalUses,
    maxUsesPerCustomer: input.maxUsesPerCustomer,
    minimumBasketAmountSom: input.minimumBasketAmountSom,
  )) {
    return 'invalid_limits';
  }
  return null;
}

bool catalogPromoDiscountLinkValidForActivate({
  required BusinessCatalogPromoCode promo,
  required BusinessCatalogDiscountRule discount,
  required DateTime asOf,
}) {
  if (discount.businessScopeId != promo.businessScopeId) {
    return false;
  }
  if (discount.status != BusinessCatalogPriceStatus.active) {
    return false;
  }
  if (!catalogPriceEffectiveAt(
    effectiveFrom: discount.effectiveFrom,
    effectiveUntil: discount.effectiveUntil,
    asOf: asOf,
  )) {
    return false;
  }
  if (!catalogPriceIntervalsOverlap(
    fromA: promo.effectiveFrom,
    untilA: promo.effectiveUntil,
    fromB: discount.effectiveFrom,
    untilB: discount.effectiveUntil,
  )) {
    return false;
  }
  final promoBranch = promo.branchId?.trim();
  if (promoBranch != null && promoBranch.isNotEmpty) {
    if (discount.branchId != promoBranch) {
      return false;
    }
  }
  return true;
}

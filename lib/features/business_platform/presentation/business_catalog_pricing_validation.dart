import 'package:qoshni/features/business_platform/domain/business_catalog_listing_kind.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_price.dart';

bool catalogPriceAmountValid(int amountSom) => amountSom >= 0;

bool catalogPriceCurrencyValid(String currencyCode) {
  final code = currencyCode.trim().toUpperCase();
  return kBusinessCatalogSupportedPriceCurrencies.contains(code);
}

bool catalogPriceEffectiveRangeValid({
  required DateTime effectiveFrom,
  DateTime? effectiveUntil,
}) {
  if (effectiveUntil == null) {
    return true;
  }
  final from = effectiveFrom.toUtc();
  final until = effectiveUntil.toUtc();
  return until.isAfter(from);
}

bool catalogPriceEffectiveAt({
  required DateTime effectiveFrom,
  DateTime? effectiveUntil,
  required DateTime asOf,
}) {
  final from = effectiveFrom.toUtc();
  final at = asOf.toUtc();
  if (at.isBefore(from)) {
    return false;
  }
  if (effectiveUntil != null && !at.isBefore(effectiveUntil.toUtc())) {
    return false;
  }
  return true;
}

DateTime _catalogPriceOpenIntervalEnd(DateTime? until) =>
    until?.toUtc() ?? DateTime.utc(9999, 12, 31, 23, 59, 59);

bool catalogPriceIntervalsOverlap({
  required DateTime fromA,
  DateTime? untilA,
  required DateTime fromB,
  DateTime? untilB,
}) {
  final aStart = fromA.toUtc();
  final bStart = fromB.toUtc();
  final aEnd = _catalogPriceOpenIntervalEnd(untilA);
  final bEnd = _catalogPriceOpenIntervalEnd(untilB);
  return aStart.isBefore(bEnd) && bStart.isBefore(aEnd);
}

String? catalogPriceInputValidationError(BusinessCatalogPriceInput input) {
  if (!catalogPriceAmountValid(input.amountSom)) {
    return 'invalid_amount';
  }
  if (!catalogPriceCurrencyValid(input.currencyCode)) {
    return 'invalid_currency';
  }
  if (!catalogPriceEffectiveRangeValid(
    effectiveFrom: input.effectiveFrom,
    effectiveUntil: input.effectiveUntil,
  )) {
    return 'invalid_effective_range';
  }
  if (input.listingKind == BusinessCatalogListingKind.service) {
    final variant = input.variantId?.trim();
    if (variant != null && variant.isNotEmpty) {
      return 'variant_on_service';
    }
  }
  return null;
}

String catalogPriceTargetKey({
  required String branchId,
  required BusinessCatalogListingKind listingKind,
  required String listingId,
  String? variantId,
}) {
  final variantPart = variantId?.trim() ?? '';
  return '${branchId.trim()}|${listingKind.name}|${listingId.trim()}|$variantPart';
}

String formatCatalogPriceAmountSom(int amountSom, {String currencyCode = 'UZS'}) {
  final digits = amountSom.abs().toString();
  final buffer = StringBuffer();
  if (amountSom < 0) {
    buffer.write('-');
  }
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) {
      buffer.write(' ');
    }
    buffer.write(digits[i]);
  }
  return '${buffer.toString()} $currencyCode';
}

import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_listing_kind.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_price.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_pricing_validation.dart';

void main() {
  test('amount and currency validation', () {
    expect(catalogPriceAmountValid(0), isTrue);
    expect(catalogPriceAmountValid(8000), isTrue);
    expect(catalogPriceAmountValid(-1), isFalse);
    expect(catalogPriceCurrencyValid('UZS'), isTrue);
    expect(catalogPriceCurrencyValid('usd'), isFalse);
  });

  test('effective range rejects until before from', () {
    final from = DateTime.utc(2025, 6, 1);
    final until = DateTime.utc(2025, 5, 1);
    expect(
      catalogPriceEffectiveRangeValid(
        effectiveFrom: from,
        effectiveUntil: until,
      ),
      isFalse,
    );
    expect(
      catalogPriceEffectiveRangeValid(
        effectiveFrom: from,
        effectiveUntil: DateTime.utc(2025, 7, 1),
      ),
      isTrue,
    );
  });

  test('effective at uses half-open interval', () {
    final from = DateTime.utc(2025, 6, 1);
    final until = DateTime.utc(2025, 12, 1);
    expect(
      catalogPriceEffectiveAt(
        effectiveFrom: from,
        effectiveUntil: until,
        asOf: from,
      ),
      isTrue,
    );
    expect(
      catalogPriceEffectiveAt(
        effectiveFrom: from,
        effectiveUntil: until,
        asOf: until,
      ),
      isFalse,
    );
    expect(
      catalogPriceEffectiveAt(
        effectiveFrom: from,
        effectiveUntil: null,
        asOf: DateTime.utc(2030, 1, 1),
      ),
      isTrue,
    );
  });

  test('variant on service input rejected', () {
    final error = catalogPriceInputValidationError(
      BusinessCatalogPriceInput(
        listingKind: BusinessCatalogListingKind.service,
        listingId: 'svc',
        variantId: 'var',
        branchId: 'branch',
        amountSom: 100,
        currencyCode: kBusinessCatalogPriceCurrencyUzs,
        effectiveFrom: DateTime.utc(2025, 1, 1),
      ),
    );
    expect(error, 'variant_on_service');
  });

  test('interval overlap detection', () {
    expect(
      catalogPriceIntervalsOverlap(
        fromA: DateTime.utc(2025, 1, 1),
        untilA: DateTime.utc(2025, 6, 1),
        fromB: DateTime.utc(2025, 5, 1),
        untilB: DateTime.utc(2025, 12, 1),
      ),
      isTrue,
    );
    expect(
      catalogPriceIntervalsOverlap(
        fromA: DateTime.utc(2025, 1, 1),
        untilA: DateTime.utc(2025, 6, 1),
        fromB: DateTime.utc(2025, 6, 1),
        untilB: DateTime.utc(2025, 12, 1),
      ),
      isFalse,
    );
  });
}

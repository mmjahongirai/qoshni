import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/features/business_platform/data/business_catalog_pricing_demo_seed.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_promo_code.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_promo_code_validation.dart';

void main() {
  test('normalizes trim and case', () {
    expect(catalogPromoCodeNormalize('  non10 '), 'NON10');
  });

  test('rejects invalid format and empty', () {
    expect(catalogPromoCodeNormalize(''), isNull);
    expect(catalogPromoCodeNormalize('bad code'), isNull);
    expect(catalogPromoCodeNormalize('unicode–dash'), isNull);
  });

  test('input validation catches bad code', () {
    final input = BusinessCatalogPromoCodeInput(
      code: '!!!',
      discountRuleId: 'rule',
      effectiveFrom: kDemoCatalogPricingEpoch,
    );
    expect(catalogPromoCodeInputValidationError(input), 'invalid_code');
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_discount_rule.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_discount_target_scope.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_discount_type.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_discount_validation.dart';

void main() {
  test('percent and fixed validation', () {
    expect(catalogDiscountPercentBasisPointsValid(1000), isTrue);
    expect(catalogDiscountPercentBasisPointsValid(0), isFalse);
    expect(catalogDiscountPercentBasisPointsValid(10001), isFalse);
    expect(catalogDiscountFixedAmountValid(0), isTrue);
    expect(catalogDiscountFixedAmountValid(-1), isFalse);
  });

  test('half-up percent rounding to whole UZS', () {
    expect(
      catalogDiscountAmountFromPercent(
        basePriceAmountSom: 8000,
        percentBasisPoints: 1000,
      ),
      800,
    );
    expect(
      catalogDiscountAmountFromPercent(
        basePriceAmountSom: 8501,
        percentBasisPoints: 1000,
      ),
      850,
    );
  });

  test('fixed discount capped at base', () {
    expect(
      catalogDiscountAmountFromFixed(
        basePriceAmountSom: 5000,
        fixedAmountSom: 9000,
      ),
      5000,
    );
  });

  test('service target rejects variant', () {
    final error = catalogDiscountInputValidationError(
      BusinessCatalogDiscountRuleInput(
        branchId: 'branch',
        targetScope: BusinessCatalogDiscountTargetScope.service,
        listingId: 'svc',
        variantId: 'var',
        discountType: BusinessCatalogDiscountType.fixedAmount,
        fixedAmountSom: 100,
        effectiveFrom: DateTime.utc(2025, 1, 1),
        priority: 1,
      ),
    );
    expect(error, 'variant_on_service');
  });
}

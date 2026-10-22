import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_commercial_fee_application_basis.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_commercial_fee_calculation_type.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_commercial_fee_charge_bearer.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_commercial_fee_rule.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_commercial_fee_type.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_commercial_fee_validation.dart';

void main() {
  test('percent basis points bounds', () {
    expect(catalogCommercialFeePercentBasisPointsValid(500), isTrue);
    expect(catalogCommercialFeePercentBasisPointsValid(0), isFalse);
    expect(catalogCommercialFeePercentBasisPointsValid(10001), isFalse);
  });

  test('rounding half-up', () {
    expect(
      catalogCommercialFeeAmountFromPercent(
        basisAmountSom: 8000,
        percentBasisPoints: 500,
      ),
      400,
    );
    expect(
      catalogCommercialFeeAmountFromPercent(
        basisAmountSom: 1,
        percentBasisPoints: 5000,
      ),
      1,
    );
  });

  test('input validation rejects invalid fixed', () {
    final input = BusinessCatalogCommercialFeeRuleInput(
      feeType: BusinessCatalogCommercialFeeType.platformFee,
      chargeBearer: BusinessCatalogCommercialFeeChargeBearer.customer,
      calculationType: BusinessCatalogCommercialFeeCalculationType.fixedAmount,
      fixedAmountSom: -1,
      applicationBasis: BusinessCatalogCommercialFeeApplicationBasis.listingBase,
      effectiveFrom: DateTime.utc(2025, 1, 1),
      priority: 1,
    );
    expect(catalogCommercialFeeInputValidationError(input), isNotNull);
  });
}

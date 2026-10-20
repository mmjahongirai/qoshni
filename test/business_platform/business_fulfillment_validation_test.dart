import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/features/business_platform/domain/business_fulfillment_configuration.dart';
import 'package:qoshni/features/business_platform/domain/business_fulfillment_target_scope.dart';
import 'package:qoshni/features/business_platform/domain/business_fulfillment_type.dart';
import 'package:qoshni/features/business_platform/presentation/business_fulfillment_validation.dart';

void main() {
  test('rejects empty and duplicate types', () {
    expect(
      catalogFulfillmentInputValidationError(
        const BusinessFulfillmentConfigurationInput(
          branchId: 'b',
          targetScope: BusinessFulfillmentTargetScope.businessWide,
          supportedFulfillmentTypes: [],
        ),
      ),
      'empty_types',
    );
    expect(
      catalogFulfillmentInputValidationError(
        BusinessFulfillmentConfigurationInput(
          branchId: 'b',
          targetScope: BusinessFulfillmentTargetScope.businessWide,
          supportedFulfillmentTypes: [
            BusinessFulfillmentType.delivery,
            BusinessFulfillmentType.delivery,
          ],
        ),
      ),
      'duplicate_type',
    );
  });

  test('scope listing rules', () {
    expect(
      catalogFulfillmentInputValidationError(
        const BusinessFulfillmentConfigurationInput(
          branchId: 'b',
          targetScope: BusinessFulfillmentTargetScope.product,
          supportedFulfillmentTypes: [BusinessFulfillmentType.pickup],
        ),
      ),
      'invalid_target',
    );
  });
}

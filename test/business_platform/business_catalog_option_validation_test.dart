import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_localized_fields.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_option_group.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_option_selection_mode.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_option_validation.dart';

void main() {
  test('required group needs min and max at least 1', () {
    final issue = validateCatalogOptionGroupInput(
      const BusinessCatalogOptionGroupInput(
        localized: BusinessCatalogLocalizedFields(nameEn: 'Size'),
        description: BusinessCatalogLocalizedFields(),
        selectionMode: BusinessCatalogOptionSelectionMode.single,
        required: true,
        minSelections: 0,
        maxSelections: 1,
      ),
    );
    expect(issue, CatalogOptionGroupValidationIssue.inconsistentRequiredRules);
  });

  test('single selection rejects max above 1', () {
    final issue = validateCatalogOptionGroupInput(
      const BusinessCatalogOptionGroupInput(
        localized: BusinessCatalogLocalizedFields(nameEn: 'Extras'),
        description: BusinessCatalogLocalizedFields(),
        selectionMode: BusinessCatalogOptionSelectionMode.single,
        required: false,
        minSelections: 0,
        maxSelections: 2,
      ),
    );
    expect(issue, CatalogOptionGroupValidationIssue.invalidSelectionLimits);
  });

  test('valid multiple selection group passes', () {
    final issue = validateCatalogOptionGroupInput(
      const BusinessCatalogOptionGroupInput(
        localized: BusinessCatalogLocalizedFields(nameEn: 'Toppings'),
        description: BusinessCatalogLocalizedFields(),
        selectionMode: BusinessCatalogOptionSelectionMode.multiple,
        required: false,
        minSelections: 0,
        maxSelections: 3,
      ),
    );
    expect(issue, CatalogOptionGroupValidationIssue.none);
  });

  test('option requires localized name', () {
    expect(
      validateCatalogOptionInput(const BusinessCatalogLocalizedFields()),
      CatalogOptionValidationIssue.missingName,
    );
  });
}

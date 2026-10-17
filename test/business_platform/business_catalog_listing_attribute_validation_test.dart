import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_attribute_value_kind.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_listing_attribute.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_localized_fields.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_listing_attribute_validation.dart';

void main() {
  test('rejects empty and invalid keys', () {
    expect(
      validateCatalogListingAttributeInput(
        const BusinessCatalogListingAttributeInput(
          key: '',
          label: BusinessCatalogLocalizedFields(nameEn: 'Unit'),
          valueKind: BusinessCatalogAttributeValueKind.text,
          textValue: 'loaf',
          choiceValue: '',
        ),
      ),
      CatalogListingAttributeValidationIssue.emptyKey,
    );
    expect(
      validateCatalogListingAttributeInput(
        const BusinessCatalogListingAttributeInput(
          key: 'Bad-Key',
          label: BusinessCatalogLocalizedFields(nameEn: 'Unit'),
          valueKind: BusinessCatalogAttributeValueKind.text,
          textValue: 'loaf',
          choiceValue: '',
        ),
      ),
      CatalogListingAttributeValidationIssue.invalidKey,
    );
  });

  test('requires label and typed values', () {
    expect(
      validateCatalogListingAttributeInput(
        const BusinessCatalogListingAttributeInput(
          key: 'unit',
          label: BusinessCatalogLocalizedFields(),
          valueKind: BusinessCatalogAttributeValueKind.text,
          textValue: 'loaf',
          choiceValue: '',
        ),
      ),
      CatalogListingAttributeValidationIssue.missingLabel,
    );
    expect(
      validateCatalogListingAttributeInput(
        const BusinessCatalogListingAttributeInput(
          key: 'weight',
          label: BusinessCatalogLocalizedFields(nameEn: 'Weight'),
          valueKind: BusinessCatalogAttributeValueKind.number,
          textValue: '',
          choiceValue: '',
        ),
      ),
      CatalogListingAttributeValidationIssue.invalidValue,
    );
  });
}

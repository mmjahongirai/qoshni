import 'package:qoshni/features/business_platform/domain/business_catalog_attribute_value_kind.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_listing_attribute.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_listing_validation.dart';

final RegExp _catalogAttributeKeyPattern = RegExp(r'^[a-z][a-z0-9_]*$');

enum CatalogListingAttributeValidationIssue {
  none,
  emptyKey,
  invalidKey,
  missingLabel,
  invalidValue,
}

CatalogListingAttributeValidationIssue validateCatalogListingAttributeInput(
  BusinessCatalogListingAttributeInput input,
) {
  final key = input.key.trim();
  if (key.isEmpty) {
    return CatalogListingAttributeValidationIssue.emptyKey;
  }
  if (!_catalogAttributeKeyPattern.hasMatch(key)) {
    return CatalogListingAttributeValidationIssue.invalidKey;
  }
  if (!catalogListingHasName(input.label)) {
    return CatalogListingAttributeValidationIssue.missingLabel;
  }
  switch (input.valueKind) {
    case BusinessCatalogAttributeValueKind.text:
      if (input.textValue.trim().isEmpty) {
        return CatalogListingAttributeValidationIssue.invalidValue;
      }
    case BusinessCatalogAttributeValueKind.number:
      final n = input.numberValue;
      if (n == null || !n.isFinite) {
        return CatalogListingAttributeValidationIssue.invalidValue;
      }
    case BusinessCatalogAttributeValueKind.choice:
      if (input.choiceValue.trim().isEmpty) {
        return CatalogListingAttributeValidationIssue.invalidValue;
      }
  }
  return CatalogListingAttributeValidationIssue.none;
}

bool isValidCatalogAttributeKey(String key) =>
    _catalogAttributeKeyPattern.hasMatch(key.trim());

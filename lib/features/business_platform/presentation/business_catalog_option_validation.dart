import 'package:qoshni/features/business_platform/domain/business_catalog_localized_fields.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_option_group.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_option_selection_mode.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_listing_validation.dart';

enum CatalogOptionGroupValidationIssue {
  none,
  missingName,
  invalidSelectionLimits,
  inconsistentRequiredRules,
}

enum CatalogOptionValidationIssue {
  none,
  missingName,
}

CatalogOptionGroupValidationIssue validateCatalogOptionGroupInput(
  BusinessCatalogOptionGroupInput input,
) {
  if (!catalogListingHasName(input.localized)) {
    return CatalogOptionGroupValidationIssue.missingName;
  }
  final min = input.minSelections;
  final max = input.maxSelections;
  if (min < 0 || max < 0 || min > max) {
    return CatalogOptionGroupValidationIssue.invalidSelectionLimits;
  }
  if (input.selectionMode == BusinessCatalogOptionSelectionMode.single) {
    if (max > 1 || min > 1) {
      return CatalogOptionGroupValidationIssue.invalidSelectionLimits;
    }
  }
  if (input.required) {
    if (min < 1) {
      return CatalogOptionGroupValidationIssue.inconsistentRequiredRules;
    }
    if (max < 1) {
      return CatalogOptionGroupValidationIssue.inconsistentRequiredRules;
    }
  } else if (min > 0 && max < min) {
    return CatalogOptionGroupValidationIssue.invalidSelectionLimits;
  }
  return CatalogOptionGroupValidationIssue.none;
}

CatalogOptionValidationIssue validateCatalogOptionInput(
  BusinessCatalogLocalizedFields localized,
) {
  if (!catalogListingHasName(localized)) {
    return CatalogOptionValidationIssue.missingName;
  }
  return CatalogOptionValidationIssue.none;
}

bool catalogOptionLocalizedHasName(BusinessCatalogLocalizedFields localized) =>
    catalogListingHasName(localized);

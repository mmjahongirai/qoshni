import 'package:qoshni/features/business_platform/domain/business_catalog_localized_fields.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_resource.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_listing_validation.dart';

bool catalogResourceQuantitiesValid({
  required int totalCapacity,
  required int allocatedCapacity,
}) {
  if (totalCapacity < 0 || allocatedCapacity < 0) {
    return false;
  }
  if (allocatedCapacity > totalCapacity) {
    return false;
  }
  return true;
}

int catalogResourceAvailableCapacity({
  required int totalCapacity,
  required int allocatedCapacity,
  required bool countsAsActive,
}) {
  if (!countsAsActive) {
    return 0;
  }
  final raw = totalCapacity - allocatedCapacity;
  return raw < 0 ? 0 : raw;
}

String? catalogResourceInputValidationError(BusinessCatalogResourceInput input) {
  if (!catalogListingHasName(input.localized)) {
    return 'name_required';
  }
  if (input.capacityUnit.trim().isEmpty) {
    return 'unit_required';
  }
  if (input.totalCapacity < 0) {
    return 'negative_capacity';
  }
  return null;
}

String? catalogResourceCapacityChangeValidationError(
  BusinessCatalogResource resource,
  BusinessCatalogResourceCapacityChangeInput input,
) {
  if (input.reason.trim().isEmpty) {
    return 'reason_required';
  }
  if (input.newTotalCapacity < 0) {
    return 'negative_capacity';
  }
  if (input.newTotalCapacity < resource.allocatedCapacity) {
    return 'below_allocated';
  }
  if (input.newTotalCapacity == resource.totalCapacity) {
    return 'no_change';
  }
  return null;
}

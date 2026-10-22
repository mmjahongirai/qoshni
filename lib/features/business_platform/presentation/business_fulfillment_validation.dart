import 'package:qoshni/features/business_platform/domain/business_fulfillment_configuration.dart';
import 'package:qoshni/features/business_platform/domain/business_fulfillment_target_scope.dart';
import 'package:qoshni/features/business_platform/domain/business_fulfillment_type.dart';

List<BusinessFulfillmentType> catalogFulfillmentTypesNormalize(
  List<BusinessFulfillmentType> types,
) {
  final seen = <BusinessFulfillmentType>{};
  final result = <BusinessFulfillmentType>[];
  for (final t in types) {
    if (seen.add(t)) {
      result.add(t);
    }
  }
  return result;
}

String catalogFulfillmentTargetKey({
  required String branchId,
  required BusinessFulfillmentTargetScope targetScope,
  String? listingId,
}) {
  final listing = listingId?.trim() ?? '';
  return '${branchId.trim()}|${targetScope.name}|$listing';
}

String? catalogFulfillmentInputValidationError(
  BusinessFulfillmentConfigurationInput input,
) {
  final normalized = catalogFulfillmentTypesNormalize(input.supportedFulfillmentTypes);
  if (normalized.isEmpty) {
    return 'empty_types';
  }
  if (normalized.length != input.supportedFulfillmentTypes.length) {
    return 'duplicate_type';
  }
  switch (input.targetScope) {
    case BusinessFulfillmentTargetScope.businessWide:
      final listing = input.listingId?.trim();
      if (listing != null && listing.isNotEmpty) {
        return 'invalid_target';
      }
    case BusinessFulfillmentTargetScope.product:
    case BusinessFulfillmentTargetScope.service:
      final listing = input.listingId?.trim();
      if (listing == null || listing.isEmpty) {
        return 'invalid_target';
      }
  }
  return null;
}

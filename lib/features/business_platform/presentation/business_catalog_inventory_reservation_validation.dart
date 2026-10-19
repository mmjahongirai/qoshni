import 'package:qoshni/features/business_platform/domain/business_catalog_inventory_item.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_inventory_track_status.dart';

String? catalogInventoryReservationInputValidationError({
  required int quantity,
  required DateTime expiresAt,
  required DateTime now,
  BusinessCatalogInventoryItem? item,
  required String businessScopeId,
}) {
  if (quantity <= 0) {
    return 'invalid_quantity';
  }
  if (!expiresAt.isAfter(now)) {
    return 'invalid_expiry';
  }
  if (item == null) {
    return 'not_found';
  }
  if (item.businessScopeId != businessScopeId) {
    return 'invalid_scope';
  }
  if (item.trackStatus ==
      BusinessCatalogInventoryTrackStatus.manuallyUnavailable) {
    return 'item_unavailable';
  }
  if (item.availableQuantity < quantity) {
    return 'insufficient_available';
  }
  return null;
}

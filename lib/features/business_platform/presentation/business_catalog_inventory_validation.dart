import 'package:qoshni/features/business_platform/domain/business_catalog_inventory_adjustment.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_inventory_item.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_inventory_track_status.dart';

bool catalogInventoryQuantitiesValid({
  required int onHandQuantity,
  required int reservedQuantity,
  required int lowStockThreshold,
}) {
  if (onHandQuantity < 0 ||
      reservedQuantity < 0 ||
      lowStockThreshold < 0) {
    return false;
  }
  if (reservedQuantity > onHandQuantity) {
    return false;
  }
  return true;
}

int catalogInventoryAvailableQuantity({
  required int onHandQuantity,
  required int reservedQuantity,
  required BusinessCatalogInventoryTrackStatus trackStatus,
}) {
  if (trackStatus == BusinessCatalogInventoryTrackStatus.manuallyUnavailable) {
    return 0;
  }
  final raw = onHandQuantity - reservedQuantity;
  return raw < 0 ? 0 : raw;
}

String? catalogInventoryAdjustmentValidationError(
  BusinessCatalogInventoryItem item,
  BusinessCatalogInventoryAdjustmentInput input,
) {
  final reason = input.reason.trim();
  if (reason.isEmpty) {
    return 'reason_required';
  }
  if (input.delta == 0) {
    return 'delta_zero';
  }

  switch (input.kind) {
    case BusinessCatalogInventoryAdjustmentKind.onHandDelta:
      final nextOnHand = item.onHandQuantity + input.delta;
      if (nextOnHand < 0) {
        return 'on_hand_negative';
      }
      if (item.reservedQuantity > nextOnHand) {
        return 'reserved_exceeds_on_hand';
      }
    case BusinessCatalogInventoryAdjustmentKind.reservedDelta:
      final nextReserved = item.reservedQuantity + input.delta;
      if (nextReserved < 0) {
        return 'reserved_negative';
      }
      if (nextReserved > item.onHandQuantity) {
        return 'reserved_exceeds_on_hand';
      }
  }
  return null;
}

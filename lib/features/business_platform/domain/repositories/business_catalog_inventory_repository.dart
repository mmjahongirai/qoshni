import 'package:qoshni/features/business_platform/domain/business_catalog_inventory_adjustment.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_inventory_availability.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_inventory_item.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_inventory_track_status.dart';

enum BusinessCatalogInventorySaveResult {
  success,
  notFound,
  invalidProduct,
  invalidBranch,
  invalidVariant,
  duplicateLocation,
  invalidQuantities,
  failure,
}

enum BusinessCatalogInventoryAdjustmentResult {
  success,
  notFound,
  invalidQuantities,
  invalidReason,
  invalidDelta,
  failure,
}

abstract class BusinessCatalogInventoryRepository {
  String get businessScopeId;

  List<BusinessCatalogInventoryItem> listForCurrentScope({
    String? branchId,
    BusinessCatalogInventoryAvailability? availability,
  });

  BusinessCatalogInventoryItem? findById(String inventoryItemId);

  BusinessCatalogInventorySaveResult upsertInventory({
    String? inventoryItemId,
    required BusinessCatalogInventoryItemInput input,
  });

  BusinessCatalogInventorySaveResult setTrackStatus({
    required String inventoryItemId,
    required BusinessCatalogInventoryTrackStatus trackStatus,
  });

  BusinessCatalogInventoryAdjustmentResult applyAdjustment({
    required String inventoryItemId,
    required BusinessCatalogInventoryAdjustmentInput input,
  });

  List<BusinessCatalogInventoryAdjustmentEvent> adjustmentHistory(
    String inventoryItemId,
  );
}

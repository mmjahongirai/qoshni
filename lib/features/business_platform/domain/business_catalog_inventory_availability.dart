import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_inventory_item.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_inventory_track_status.dart';

enum BusinessCatalogInventoryAvailability {
  inStock,
  lowStock,
  outOfStock,
  unavailable;

  String label(AppLocalizations l10n) {
    switch (this) {
      case BusinessCatalogInventoryAvailability.inStock:
        return l10n.catalogInventoryAvailabilityInStock;
      case BusinessCatalogInventoryAvailability.lowStock:
        return l10n.catalogInventoryAvailabilityLowStock;
      case BusinessCatalogInventoryAvailability.outOfStock:
        return l10n.catalogInventoryAvailabilityOutOfStock;
      case BusinessCatalogInventoryAvailability.unavailable:
        return l10n.catalogInventoryAvailabilityUnavailable;
    }
  }
}

BusinessCatalogInventoryAvailability computeCatalogInventoryAvailability(
  BusinessCatalogInventoryItem item,
) {
  if (item.trackStatus == BusinessCatalogInventoryTrackStatus.manuallyUnavailable) {
    return BusinessCatalogInventoryAvailability.unavailable;
  }
  final available = item.availableQuantity;
  if (available <= 0) {
    return BusinessCatalogInventoryAvailability.outOfStock;
  }
  if (available <= item.lowStockThreshold) {
    return BusinessCatalogInventoryAvailability.lowStock;
  }
  return BusinessCatalogInventoryAvailability.inStock;
}

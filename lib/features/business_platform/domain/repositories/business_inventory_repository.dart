import 'package:qoshni/features/business_platform/domain/business_offering_availability_state.dart';
import 'package:qoshni/features/business_platform/domain/business_offering_inventory.dart';

enum BusinessInventorySaveResult {
  success,
  profileNotEditable,
  offeringNotFound,
  invalidQuantities,
}

/// Inventory/availability for owner offerings (session storage today).
abstract class BusinessInventoryRepository {
  BusinessOfferingInventory? inventoryFor({
    required String businessProfileId,
    required String offeringId,
  });

  BusinessInventorySaveResult saveInventory({
    required String businessProfileId,
    required String offeringId,
    required BusinessOfferingAvailabilityState availability,
    int? totalQuantity,
    int? availableQuantity,
  });

  void removeForOffering({
    required String businessProfileId,
    required String offeringId,
  });

  void pruneOrphansForProfile(String businessProfileId);
}

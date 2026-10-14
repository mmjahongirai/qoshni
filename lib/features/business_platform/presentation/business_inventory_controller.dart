import 'package:flutter/foundation.dart';
import 'package:qoshni/features/business_platform/domain/business_offering_availability_state.dart';
import 'package:qoshni/features/business_platform/domain/business_offering_inventory.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_inventory_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_offering_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_profile_repository.dart';

export 'package:qoshni/features/business_platform/domain/repositories/business_inventory_repository.dart'
    show BusinessInventorySaveResult;

class BusinessInventoryProfileSummary {
  const BusinessInventoryProfileSummary({
    required this.configuredCount,
    required this.activeCount,
    required this.pausedCount,
    required this.offeringCount,
  });

  final int configuredCount;
  final int activeCount;
  final int pausedCount;
  final int offeringCount;
}

/// Orchestrates inventory/availability for user-owned offerings.
class BusinessInventoryController extends ChangeNotifier {
  BusinessInventoryController({
    required BusinessProfileRepository profileRepository,
    required BusinessOfferingRepository offeringRepository,
    required BusinessInventoryRepository inventoryRepository,
  })  : _profiles = profileRepository,
        _offerings = offeringRepository,
        _inventory = inventoryRepository;

  final BusinessProfileRepository _profiles;
  final BusinessOfferingRepository _offerings;
  final BusinessInventoryRepository _inventory;

  BusinessOfferingInventory? inventoryFor({
    required String businessProfileId,
    required String offeringId,
  }) {
    return _inventory.inventoryFor(
      businessProfileId: businessProfileId,
      offeringId: offeringId,
    );
  }

  List<BusinessOfferingInventory> inventoriesForProfile(
    String businessProfileId,
  ) {
    if (!_isEditableProfile(businessProfileId)) {
      return const [];
    }
    final offerings = _offerings.offeringsForProfile(businessProfileId);
    final list = <BusinessOfferingInventory>[];
    for (final offering in offerings) {
      final record = inventoryFor(
        businessProfileId: businessProfileId,
        offeringId: offering.id,
      );
      if (record != null) {
        list.add(record);
      }
    }
    return list;
  }

  BusinessInventoryProfileSummary summaryForProfile(String businessProfileId) {
    final offerings = _offerings.offeringsForProfile(businessProfileId);
    var configured = 0;
    var active = 0;
    var paused = 0;
    for (final offering in offerings) {
      final record = inventoryFor(
        businessProfileId: businessProfileId,
        offeringId: offering.id,
      );
      if (record == null) {
        continue;
      }
      configured++;
      if (record.availability == BusinessOfferingAvailabilityState.active) {
        active++;
      } else {
        paused++;
      }
    }
    return BusinessInventoryProfileSummary(
      configuredCount: configured,
      activeCount: active,
      pausedCount: paused,
      offeringCount: offerings.length,
    );
  }

  BusinessInventorySaveResult saveInventory({
    required String businessProfileId,
    required String offeringId,
    required BusinessOfferingAvailabilityState availability,
    int? totalQuantity,
    int? availableQuantity,
  }) {
    if (!_isEditableProfile(businessProfileId)) {
      return BusinessInventorySaveResult.profileNotEditable;
    }

    final result = _inventory.saveInventory(
      businessProfileId: businessProfileId,
      offeringId: offeringId,
      availability: availability,
      totalQuantity: totalQuantity,
      availableQuantity: availableQuantity,
    );
    if (result == BusinessInventorySaveResult.success) {
      notifyListeners();
    }
    return result;
  }

  void removeForOffering({
    required String businessProfileId,
    required String offeringId,
  }) {
    _inventory.removeForOffering(
      businessProfileId: businessProfileId,
      offeringId: offeringId,
    );
    notifyListeners();
  }

  void pruneOrphansForProfile(String businessProfileId) {
    _inventory.pruneOrphansForProfile(businessProfileId);
    notifyListeners();
  }

  bool _isEditableProfile(String businessProfileId) {
    final draft = _profiles.userDraftById(businessProfileId);
    return draft != null && draft.isEditable;
  }
}

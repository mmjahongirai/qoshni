import 'package:qoshni/features/business_platform/domain/business_offering_availability_state.dart';
import 'package:qoshni/features/business_platform/domain/business_offering_inventory.dart';
import 'package:qoshni/features/business_platform/domain/business_offering_kind.dart';
import 'package:qoshni/features/business_platform/domain/business_profile_offering.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_inventory_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_offering_repository.dart';

class InMemoryBusinessInventoryRepository implements BusinessInventoryRepository {
  InMemoryBusinessInventoryRepository(this._offerings);

  final BusinessOfferingRepository _offerings;

  final Map<BusinessOfferingInventoryKey, BusinessOfferingInventory> _records =
      {};

  @override
  BusinessOfferingInventory? inventoryFor({
    required String businessProfileId,
    required String offeringId,
  }) {
    if (_offerings.offeringById(
          businessProfileId: businessProfileId,
          offeringId: offeringId,
        ) ==
        null) {
      return null;
    }
    return _records[BusinessOfferingInventoryKey(
      businessProfileId: businessProfileId,
      offeringId: offeringId,
    )];
  }

  @override
  BusinessInventorySaveResult saveInventory({
    required String businessProfileId,
    required String offeringId,
    required BusinessOfferingAvailabilityState availability,
    int? totalQuantity,
    int? availableQuantity,
  }) {
    final offering = _offerings.offeringById(
      businessProfileId: businessProfileId,
      offeringId: offeringId,
    );
    if (offering == null) {
      return BusinessInventorySaveResult.offeringNotFound;
    }

    if (!_validateQuantities(
      offering: offering,
      totalQuantity: totalQuantity,
      availableQuantity: availableQuantity,
    )) {
      return BusinessInventorySaveResult.invalidQuantities;
    }

    final key = BusinessOfferingInventoryKey(
      businessProfileId: businessProfileId,
      offeringId: offeringId,
    );
    final existing = _records[key];
    final now = DateTime.now();

    _records[key] = BusinessOfferingInventory(
      businessProfileId: businessProfileId,
      offeringId: offeringId,
      availability: availability,
      totalQuantity: _storedTotal(offering.kind, totalQuantity),
      availableQuantity: _storedAvailable(offering.kind, availableQuantity),
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    );
    return BusinessInventorySaveResult.success;
  }

  @override
  void removeForOffering({
    required String businessProfileId,
    required String offeringId,
  }) {
    _records.remove(
      BusinessOfferingInventoryKey(
        businessProfileId: businessProfileId,
        offeringId: offeringId,
      ),
    );
  }

  @override
  void pruneOrphansForProfile(String businessProfileId) {
    final offeringIds = _offerings
        .offeringsForProfile(businessProfileId)
        .map((o) => o.id)
        .toSet();
    _records.removeWhere(
      (key, _) =>
          key.businessProfileId == businessProfileId &&
          !offeringIds.contains(key.offeringId),
    );
  }

  bool _validateQuantities({
    required BusinessProfileOffering offering,
    required int? totalQuantity,
    required int? availableQuantity,
  }) {
    switch (offering.kind) {
      case BusinessOfferingKind.service:
        return true;
      case BusinessOfferingKind.product:
      case BusinessOfferingKind.rental:
        if (totalQuantity == null || availableQuantity == null) {
          return false;
        }
        if (totalQuantity < 0 || availableQuantity < 0) {
          return false;
        }
        return availableQuantity <= totalQuantity;
    }
  }

  int? _storedTotal(BusinessOfferingKind kind, int? total) {
    return switch (kind) {
      BusinessOfferingKind.service => null,
      BusinessOfferingKind.product ||
      BusinessOfferingKind.rental =>
        total,
    };
  }

  int? _storedAvailable(BusinessOfferingKind kind, int? available) {
    return switch (kind) {
      BusinessOfferingKind.service => null,
      BusinessOfferingKind.product ||
      BusinessOfferingKind.rental =>
        available,
    };
  }
}

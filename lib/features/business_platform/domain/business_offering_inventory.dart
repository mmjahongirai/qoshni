import 'package:qoshni/features/business_platform/domain/business_offering_availability_state.dart';

/// Composite identity for inventory tied to a user-owned offering.
class BusinessOfferingInventoryKey {
  const BusinessOfferingInventoryKey({
    required this.businessProfileId,
    required this.offeringId,
  });

  final String businessProfileId;
  final String offeringId;

  @override
  bool operator ==(Object other) {
    return other is BusinessOfferingInventoryKey &&
        other.businessProfileId == businessProfileId &&
        other.offeringId == offeringId;
  }

  @override
  int get hashCode => Object.hash(businessProfileId, offeringId);
}

/// Local inventory/availability settings (session-only, not consumer catalog).
class BusinessOfferingInventory {
  BusinessOfferingInventory({
    required this.businessProfileId,
    required this.offeringId,
    required this.availability,
    this.totalQuantity,
    this.availableQuantity,
    required this.createdAt,
    required this.updatedAt,
  });

  final String businessProfileId;
  final String offeringId;
  final BusinessOfferingAvailabilityState availability;
  final int? totalQuantity;
  final int? availableQuantity;
  final DateTime createdAt;
  final DateTime updatedAt;

  BusinessOfferingInventoryKey get key => BusinessOfferingInventoryKey(
        businessProfileId: businessProfileId,
        offeringId: offeringId,
      );
}

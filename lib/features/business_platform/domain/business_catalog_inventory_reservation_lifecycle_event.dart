import 'package:qoshni/features/business_platform/domain/business_catalog_inventory_reservation_status.dart';

enum BusinessCatalogInventoryReservationLifecycleAction {
  reserve,
  release,
  confirm,
  expire,
}

class BusinessCatalogInventoryReservationLifecycleEvent {
  const BusinessCatalogInventoryReservationLifecycleEvent({
    required this.eventId,
    required this.reservationId,
    required this.action,
    required this.statusBefore,
    required this.statusAfter,
    required this.quantity,
    required this.recordedAt,
    required this.reason,
  });

  final String eventId;
  final String reservationId;
  final BusinessCatalogInventoryReservationLifecycleAction action;
  final BusinessCatalogInventoryReservationStatus statusBefore;
  final BusinessCatalogInventoryReservationStatus statusAfter;
  final int quantity;
  final DateTime recordedAt;
  final String reason;
}

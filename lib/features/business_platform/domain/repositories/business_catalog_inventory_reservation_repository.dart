import 'package:qoshni/features/business_platform/domain/business_catalog_inventory_reservation.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_inventory_reservation_lifecycle_event.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_inventory_reservation_reconciliation.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_inventory_reservation_status.dart';

enum BusinessCatalogInventoryReservationReserveResult {
  success,
  notFound,
  invalidQuantity,
  invalidExpiry,
  insufficientAvailable,
  itemUnavailable,
  invalidScope,
  idempotentReplay,
  failure,
}

enum BusinessCatalogInventoryReservationReleaseResult {
  success,
  notFound,
  invalidTransition,
  idempotentReplay,
  failure,
}

enum BusinessCatalogInventoryReservationConfirmResult {
  success,
  notFound,
  invalidTransition,
  expired,
  idempotentReplay,
  failure,
}

enum BusinessCatalogInventoryReservationExpireResult {
  success,
  notFound,
  invalidTransition,
  idempotentReplay,
  failure,
}

abstract class BusinessCatalogInventoryReservationRepository {
  String get businessScopeId;

  List<BusinessCatalogInventoryReservation> listForCurrentScope({
    BusinessCatalogInventoryReservationStatus? status,
    String? branchId,
    String? inventoryItemId,
  });

  BusinessCatalogInventoryReservation? findById(String reservationId);

  BusinessCatalogInventoryReservationReserveResult reserve({
    required BusinessCatalogInventoryReservationInput input,
    DateTime? now,
  });

  BusinessCatalogInventoryReservationReleaseResult release({
    required String reservationId,
    DateTime? now,
  });

  BusinessCatalogInventoryReservationConfirmResult confirm({
    required String reservationId,
    DateTime? now,
  });

  BusinessCatalogInventoryReservationExpireResult expireReservation({
    required String reservationId,
    DateTime? now,
  });

  int expireAllDueReservations({DateTime? now});

  BusinessCatalogInventoryReservationReconciliationReport reconcileReservedQuantities({
    DateTime? now,
  });

  List<BusinessCatalogInventoryReservationLifecycleEvent> lifecycleHistory(
    String reservationId,
  );
}

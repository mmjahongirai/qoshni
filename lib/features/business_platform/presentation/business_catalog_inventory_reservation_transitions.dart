import 'package:qoshni/features/business_platform/domain/business_catalog_inventory_reservation.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_inventory_reservation_status.dart';

bool catalogReservationCanRelease(
  BusinessCatalogInventoryReservation reservation,
) {
  return reservation.status == BusinessCatalogInventoryReservationStatus.reserved ||
      reservation.status == BusinessCatalogInventoryReservationStatus.released;
}

bool catalogReservationCanConfirm(
  BusinessCatalogInventoryReservation reservation,
  DateTime now,
) {
  if (reservation.status == BusinessCatalogInventoryReservationStatus.confirmed) {
    return true;
  }
  if (reservation.status != BusinessCatalogInventoryReservationStatus.reserved) {
    return false;
  }
  return reservation.expiresAt.isAfter(now);
}

bool catalogReservationCanExpire(
  BusinessCatalogInventoryReservation reservation,
  DateTime now,
) {
  if (reservation.status == BusinessCatalogInventoryReservationStatus.expired) {
    return true;
  }
  if (reservation.status != BusinessCatalogInventoryReservationStatus.reserved) {
    return false;
  }
  return !reservation.expiresAt.isAfter(now);
}

bool catalogReservationIsExpiredByTime(
  BusinessCatalogInventoryReservation reservation,
  DateTime now,
) {
  return reservation.status == BusinessCatalogInventoryReservationStatus.reserved &&
      !reservation.expiresAt.isAfter(now);
}

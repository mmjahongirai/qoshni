import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_inventory_reservation_status.dart';

extension BusinessCatalogInventoryReservationStatusLabels
    on BusinessCatalogInventoryReservationStatus {
  String label(AppLocalizations l10n) {
    switch (this) {
      case BusinessCatalogInventoryReservationStatus.reserved:
        return l10n.catalogInventoryReservationStatusReserved;
      case BusinessCatalogInventoryReservationStatus.confirmed:
        return l10n.catalogInventoryReservationStatusConfirmed;
      case BusinessCatalogInventoryReservationStatus.released:
        return l10n.catalogInventoryReservationStatusReleased;
      case BusinessCatalogInventoryReservationStatus.expired:
        return l10n.catalogInventoryReservationStatusExpired;
    }
  }
}

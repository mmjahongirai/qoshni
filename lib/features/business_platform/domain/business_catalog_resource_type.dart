import 'package:qoshni/core/localization/generated/app_localizations.dart';

enum BusinessCatalogResourceType {
  equipment,
  staff,
  serviceCapacity;

  String label(AppLocalizations l10n) {
    switch (this) {
      case BusinessCatalogResourceType.equipment:
        return l10n.catalogResourceTypeEquipment;
      case BusinessCatalogResourceType.staff:
        return l10n.catalogResourceTypeStaff;
      case BusinessCatalogResourceType.serviceCapacity:
        return l10n.catalogResourceTypeServiceCapacity;
    }
  }
}

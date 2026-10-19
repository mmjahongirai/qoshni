import 'package:qoshni/core/localization/generated/app_localizations.dart';

enum BusinessCatalogResourceStatus {
  active,
  manuallyUnavailable,
  archived;

  bool get isArchived => this == BusinessCatalogResourceStatus.archived;

  String label(AppLocalizations l10n) {
    switch (this) {
      case BusinessCatalogResourceStatus.active:
        return l10n.catalogResourceStatusActive;
      case BusinessCatalogResourceStatus.manuallyUnavailable:
        return l10n.catalogResourceStatusUnavailable;
      case BusinessCatalogResourceStatus.archived:
        return l10n.catalogResourceStatusArchived;
    }
  }
}

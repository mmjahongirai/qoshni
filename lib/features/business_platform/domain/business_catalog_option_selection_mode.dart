import 'package:qoshni/core/localization/generated/app_localizations.dart';

enum BusinessCatalogOptionSelectionMode {
  single,
  multiple;

  String label(AppLocalizations l10n) {
    switch (this) {
      case BusinessCatalogOptionSelectionMode.single:
        return l10n.catalogOptionSelectionSingle;
      case BusinessCatalogOptionSelectionMode.multiple:
        return l10n.catalogOptionSelectionMultiple;
    }
  }
}

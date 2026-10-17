import 'package:qoshni/core/localization/generated/app_localizations.dart';

enum BusinessCatalogAttributeValueKind {
  text,
  number,
  choice;

  String label(AppLocalizations l10n) {
    switch (this) {
      case BusinessCatalogAttributeValueKind.text:
        return l10n.catalogAttributeValueKindText;
      case BusinessCatalogAttributeValueKind.number:
        return l10n.catalogAttributeValueKindNumber;
      case BusinessCatalogAttributeValueKind.choice:
        return l10n.catalogAttributeValueKindChoice;
    }
  }
}

import 'package:qoshni/core/localization/generated/app_localizations.dart';

enum BusinessCatalogCategoryStatus {
  active,
  draft,
  archived,
}

extension BusinessCatalogCategoryStatusLabels on BusinessCatalogCategoryStatus {
  String label(AppLocalizations l10n) {
    return switch (this) {
      BusinessCatalogCategoryStatus.active => l10n.catalogCategoryStatusActive,
      BusinessCatalogCategoryStatus.draft => l10n.catalogCategoryStatusDraft,
      BusinessCatalogCategoryStatus.archived => l10n.catalogCategoryStatusArchived,
    };
  }
}

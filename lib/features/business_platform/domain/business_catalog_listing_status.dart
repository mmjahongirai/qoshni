import 'package:qoshni/core/localization/generated/app_localizations.dart';

/// Publication status for business catalog products and services (preview scope).
enum BusinessCatalogListingStatus {
  draft,
  active,
  archived,
}

extension BusinessCatalogListingStatusLabels on BusinessCatalogListingStatus {
  String label(AppLocalizations l10n) {
    return switch (this) {
      BusinessCatalogListingStatus.draft => l10n.catalogListingStatusDraft,
      BusinessCatalogListingStatus.active => l10n.catalogListingStatusActive,
      BusinessCatalogListingStatus.archived => l10n.catalogListingStatusArchived,
    };
  }
}

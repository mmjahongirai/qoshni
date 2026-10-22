import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_price_status.dart';

extension BusinessCatalogPriceStatusLabels on BusinessCatalogPriceStatus {
  String label(AppLocalizations l10n) {
    switch (this) {
      case BusinessCatalogPriceStatus.draft:
        return l10n.catalogPricingStatusDraft;
      case BusinessCatalogPriceStatus.active:
        return l10n.catalogPricingStatusActive;
      case BusinessCatalogPriceStatus.archived:
        return l10n.catalogPricingStatusArchived;
    }
  }
}

import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_discount_target_scope.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_discount_type.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_price_status.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_price_status_labels.dart';

extension BusinessCatalogDiscountTargetScopeLabels
    on BusinessCatalogDiscountTargetScope {
  String label(AppLocalizations l10n) {
    switch (this) {
      case BusinessCatalogDiscountTargetScope.businessWide:
        return l10n.catalogDiscountScopeBusinessWide;
      case BusinessCatalogDiscountTargetScope.product:
        return l10n.catalogDiscountScopeProduct;
      case BusinessCatalogDiscountTargetScope.service:
        return l10n.catalogDiscountScopeService;
    }
  }
}

extension BusinessCatalogDiscountTypeLabels on BusinessCatalogDiscountType {
  String label(AppLocalizations l10n) {
    switch (this) {
      case BusinessCatalogDiscountType.percentage:
        return l10n.catalogDiscountTypePercentage;
      case BusinessCatalogDiscountType.fixedAmount:
        return l10n.catalogDiscountTypeFixed;
    }
  }
}

extension BusinessCatalogDiscountStatusLabels on BusinessCatalogPriceStatus {
  String discountStatusLabel(AppLocalizations l10n) => label(l10n);
}

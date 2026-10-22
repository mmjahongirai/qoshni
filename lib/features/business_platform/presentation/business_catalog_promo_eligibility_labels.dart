import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_promo_eligibility.dart';

extension CatalogPromoCodeEligibilityLabels on CatalogPromoCodeEligibilityStatus {
  String label(AppLocalizations l10n) {
    switch (this) {
      case CatalogPromoCodeEligibilityStatus.eligible:
        return l10n.catalogPromoEligibilityEligible;
      case CatalogPromoCodeEligibilityStatus.invalidCode:
        return l10n.catalogPromoEligibilityInvalidCode;
      case CatalogPromoCodeEligibilityStatus.inactive:
        return l10n.catalogPromoEligibilityInactive;
      case CatalogPromoCodeEligibilityStatus.notYetValid:
        return l10n.catalogPromoEligibilityNotYetValid;
      case CatalogPromoCodeEligibilityStatus.expired:
        return l10n.catalogPromoEligibilityExpired;
      case CatalogPromoCodeEligibilityStatus.scopeMismatch:
        return l10n.catalogPromoEligibilityScopeMismatch;
      case CatalogPromoCodeEligibilityStatus.discountRuleUnavailable:
        return l10n.catalogPromoEligibilityDiscountUnavailable;
      case CatalogPromoCodeEligibilityStatus.minimumBasketNotMet:
        return l10n.catalogPromoEligibilityMinimumBasket;
      case CatalogPromoCodeEligibilityStatus.totalUsageLimitReached:
        return l10n.catalogPromoEligibilityTotalLimit;
      case CatalogPromoCodeEligibilityStatus.customerUsageLimitReached:
        return l10n.catalogPromoEligibilityCustomerLimit;
      case CatalogPromoCodeEligibilityStatus.noApplicableDiscount:
        return l10n.catalogPromoEligibilityNoApplicableDiscount;
      case CatalogPromoCodeEligibilityStatus.basePriceRequired:
        return l10n.catalogPromoEligibilityBasePriceRequired;
    }
  }
}

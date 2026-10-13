import 'package:qoshni/core/localization/generated/app_localizations.dart';

/// Stable category identifiers for routing and filtering (not localized).
enum ServiceCategoryId {
  groceries,
  restaurants,
  pharmacy,
  shops,
  masters,
  rent,
}

ServiceCategoryId? tryParseServiceCategoryId(String? raw) {
  if (raw == null || raw.isEmpty) {
    return null;
  }
  for (final id in ServiceCategoryId.values) {
    if (id.name == raw) {
      return id;
    }
  }
  return null;
}

String serviceCategoryLabel(ServiceCategoryId id, AppLocalizations l10n) {
  return switch (id) {
    ServiceCategoryId.groceries => l10n.categoryGroceries,
    ServiceCategoryId.restaurants => l10n.categoryRestaurants,
    ServiceCategoryId.pharmacy => l10n.categoryPharmacy,
    ServiceCategoryId.shops => l10n.categoryShops,
    ServiceCategoryId.masters => l10n.categoryMasters,
    ServiceCategoryId.rent => l10n.categoryRent,
  };
}

String businessListingSubtitle(
  ServiceCategoryId categoryId,
  String distanceLabel,
  AppLocalizations l10n,
) {
  return '${serviceCategoryLabel(categoryId, l10n)} • $distanceLabel';
}

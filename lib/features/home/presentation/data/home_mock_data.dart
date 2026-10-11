import 'package:flutter/material.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';

class HomeServiceCategoryItem {
  const HomeServiceCategoryItem({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;
}

class NearbyBusinessItem {
  const NearbyBusinessItem({
    required this.name,
    required this.subtitle,
    required this.icon,
    required this.accent,
  });

  final String name;
  final String subtitle;
  final IconData icon;
  final Color accent;
}

List<HomeServiceCategoryItem> buildServiceCategories(AppLocalizations l10n) {
  return [
    HomeServiceCategoryItem(
      icon: Icons.shopping_basket_outlined,
      label: l10n.categoryGroceries,
    ),
    HomeServiceCategoryItem(
      icon: Icons.restaurant_outlined,
      label: l10n.categoryRestaurants,
    ),
    HomeServiceCategoryItem(
      icon: Icons.local_pharmacy_outlined,
      label: l10n.categoryPharmacy,
    ),
    HomeServiceCategoryItem(
      icon: Icons.storefront_outlined,
      label: l10n.categoryShops,
    ),
    HomeServiceCategoryItem(
      icon: Icons.handyman_outlined,
      label: l10n.categoryMasters,
    ),
    HomeServiceCategoryItem(
      icon: Icons.key_outlined,
      label: l10n.categoryRent,
    ),
  ];
}

List<NearbyBusinessItem> buildNearbyBusinesses(
  AppLocalizations l10n,
  ColorScheme colorScheme,
) {
  return [
    NearbyBusinessItem(
      name: l10n.nearbyMock1Name,
      subtitle: l10n.nearbyMock1Subtitle,
      icon: Icons.store_mall_directory_outlined,
      accent: colorScheme.primary,
    ),
    NearbyBusinessItem(
      name: l10n.nearbyMock2Name,
      subtitle: l10n.nearbyMock2Subtitle,
      icon: Icons.local_cafe_outlined,
      accent: colorScheme.tertiary,
    ),
    NearbyBusinessItem(
      name: l10n.nearbyMock3Name,
      subtitle: l10n.nearbyMock3Subtitle,
      icon: Icons.medical_services_outlined,
      accent: colorScheme.secondary,
    ),
  ];
}

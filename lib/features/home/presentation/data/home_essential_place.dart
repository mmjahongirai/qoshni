import 'package:flutter/material.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/features/home/presentation/data/service_category_id.dart';

/// Place-type shortcuts for the home screen (not verified chain/branch data).
enum HomeEssentialPlaceKind {
  supermarkets,
  pharmacies,
  hospitals,
  restaurants,
}

class HomeEssentialPlaceItem {
  const HomeEssentialPlaceItem({
    required this.kind,
    required this.icon,
    required this.accent,
    required this.title,
    required this.subtitle,
    this.categoryId,
  });

  final HomeEssentialPlaceKind kind;
  final IconData icon;
  final Color accent;
  final String title;
  final String subtitle;

  /// When set, opens category listing with this filter.
  final ServiceCategoryId? categoryId;
}

List<HomeEssentialPlaceItem> buildHomeEssentialPlaces(
  AppLocalizations l10n,
  ColorScheme colorScheme,
) {
  return [
    HomeEssentialPlaceItem(
      kind: HomeEssentialPlaceKind.supermarkets,
      icon: Icons.shopping_cart_outlined,
      accent: colorScheme.primary,
      title: l10n.homeEssentialSupermarkets,
      subtitle: l10n.homeEssentialPlaceTypeHint,
      categoryId: ServiceCategoryId.groceries,
    ),
    HomeEssentialPlaceItem(
      kind: HomeEssentialPlaceKind.pharmacies,
      icon: Icons.local_pharmacy_outlined,
      accent: colorScheme.tertiary,
      title: l10n.homeEssentialPharmacies,
      subtitle: l10n.homeEssentialPlaceTypeHint,
      categoryId: ServiceCategoryId.pharmacy,
    ),
    HomeEssentialPlaceItem(
      kind: HomeEssentialPlaceKind.hospitals,
      icon: Icons.local_hospital_outlined,
      accent: colorScheme.error,
      title: l10n.homeEssentialHospitals,
      subtitle: l10n.homeEssentialPlaceTypeHint,
    ),
    HomeEssentialPlaceItem(
      kind: HomeEssentialPlaceKind.restaurants,
      icon: Icons.restaurant_outlined,
      accent: colorScheme.secondary,
      title: l10n.homeEssentialRestaurants,
      subtitle: l10n.homeEssentialPlaceTypeHint,
      categoryId: ServiceCategoryId.restaurants,
    ),
  ];
}

/// Decorative map legend entries (not GPS coordinates).
List<({IconData icon, String label, Color accent})> buildHomeMapLegendEntries(
  AppLocalizations l10n,
  ColorScheme colorScheme,
) {
  return [
    (
      icon: Icons.shopping_basket_outlined,
      label: l10n.homeMapLegendMarkets,
      accent: colorScheme.primary,
    ),
    (
      icon: Icons.local_pharmacy_outlined,
      label: l10n.homeMapLegendPharmacy,
      accent: colorScheme.tertiary,
    ),
    (
      icon: Icons.local_hospital_outlined,
      label: l10n.homeMapLegendHealth,
      accent: colorScheme.error,
    ),
    (
      icon: Icons.restaurant_outlined,
      label: l10n.homeMapLegendFood,
      accent: colorScheme.secondary,
    ),
  ];
}

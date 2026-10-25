import 'package:flutter/material.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/features/home/presentation/data/mock_business_id.dart';
import 'package:qoshni/features/home/presentation/data/service_category_id.dart';

class HomeServiceCategoryItem {
  const HomeServiceCategoryItem({
    required this.id,
    required this.icon,
    required this.label,
  });

  final ServiceCategoryId id;
  final IconData icon;
  final String label;
}

class NearbyBusinessItem {
  const NearbyBusinessItem({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.distanceLabel,
    required this.subtitle,
    required this.icon,
    required this.accent,
    this.description,
    this.address,
    this.hours,
  });

  final MockBusinessId id;
  final ServiceCategoryId categoryId;
  final String name;
  final String distanceLabel;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final String? description;
  final String? address;
  final String? hours;
}

enum SearchEntryKind { category, business }

class SearchCatalogEntry {
  const SearchCatalogEntry({
    required this.kind,
    required this.title,
    required this.subtitle,
    required this.categoryLabel,
    required this.icon,
    required this.accent,
    this.businessId,
    this.categoryId,
  });

  final SearchEntryKind kind;
  final String title;
  final String subtitle;
  final String categoryLabel;
  final IconData icon;
  final Color accent;
  final MockBusinessId? businessId;
  final ServiceCategoryId? categoryId;
}

List<HomeServiceCategoryItem> buildServiceCategories(AppLocalizations l10n) {
  return [
    HomeServiceCategoryItem(
      id: ServiceCategoryId.groceries,
      icon: Icons.shopping_basket_outlined,
      label: l10n.categoryGroceries,
    ),
    HomeServiceCategoryItem(
      id: ServiceCategoryId.restaurants,
      icon: Icons.restaurant_outlined,
      label: l10n.categoryRestaurants,
    ),
    HomeServiceCategoryItem(
      id: ServiceCategoryId.pharmacy,
      icon: Icons.local_pharmacy_outlined,
      label: l10n.categoryPharmacy,
    ),
    HomeServiceCategoryItem(
      id: ServiceCategoryId.shops,
      icon: Icons.storefront_outlined,
      label: l10n.categoryShops,
    ),
    HomeServiceCategoryItem(
      id: ServiceCategoryId.masters,
      icon: Icons.handyman_outlined,
      label: l10n.categoryMasters,
    ),
    HomeServiceCategoryItem(
      id: ServiceCategoryId.rent,
      icon: Icons.key_outlined,
      label: l10n.categoryRent,
    ),
  ];
}

List<NearbyBusinessItem> buildNearbyBusinesses(
  AppLocalizations l10n,
  ColorScheme colorScheme,
) {
  return buildAllMockBusinesses(l10n, colorScheme).take(3).toList(growable: false);
}

List<NearbyBusinessItem> buildAllMockBusinesses(
  AppLocalizations l10n,
  ColorScheme colorScheme,
) {
  return [
    _mockBusiness(
      l10n: l10n,
      id: MockBusinessId.barakaMarket,
      categoryId: ServiceCategoryId.groceries,
      name: l10n.nearbyMock1Name,
      distanceLabel: l10n.nearbyMock1Distance,
      description: l10n.nearbyMock1Description,
      address: l10n.nearbyMock1Address,
      hours: l10n.nearbyMock1Hours,
      icon: Icons.store_mall_directory_outlined,
      accent: colorScheme.primary,
    ),
    _mockBusiness(
      l10n: l10n,
      id: MockBusinessId.samarkandCafe,
      categoryId: ServiceCategoryId.restaurants,
      name: l10n.nearbyMock2Name,
      distanceLabel: l10n.nearbyMock2Distance,
      description: l10n.nearbyMock2Description,
      address: l10n.nearbyMock2Address,
      hours: l10n.nearbyMock2Hours,
      icon: Icons.local_cafe_outlined,
      accent: colorScheme.tertiary,
    ),
    _mockBusiness(
      l10n: l10n,
      id: MockBusinessId.shifoPlus,
      categoryId: ServiceCategoryId.pharmacy,
      name: l10n.nearbyMock3Name,
      distanceLabel: l10n.nearbyMock3Distance,
      description: l10n.nearbyMock3Description,
      address: l10n.nearbyMock3Address,
      hours: l10n.nearbyMock3Hours,
      icon: Icons.medical_services_outlined,
      accent: colorScheme.secondary,
    ),
    _mockBusiness(
      l10n: l10n,
      id: MockBusinessId.sampleTechCorner,
      categoryId: ServiceCategoryId.shops,
      name: l10n.listingMockShop1Name,
      distanceLabel: l10n.listingMockShop1Distance,
      description: l10n.listingMockShop1Description,
      address: l10n.listingMockShop1Address,
      hours: l10n.listingMockShop1Hours,
      icon: Icons.shopping_bag_outlined,
      accent: colorScheme.primary,
    ),
    _mockBusiness(
      l10n: l10n,
      id: MockBusinessId.sampleStyleShop,
      categoryId: ServiceCategoryId.shops,
      name: l10n.listingMockShop2Name,
      distanceLabel: l10n.listingMockShop2Distance,
      description: l10n.listingMockShop2Description,
      address: l10n.listingMockShop2Address,
      hours: l10n.listingMockShop2Hours,
      icon: Icons.checkroom_outlined,
      accent: colorScheme.tertiary,
    ),
    _mockBusiness(
      l10n: l10n,
      id: MockBusinessId.samplePipeFix,
      categoryId: ServiceCategoryId.masters,
      name: l10n.listingMockMaster1Name,
      distanceLabel: l10n.listingMockMaster1Distance,
      description: l10n.listingMockMaster1Description,
      address: l10n.listingMockMaster1Address,
      hours: l10n.listingMockMaster1Hours,
      icon: Icons.plumbing_outlined,
      accent: colorScheme.secondary,
    ),
    _mockBusiness(
      l10n: l10n,
      id: MockBusinessId.sampleElectricHelp,
      categoryId: ServiceCategoryId.masters,
      name: l10n.listingMockMaster2Name,
      distanceLabel: l10n.listingMockMaster2Distance,
      description: l10n.listingMockMaster2Description,
      address: l10n.listingMockMaster2Address,
      hours: l10n.listingMockMaster2Hours,
      icon: Icons.electrical_services_outlined,
      accent: colorScheme.primary,
    ),
    _mockBusiness(
      l10n: l10n,
      id: MockBusinessId.sampleApartmentHub,
      categoryId: ServiceCategoryId.rent,
      name: l10n.listingMockRent1Name,
      distanceLabel: l10n.listingMockRent1Distance,
      description: l10n.listingMockRent1Description,
      address: l10n.listingMockRent1Address,
      hours: l10n.listingMockRent1Hours,
      icon: Icons.apartment_outlined,
      accent: colorScheme.tertiary,
    ),
    _mockBusiness(
      l10n: l10n,
      id: MockBusinessId.sampleCarRent,
      categoryId: ServiceCategoryId.rent,
      name: l10n.listingMockRent2Name,
      distanceLabel: l10n.listingMockRent2Distance,
      description: l10n.listingMockRent2Description,
      address: l10n.listingMockRent2Address,
      hours: l10n.listingMockRent2Hours,
      icon: Icons.directions_car_filled_outlined,
      accent: colorScheme.secondary,
    ),
  ];
}

NearbyBusinessItem _mockBusiness({
  required AppLocalizations l10n,
  required MockBusinessId id,
  required ServiceCategoryId categoryId,
  required String name,
  required String distanceLabel,
  required String description,
  required String address,
  required String hours,
  required IconData icon,
  required Color accent,
}) {
  return NearbyBusinessItem(
    id: id,
    categoryId: categoryId,
    name: name,
    distanceLabel: distanceLabel,
    subtitle: businessListingSubtitle(categoryId, distanceLabel, l10n),
    description: description,
    address: address,
    hours: hours,
    icon: icon,
    accent: accent,
  );
}

NearbyBusinessItem? findMockBusinessById(
  AppLocalizations l10n,
  ColorScheme colorScheme,
  MockBusinessId businessId,
) {
  for (final business in buildAllMockBusinesses(l10n, colorScheme)) {
    if (business.id == businessId) {
      return business;
    }
  }
  return null;
}

List<NearbyBusinessItem> filterMockBusinessesByCategory(
  List<NearbyBusinessItem> businesses,
  ServiceCategoryId categoryId,
) {
  return businesses
      .where((business) => business.categoryId == categoryId)
      .toList(growable: false);
}

SearchCatalogEntry searchCatalogEntryFromBusiness(
  NearbyBusinessItem business,
  AppLocalizations l10n,
) {
  return SearchCatalogEntry(
    kind: SearchEntryKind.business,
    title: business.name,
    subtitle: business.subtitle,
    categoryLabel: serviceCategoryLabel(business.categoryId, l10n),
    icon: business.icon,
    accent: business.accent,
    categoryId: business.categoryId,
    businessId: business.id,
  );
}

List<SearchCatalogEntry> buildSearchCatalog(
  AppLocalizations l10n,
  ColorScheme colorScheme,
) {
  final categories = buildServiceCategories(l10n);
  final businesses = buildAllMockBusinesses(l10n, colorScheme);

  return [
    ...categories.map(
      (category) => SearchCatalogEntry(
        kind: SearchEntryKind.category,
        title: category.label,
        subtitle: l10n.searchCategoryEntrySubtitle,
        categoryLabel: category.label,
        icon: category.icon,
        accent: colorScheme.primary,
        categoryId: category.id,
      ),
    ),
    ...businesses.map(
      (business) => searchCatalogEntryFromBusiness(business, l10n),
    ),
  ];
}

/// Legacy substring filter — prefer Phase 16 catalog matcher with query understanding.
List<SearchCatalogEntry> filterSearchCatalog(
  List<SearchCatalogEntry> catalog,
  String query,
) {
  final normalizedQuery = query.trim().toLowerCase();
  if (normalizedQuery.isEmpty) {
    return const [];
  }

  return catalog.where((entry) {
    final haystack = [
      entry.title,
      entry.categoryLabel,
      entry.subtitle,
    ].join(' ').toLowerCase();

    return haystack.contains(normalizedQuery);
  }).toList(growable: false);
}

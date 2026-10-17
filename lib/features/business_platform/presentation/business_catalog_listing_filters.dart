import 'package:flutter/material.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/theme/app_tokens.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_category.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_listing_status.dart';

BusinessCatalogListingStatus? parseCatalogListingStatus(String? raw) {
  if (raw == null || raw.isEmpty) {
    return null;
  }
  for (final s in BusinessCatalogListingStatus.values) {
    if (s.name == raw) {
      return s;
    }
  }
  return null;
}

bool catalogListingFiltersActive({
  required String query,
  required String? categoryFilter,
  required BusinessCatalogListingStatus? statusFilter,
}) {
  return query.trim().isNotEmpty ||
      (categoryFilter != null && categoryFilter.isNotEmpty) ||
      statusFilter != null;
}

List<T> filterCatalogListings<T>({
  required List<T> all,
  required String? categoryFilter,
  required BusinessCatalogListingStatus? statusFilter,
  required String query,
  required AppLocalizations l10n,
  required String Function(T item) categoryIdFor,
  required BusinessCatalogListingStatus Function(T item) statusFor,
  required String Function(T item) displayNameFor,
}) {
  var result = all;
  if (categoryFilter != null && categoryFilter.isNotEmpty) {
    result = result
        .where((item) => categoryIdFor(item) == categoryFilter)
        .toList(growable: false);
  }
  if (statusFilter != null) {
    result = result
        .where((item) => statusFor(item) == statusFilter)
        .toList(growable: false);
  }
  final q = query.trim().toLowerCase();
  if (q.isNotEmpty) {
    result = result
        .where((item) => displayNameFor(item).toLowerCase().contains(q))
        .toList(growable: false);
  }
  return result;
}

class CatalogListingFiltersPanel extends StatelessWidget {
  const CatalogListingFiltersPanel({
    required this.l10n,
    required this.searchController,
    required this.categories,
    required this.categoryFilter,
    required this.statusFilter,
    required this.filteredCount,
    required this.totalCount,
    required this.onCategoryChanged,
    required this.onStatusChanged,
    required this.onClearFilters,
    super.key,
  });

  final AppLocalizations l10n;
  final TextEditingController searchController;
  final List<BusinessCatalogCategory> categories;
  final String? categoryFilter;
  final BusinessCatalogListingStatus? statusFilter;
  final int filteredCount;
  final int totalCount;
  final ValueChanged<String?> onCategoryChanged;
  final ValueChanged<BusinessCatalogListingStatus?> onStatusChanged;
  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    final active = catalogListingFiltersActive(
      query: searchController.text,
      categoryFilter: categoryFilter,
      statusFilter: statusFilter,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: searchController,
          decoration: InputDecoration(
            labelText: l10n.catalogListingSearchLabel,
            prefixIcon: const Icon(Icons.search),
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        DropdownButtonFormField<String?>(
          value: categoryFilter,
          decoration: InputDecoration(
            labelText: l10n.catalogListingCategoryFilter,
            border: const OutlineInputBorder(),
          ),
          items: [
            DropdownMenuItem<String?>(
              value: null,
              child: Text(l10n.catalogListingAllCategories),
            ),
            ...categories.map(
              (c) => DropdownMenuItem<String?>(
                value: c.categoryId,
                child: Text(c.displayName(l10n)),
              ),
            ),
          ],
          onChanged: onCategoryChanged,
        ),
        const SizedBox(height: AppSpacing.sm),
        DropdownButtonFormField<BusinessCatalogListingStatus?>(
          value: statusFilter,
          decoration: InputDecoration(
            labelText: l10n.catalogListingStatusFilter,
            border: const OutlineInputBorder(),
          ),
          items: [
            DropdownMenuItem<BusinessCatalogListingStatus?>(
              value: null,
              child: Text(l10n.catalogListingAllStatuses),
            ),
            ...BusinessCatalogListingStatus.values.map(
              (s) => DropdownMenuItem(
                value: s,
                child: Text(s.label(l10n)),
              ),
            ),
          ],
          onChanged: onStatusChanged,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          l10n.catalogListingFilteredCount(filteredCount, totalCount),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        if (active) ...[
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: onClearFilters,
              icon: const Icon(Icons.filter_alt_off_outlined),
              label: Text(l10n.catalogListingClearFilters),
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.md),
      ],
    );
  }
}

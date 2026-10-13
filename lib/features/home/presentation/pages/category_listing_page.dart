import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/responsive/responsive_layout.dart';
import 'package:qoshni/features/home/presentation/data/home_mock_data.dart';
import 'package:qoshni/features/home/presentation/data/service_category_id.dart';
import 'package:qoshni/features/home/presentation/widgets/search_result_tile.dart';

class CategoryListingPage extends StatelessWidget {
  const CategoryListingPage({
    required this.categoryId,
    super.key,
  });

  final ServiceCategoryId? categoryId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final id = categoryId;

    final title = id == null
        ? l10n.categoryListingUnknownTitle
        : serviceCategoryLabel(id, l10n);
    final listings = id == null
        ? const <NearbyBusinessItem>[]
        : filterMockBusinessesByCategory(
            buildAllMockBusinesses(l10n, colorScheme),
            id,
          );

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(title),
      ),
      body: SafeArea(
        child: ResponsiveLayout(
          phone: _CategoryListingBody(
            maxWidth: 520,
            l10n: l10n,
            listings: listings,
            showUnknownCategory: id == null,
          ),
          tablet: _CategoryListingBody(
            maxWidth: 760,
            l10n: l10n,
            listings: listings,
            showUnknownCategory: id == null,
          ),
        ),
      ),
    );
  }
}

class _CategoryListingBody extends StatelessWidget {
  const _CategoryListingBody({
    required this.maxWidth,
    required this.l10n,
    required this.listings,
    required this.showUnknownCategory,
  });

  final double maxWidth;
  final AppLocalizations l10n;
  final List<NearbyBusinessItem> listings;
  final bool showUnknownCategory;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: responsivePagePadding(context),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: listings.isEmpty
              ? _CategoryListingEmptyState(
                  title: showUnknownCategory
                      ? l10n.categoryListingUnknownTitle
                      : l10n.categoryListingEmptyTitle,
                  body: showUnknownCategory
                      ? l10n.categoryListingUnknownBody
                      : l10n.categoryListingEmptyBody,
                )
              : ListView.separated(
                  itemCount: listings.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final entry = searchCatalogEntryFromBusiness(
                      listings[index],
                      l10n,
                    );
                    return SearchResultTile(entry: entry);
                  },
                ),
        ),
      ),
    );
  }
}

class _CategoryListingEmptyState extends StatelessWidget {
  const _CategoryListingEmptyState({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.storefront_outlined,
              size: 48,
              color: colorScheme.primary,
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              body,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.35,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

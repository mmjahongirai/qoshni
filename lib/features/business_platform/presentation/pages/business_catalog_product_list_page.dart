import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/responsive/responsive_layout.dart';
import 'package:qoshni/core/theme/app_tokens.dart';
import 'package:qoshni/core/widgets/app_message_banner.dart';
import 'package:qoshni/core/widgets/app_surface_card.dart';
import 'package:qoshni/core/widgets/demo_content_badge.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_category.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_listing_status.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_product.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_category_controller.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_listing_filters.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_product_controller.dart';
import 'package:qoshni/routing/route_paths.dart';

class BusinessCatalogProductListPage extends StatefulWidget {
  const BusinessCatalogProductListPage({
    this.initialCategoryId,
    this.initialStatus,
    super.key,
  });

  final String? initialCategoryId;
  final String? initialStatus;

  @override
  State<BusinessCatalogProductListPage> createState() =>
      _BusinessCatalogProductListPageState();
}

class _BusinessCatalogProductListPageState
    extends State<BusinessCatalogProductListPage> {
  late String? _categoryFilter;
  BusinessCatalogListingStatus? _statusFilter;
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _categoryFilter = widget.initialCategoryId?.trim();
    _statusFilter = parseCatalogListingStatus(widget.initialStatus);
    _searchController = TextEditingController();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearFilters() {
    setState(() {
      _categoryFilter = null;
      _statusFilter = null;
      _searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final productController = getIt<BusinessCatalogProductController>();
    final categoryController = getIt<BusinessCatalogCategoryController>();

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(l10n.catalogProductListTitle),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(RoutePaths.businessCatalogProductCreate),
        icon: const Icon(Icons.add),
        label: Text(l10n.catalogProductAddAction),
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: Listenable.merge([productController, categoryController]),
          builder: (context, _) {
            final all = productController.products;
            final filtered = filterCatalogListings<BusinessCatalogProduct>(
              all: all,
              categoryFilter: _categoryFilter,
              statusFilter: _statusFilter,
              query: _searchController.text,
              l10n: l10n,
              categoryIdFor: (p) => p.categoryId,
              statusFor: (p) => p.status,
              displayNameFor: (p) => p.displayName(l10n),
            );
            return ResponsiveLayout(
              phone: _ProductListBody(
                maxWidth: 520,
                l10n: l10n,
                products: filtered,
                allCount: all.length,
                categories: categoryController.categories,
                searchController: _searchController,
                categoryFilter: _categoryFilter,
                statusFilter: _statusFilter,
                onCategoryChanged: (v) => setState(() => _categoryFilter = v),
                onStatusChanged: (v) => setState(() => _statusFilter = v),
                onClearFilters: _clearFilters,
              ),
              tablet: _ProductListBody(
                maxWidth: 760,
                l10n: l10n,
                products: filtered,
                allCount: all.length,
                categories: categoryController.categories,
                searchController: _searchController,
                categoryFilter: _categoryFilter,
                statusFilter: _statusFilter,
                onCategoryChanged: (v) => setState(() => _categoryFilter = v),
                onStatusChanged: (v) => setState(() => _statusFilter = v),
                onClearFilters: _clearFilters,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ProductListBody extends StatelessWidget {
  const _ProductListBody({
    required this.maxWidth,
    required this.l10n,
    required this.products,
    required this.allCount,
    required this.categories,
    required this.searchController,
    required this.categoryFilter,
    required this.statusFilter,
    required this.onCategoryChanged,
    required this.onStatusChanged,
    required this.onClearFilters,
  });

  final double maxWidth;
  final AppLocalizations l10n;
  final List<BusinessCatalogProduct> products;
  final int allCount;
  final List<BusinessCatalogCategory> categories;
  final TextEditingController searchController;
  final String? categoryFilter;
  final BusinessCatalogListingStatus? statusFilter;
  final ValueChanged<String?> onCategoryChanged;
  final ValueChanged<BusinessCatalogListingStatus?> onStatusChanged;
  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final categoryController = getIt<BusinessCatalogCategoryController>();

    return Align(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        padding: responsivePagePadding(context),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppMessageBanner(
                message: l10n.catalogPreviewNotice,
                icon: Icons.info_outline,
                tone: AppMessageTone.info,
              ),
              const SizedBox(height: AppSpacing.md),
              CatalogListingFiltersPanel(
                l10n: l10n,
                searchController: searchController,
                categories: categories,
                categoryFilter: categoryFilter,
                statusFilter: statusFilter,
                filteredCount: products.length,
                totalCount: allCount,
                onCategoryChanged: onCategoryChanged,
                onStatusChanged: onStatusChanged,
                onClearFilters: onClearFilters,
              ),
              if (products.isEmpty)
                AppSurfaceCard(
                  child: Text(
                    l10n.catalogProductEmptyBody,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              else
                ...products.map((product) {
                  final category =
                      categoryController.categoryById(product.categoryId);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: AppSurfaceCard(
                      onTap: () => context.push(
                        RoutePaths.businessCatalogProductDetailPath(
                          product.productId,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.displayName(l10n),
                                  style: textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  product.status.label(l10n),
                                  style: textTheme.bodySmall?.copyWith(
                                    color: colorScheme.primary,
                                  ),
                                ),
                                if (category != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    category.displayName(l10n),
                                    style: textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          if (product.isDemoSeed) const DemoContentBadge(),
                          Icon(
                            Icons.chevron_right,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ],
                      ),
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }
}

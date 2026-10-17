import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/responsive/responsive_layout.dart';
import 'package:qoshni/core/theme/app_tokens.dart';
import 'package:qoshni/core/widgets/app_message_banner.dart';
import 'package:qoshni/core/widgets/app_surface_card.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_category.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_demo_item.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_product.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_service.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_listing_status.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_category_controller.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_controller.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_product_controller.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_service_controller.dart';
import 'package:qoshni/routing/route_paths.dart';

class BusinessCatalogHomePage extends StatefulWidget {
  const BusinessCatalogHomePage({super.key});

  @override
  State<BusinessCatalogHomePage> createState() =>
      _BusinessCatalogHomePageState();
}

class _BusinessCatalogHomePageState extends State<BusinessCatalogHomePage> {
  String _query = '';
  String? _categoryFilter;
  BusinessCatalogListingStatus? _statusFilter;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final catalogController = getIt<BusinessCatalogController>();
    final categoryController = getIt<BusinessCatalogCategoryController>();
    final productController = getIt<BusinessCatalogProductController>();
    final serviceController = getIt<BusinessCatalogServiceController>();

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(l10n.catalogHomeTitle),
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: Listenable.merge([
            catalogController,
            categoryController,
            productController,
            serviceController,
          ]),
          builder: (context, _) {
            final stats = catalogController.overviewStats;
            final filteredProducts = _filterProducts(l10n, productController);
            final filteredServices = _filterServices(l10n, serviceController);

            return ResponsiveLayout(
              phone: _CatalogHomeBody(
                maxWidth: 520,
                l10n: l10n,
                stats: stats,
                categories: categoryController.categories,
                categoryFilter: _categoryFilter,
                statusFilter: _statusFilter,
                query: _query,
                filteredProductCount: filteredProducts.length,
                filteredServiceCount: filteredServices.length,
                onCategoryChanged: (v) => setState(() => _categoryFilter = v),
                onStatusChanged: (v) => setState(() => _statusFilter = v),
                onQueryChanged: (v) => setState(() => _query = v),
              ),
              tablet: _CatalogHomeBody(
                maxWidth: 760,
                l10n: l10n,
                stats: stats,
                categories: categoryController.categories,
                categoryFilter: _categoryFilter,
                statusFilter: _statusFilter,
                query: _query,
                filteredProductCount: filteredProducts.length,
                filteredServiceCount: filteredServices.length,
                onCategoryChanged: (v) => setState(() => _categoryFilter = v),
                onStatusChanged: (v) => setState(() => _statusFilter = v),
                onQueryChanged: (v) => setState(() => _query = v),
              ),
            );
          },
        ),
      ),
    );
  }

  List<BusinessCatalogProduct> _filterProducts(
    AppLocalizations l10n,
    BusinessCatalogProductController controller,
  ) {
    return controller.products.where((p) {
      if (_categoryFilter != null && p.categoryId != _categoryFilter) {
        return false;
      }
      if (_statusFilter != null && p.status != _statusFilter) {
        return false;
      }
      final q = _query.trim().toLowerCase();
      if (q.isNotEmpty && !p.displayName(l10n).toLowerCase().contains(q)) {
        return false;
      }
      return true;
    }).toList();
  }

  List<BusinessCatalogService> _filterServices(
    AppLocalizations l10n,
    BusinessCatalogServiceController controller,
  ) {
    return controller.services.where((s) {
      if (_categoryFilter != null && s.categoryId != _categoryFilter) {
        return false;
      }
      if (_statusFilter != null && s.status != _statusFilter) {
        return false;
      }
      final q = _query.trim().toLowerCase();
      if (q.isNotEmpty && !s.displayName(l10n).toLowerCase().contains(q)) {
        return false;
      }
      return true;
    }).toList();
  }
}

class _CatalogHomeBody extends StatelessWidget {
  const _CatalogHomeBody({
    required this.maxWidth,
    required this.l10n,
    required this.stats,
    required this.categories,
    required this.categoryFilter,
    required this.statusFilter,
    required this.query,
    required this.filteredProductCount,
    required this.filteredServiceCount,
    required this.onCategoryChanged,
    required this.onStatusChanged,
    required this.onQueryChanged,
  });

  final double maxWidth;
  final AppLocalizations l10n;
  final BusinessCatalogOverviewStats stats;
  final List<BusinessCatalogCategory> categories;
  final String? categoryFilter;
  final BusinessCatalogListingStatus? statusFilter;
  final String query;
  final int filteredProductCount;
  final int filteredServiceCount;
  final ValueChanged<String?> onCategoryChanged;
  final ValueChanged<BusinessCatalogListingStatus?> onStatusChanged;
  final ValueChanged<String> onQueryChanged;

  String _productsPath() {
    final params = <String, String>{};
    if (categoryFilter != null && categoryFilter!.isNotEmpty) {
      params['categoryId'] = categoryFilter!;
    }
    if (statusFilter != null) {
      params['status'] = statusFilter!.name;
    }
    final uri = Uri(
      path: RoutePaths.businessCatalogProducts,
      queryParameters: params.isEmpty ? null : params,
    );
    return uri.toString();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

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
              Text(
                l10n.catalogHomeIntro,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _StatsGrid(l10n: l10n, stats: stats),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                decoration: InputDecoration(
                  labelText: l10n.catalogListingSearchLabel,
                  prefixIcon: const Icon(Icons.search),
                  border: const OutlineInputBorder(),
                ),
                onChanged: onQueryChanged,
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
              const SizedBox(height: AppSpacing.lg),
              AppSurfaceCard(
                onTap: () => context.push(RoutePaths.businessCatalogCategories),
                child: Row(
                  children: [
                    Icon(Icons.category_outlined, color: colorScheme.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.catalogManageCategoriesTitle,
                            style: textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(l10n.catalogManageCategoriesBody),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              AppSurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.catalogProductsSectionTitle,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      l10n.catalogHomeFilteredCount(
                        filteredProductCount,
                        stats.productCount,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        FilledButton.tonal(
                          onPressed: () => context.push(_productsPath()),
                          child: Text(l10n.catalogProductListTitle),
                        ),
                        OutlinedButton(
                          onPressed: () =>
                              context.push(RoutePaths.businessCatalogProductCreate),
                          child: Text(l10n.catalogProductAddAction),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              AppSurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.catalogServicesSectionTitle,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      l10n.catalogHomeFilteredCount(
                        filteredServiceCount,
                        stats.serviceCount,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        FilledButton.tonal(
                          onPressed: () => context.push(
                            RoutePaths.businessCatalogServices,
                          ),
                          child: Text(l10n.catalogServiceListTitle),
                        ),
                        OutlinedButton(
                          onPressed: () =>
                              context.push(RoutePaths.businessCatalogServiceCreate),
                          child: Text(l10n.catalogServiceAddAction),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.l10n, required this.stats});

  final AppLocalizations l10n;
  final BusinessCatalogOverviewStats stats;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    Widget tile(String label, int value) {
      return AppSurfaceCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value.toString(),
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.primary,
              ),
            ),
            Text(label, style: textTheme.bodySmall),
          ],
        ),
      );
    }

    final children = [
      tile(l10n.catalogStatCategories, stats.categoryCount),
      tile(l10n.catalogStatProducts, stats.productCount),
      tile(l10n.catalogStatServices, stats.serviceCount),
      tile(l10n.catalogStatActiveItems, stats.activeItemCount),
      tile(l10n.catalogStatDraftItems, stats.draftItemCount),
      tile(l10n.catalogStatArchivedItems, stats.archivedItemCount),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 480;
        if (wide) {
          return Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: children
                .map(
                  (c) => SizedBox(
                    width: (constraints.maxWidth - AppSpacing.md) / 2,
                    child: c,
                  ),
                )
                .toList(),
          );
        }
        return Column(
          children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0) const SizedBox(height: AppSpacing.sm),
              children[i],
            ],
          ],
        );
      },
    );
  }
}

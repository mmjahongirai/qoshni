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
import 'package:qoshni/features/business_platform/domain/business_catalog_category_status.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_category_controller.dart';
import 'package:qoshni/routing/route_paths.dart';

class BusinessCatalogCategoryListPage extends StatefulWidget {
  const BusinessCatalogCategoryListPage({super.key});

  @override
  State<BusinessCatalogCategoryListPage> createState() =>
      _BusinessCatalogCategoryListPageState();
}

class _BusinessCatalogCategoryListPageState
    extends State<BusinessCatalogCategoryListPage> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final controller = getIt<BusinessCatalogCategoryController>();

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(l10n.catalogCategoryListTitle),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(RoutePaths.businessCatalogCategoryCreate),
        icon: const Icon(Icons.add),
        label: Text(l10n.catalogCategoryAddAction),
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
            final categories = _filterCategories(
              controller.categories,
              _query,
              l10n,
            );
            return ResponsiveLayout(
              phone: _CategoryListBody(
                maxWidth: 520,
                l10n: l10n,
                categories: categories,
                query: _query,
                onQueryChanged: (v) => setState(() => _query = v),
              ),
              tablet: _CategoryListBody(
                maxWidth: 760,
                l10n: l10n,
                categories: categories,
                query: _query,
                onQueryChanged: (v) => setState(() => _query = v),
              ),
            );
          },
        ),
      ),
    );
  }

  List<BusinessCatalogCategory> _filterCategories(
    List<BusinessCatalogCategory> all,
    String query,
    AppLocalizations l10n,
  ) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) {
      return all;
    }
    return all
        .where((c) => c.displayName(l10n).toLowerCase().contains(q))
        .toList(growable: false);
  }
}

class _CategoryListBody extends StatelessWidget {
  const _CategoryListBody({
    required this.maxWidth,
    required this.l10n,
    required this.categories,
    required this.query,
    required this.onQueryChanged,
  });

  final double maxWidth;
  final AppLocalizations l10n;
  final List<BusinessCatalogCategory> categories;
  final String query;
  final ValueChanged<String> onQueryChanged;

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
              TextField(
                decoration: InputDecoration(
                  labelText: l10n.catalogCategorySearchLabel,
                  prefixIcon: const Icon(Icons.search),
                  border: const OutlineInputBorder(),
                ),
                onChanged: onQueryChanged,
              ),
              const SizedBox(height: AppSpacing.md),
              if (categories.isEmpty)
                AppSurfaceCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        l10n.catalogCategoryEmptyTitle,
                        style: textTheme.titleSmall,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        l10n.catalogCategoryEmptyBody,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...categories.map(
                  (category) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: AppSurfaceCard(
                      onTap: () => context.push(
                        RoutePaths.businessCatalogCategoryDetailPath(
                          category.categoryId,
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
                                  category.displayName(l10n),
                                  style: textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  category.status.label(l10n),
                                  style: textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (category.isDemoSeed) const DemoContentBadge(),
                          Icon(
                            Icons.chevron_right,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

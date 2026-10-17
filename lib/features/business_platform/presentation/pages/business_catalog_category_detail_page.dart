import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/responsive/responsive_layout.dart';
import 'package:qoshni/core/theme/app_tokens.dart';
import 'package:qoshni/core/widgets/app_surface_card.dart';
import 'package:qoshni/core/widgets/demo_content_badge.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_category.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_category_status.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_category_controller.dart';
import 'package:qoshni/routing/route_paths.dart';

class BusinessCatalogCategoryDetailPage extends StatelessWidget {
  const BusinessCatalogCategoryDetailPage({required this.categoryId, super.key});

  final String? categoryId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final controller = getIt<BusinessCatalogCategoryController>();
    final id = categoryId?.trim();
    final category =
        id == null || id.isEmpty ? null : controller.categoryById(id);

    if (category == null) {
      return Scaffold(
        appBar: AppBar(
          leading: BackButton(onPressed: () => context.pop()),
          title: Text(l10n.catalogCategoryDetailTitle),
        ),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: responsivePagePadding(context),
              child: AppSurfaceCard(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.catalogCategoryNotFoundTitle,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(l10n.catalogCategoryNotFoundBody),
                    const SizedBox(height: AppSpacing.md),
                    FilledButton(
                      onPressed: () =>
                          context.go(RoutePaths.businessCatalogCategories),
                      child: Text(l10n.catalogCategoryBackToListAction),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(l10n.catalogCategoryDetailTitle),
        actions: [
          TextButton(
            onPressed: () => context.push(
              RoutePaths.businessCatalogCategoryEditPath(category.categoryId),
            ),
            child: Text(l10n.catalogCategoryEditAction),
          ),
        ],
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
            final current =
                controller.categoryById(category.categoryId) ?? category;
            return ResponsiveLayout(
              phone: _CategoryDetailBody(category: current, maxWidth: 520),
              tablet: _CategoryDetailBody(category: current, maxWidth: 760),
            );
          },
        ),
      ),
    );
  }
}

class _CategoryDetailBody extends StatelessWidget {
  const _CategoryDetailBody({
    required this.category,
    required this.maxWidth,
  });

  final BusinessCatalogCategory category;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final controller = getIt<BusinessCatalogCategoryController>();
    final parent = category.parentCategoryId == null
        ? null
        : controller.categoryById(category.parentCategoryId!);

    return Align(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        padding: responsivePagePadding(context),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (category.isDemoSeed) ...[
                const Align(
                  alignment: Alignment.centerLeft,
                  child: DemoContentBadge(),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              AppSurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.displayName(l10n),
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      category.status.label(l10n),
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (parent != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        l10n.catalogCategoryParentLabel(parent.displayName(l10n)),
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _LocaleBlock(
                title: l10n.catalogCategoryNamesSection,
                nameUz: category.localized.nameUz,
                nameRu: category.localized.nameRu,
                nameEn: category.localized.nameEn,
              ),
              const SizedBox(height: AppSpacing.md),
              _LocaleBlock(
                title: l10n.catalogCategoryDescriptionsSection,
                nameUz: category.localized.descriptionUz,
                nameRu: category.localized.descriptionRu,
                nameEn: category.localized.descriptionEn,
                descriptions: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LocaleBlock extends StatelessWidget {
  const _LocaleBlock({
    required this.title,
    required this.nameUz,
    required this.nameRu,
    required this.nameEn,
    this.descriptions = false,
  });

  final String title;
  final String nameUz;
  final String nameRu;
  final String nameEn;
  final bool descriptions;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;

    String line(String lang, String value) {
      if (value.trim().isEmpty) {
        return '$lang: ${l10n.catalogCategoryFieldEmpty}';
      }
      return '$lang: $value';
    }

    return AppSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(line(l10n.catalogLanguageUz, nameUz)),
          const SizedBox(height: 4),
          Text(line(l10n.catalogLanguageRu, nameRu)),
          const SizedBox(height: 4),
          Text(line(l10n.catalogLanguageEn, nameEn)),
        ],
      ),
    );
  }
}

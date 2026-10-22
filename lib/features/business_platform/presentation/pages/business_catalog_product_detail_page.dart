import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/responsive/responsive_layout.dart';
import 'package:qoshni/core/theme/app_tokens.dart';
import 'package:qoshni/core/widgets/app_surface_card.dart';
import 'package:qoshni/core/widgets/demo_content_badge.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_listing_status.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_category_controller.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_product_controller.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_product_variant_controller.dart';
import 'package:qoshni/features/business_platform/presentation/widgets/catalog_listing_placeholder.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_listing_kind.dart';
import 'package:qoshni/features/business_platform/presentation/widgets/catalog_listing_attributes_section.dart';
import 'package:qoshni/features/business_platform/presentation/widgets/catalog_product_media_gallery_section.dart';
import 'package:qoshni/features/business_platform/presentation/widgets/catalog_product_options_section.dart';
import 'package:qoshni/routing/route_paths.dart';

class BusinessCatalogProductDetailPage extends StatelessWidget {
  const BusinessCatalogProductDetailPage({required this.productId, super.key});

  final String? productId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final controller = getIt<BusinessCatalogProductController>();
    final id = productId?.trim();
    final product = id == null || id.isEmpty ? null : controller.productById(id);

    if (product == null) {
      return Scaffold(
        appBar: AppBar(
          leading: BackButton(onPressed: () => context.pop()),
          title: Text(l10n.catalogProductDetailTitle),
        ),
        body: SafeArea(
          child: Center(
            child: AppSurfaceCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.catalogProductNotFoundTitle),
                  const SizedBox(height: AppSpacing.md),
                  FilledButton(
                    onPressed: () => context.go(RoutePaths.businessCatalogProducts),
                    child: Text(l10n.catalogProductBackToListAction),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(l10n.catalogProductDetailTitle),
        actions: [
          TextButton(
            onPressed: () => context.push(
              RoutePaths.businessCatalogProductEditPath(product.productId),
            ),
            child: Text(l10n.catalogCategoryEditAction),
          ),
        ],
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: Listenable.merge([
            controller,
            getIt<BusinessCatalogCategoryController>(),
            getIt<BusinessCatalogProductVariantController>(),
          ]),
          builder: (context, _) {
            final current = controller.productById(product.productId) ?? product;
            final category = getIt<BusinessCatalogCategoryController>()
                .categoryById(current.categoryId);
            final variants = getIt<BusinessCatalogProductVariantController>()
                .variantsForProduct(current.productId);

            return ResponsiveLayout(
              phone: _Body(
                maxWidth: 520,
                l10n: l10n,
                productId: current.productId,
                name: current.displayName(l10n),
                status: current.status,
                categoryName: category?.displayName(l10n),
                isDemo: current.isDemoSeed,
                variantCount: variants.length,
              ),
              tablet: _Body(
                maxWidth: 760,
                l10n: l10n,
                productId: current.productId,
                name: current.displayName(l10n),
                status: current.status,
                categoryName: category?.displayName(l10n),
                isDemo: current.isDemoSeed,
                variantCount: variants.length,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.maxWidth,
    required this.l10n,
    required this.productId,
    required this.name,
    required this.status,
    required this.categoryName,
    required this.isDemo,
    required this.variantCount,
  });

  final double maxWidth;
  final AppLocalizations l10n;
  final String productId;
  final String name;
  final BusinessCatalogListingStatus status;
  final String? categoryName;
  final bool isDemo;
  final int variantCount;

  @override
  Widget build(BuildContext context) {
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
              if (isDemo) ...[
                const Align(
                  alignment: Alignment.centerLeft,
                  child: DemoContentBadge(),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              CatalogProductMediaGallerySection(
                productId: productId,
                readOnly: true,
              ),
              const SizedBox(height: AppSpacing.md),
              CatalogProductOptionsSection(
                productId: productId,
                readOnly: true,
              ),
              const SizedBox(height: AppSpacing.md),
              CatalogListingAttributesSection(
                listingKind: BusinessCatalogListingKind.product,
                listingId: productId,
                readOnly: true,
              ),
              const SizedBox(height: AppSpacing.md),
              const CatalogListingPlaceholder(),
              const SizedBox(height: AppSpacing.md),
              AppSurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(status.label(l10n)),
                    if (categoryName != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(l10n.catalogListingCategoryLabel(categoryName!)),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              AppSurfaceCard(
                onTap: () => context.push(
                  RoutePaths.businessCatalogProductVariantsPath(productId),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.catalogProductVariantsTitle(variantCount),
                        style: textTheme.titleSmall,
                      ),
                    ),
                    const Icon(Icons.chevron_right),
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

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/responsive/responsive_layout.dart';
import 'package:qoshni/core/theme/app_tokens.dart';
import 'package:qoshni/core/widgets/app_surface_card.dart';
import 'package:qoshni/core/widgets/demo_content_badge.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_listing_status.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_product_controller.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_product_variant_controller.dart';
import 'package:qoshni/routing/route_paths.dart';

class BusinessCatalogProductVariantsPage extends StatelessWidget {
  const BusinessCatalogProductVariantsPage({required this.productId, super.key});

  final String? productId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final id = productId?.trim();
    final productController = getIt<BusinessCatalogProductController>();
    final variantController = getIt<BusinessCatalogProductVariantController>();
    final product = id == null ? null : productController.productById(id);

    if (product == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.catalogProductVariantsManageTitle)),
        body: Center(child: Text(l10n.catalogProductNotFoundTitle)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(l10n.catalogProductVariantsManageTitle),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(
          RoutePaths.businessCatalogProductVariantCreatePath(product.productId),
        ),
        icon: const Icon(Icons.add),
        label: Text(l10n.catalogVariantAddAction),
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: variantController,
          builder: (context, _) {
            final variants = variantController.variantsForProduct(product.productId);
            if (variants.isEmpty) {
              return Center(child: Text(l10n.catalogVariantEmptyBody));
            }
            return ListView.builder(
              padding: responsivePagePadding(context),
              itemCount: variants.length,
              itemBuilder: (context, index) {
                final variant = variants[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: AppSurfaceCard(
                    onTap: () => context.push(
                      RoutePaths.businessCatalogProductVariantEditPath(
                        product.productId,
                        variant.variantId,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(variant.label),
                              Text('SKU: ${variant.sku}'),
                              Text(variant.status.label(l10n)),
                            ],
                          ),
                        ),
                        if (variant.isDemoSeed) const DemoContentBadge(),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

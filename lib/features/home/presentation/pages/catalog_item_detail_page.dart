import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/responsive/responsive_layout.dart';
import 'package:qoshni/core/theme/app_tokens.dart';
import 'package:qoshni/core/widgets/app_empty_state.dart';
import 'package:qoshni/core/widgets/app_price_text.dart';
import 'package:qoshni/core/widgets/app_surface_card.dart';
import 'package:qoshni/core/widgets/category_icon_badge.dart';
import 'package:qoshni/core/widgets/demo_content_badge.dart';
import 'package:qoshni/features/home/presentation/data/business_catalog_mock_data.dart';
import 'package:qoshni/features/home/presentation/data/home_mock_data.dart';
import 'package:qoshni/features/home/presentation/data/mock_business_id.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/features/home/presentation/cart/cart_controller.dart';
import 'package:qoshni/features/home/presentation/data/mock_catalog_item_id.dart';

class CatalogItemDetailPage extends StatelessWidget {
  const CatalogItemDetailPage({
    required this.businessId,
    required this.catalogItemId,
    super.key,
  });

  final MockBusinessId? businessId;
  final MockCatalogItemId? catalogItemId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final businessRouteId = businessId;
    final itemRouteId = catalogItemId;

    final business = businessRouteId == null
        ? null
        : findMockBusinessById(l10n, colorScheme, businessRouteId);

    final catalogItem = businessRouteId != null && itemRouteId != null
        ? findCatalogItemForBusiness(
            l10n: l10n,
            businessId: businessRouteId,
            catalogItemId: itemRouteId,
          )
        : null;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(
          catalogItem?.name ?? l10n.catalogItemDetailNotFoundTitle,
        ),
      ),
      body: SafeArea(
        child: ResponsiveLayout(
          phone: _CatalogItemDetailBody(
            maxWidth: 520,
            l10n: l10n,
            business: business,
            catalogItem: catalogItem,
          ),
          tablet: _CatalogItemDetailBody(
            maxWidth: 760,
            l10n: l10n,
            business: business,
            catalogItem: catalogItem,
          ),
        ),
      ),
    );
  }
}

class _CatalogItemDetailBody extends StatelessWidget {
  const _CatalogItemDetailBody({
    required this.maxWidth,
    required this.l10n,
    required this.business,
    required this.catalogItem,
  });

  final double maxWidth;
  final AppLocalizations l10n;
  final NearbyBusinessItem? business;
  final BusinessCatalogItem? catalogItem;

  @override
  Widget build(BuildContext context) {
    if (business == null || catalogItem == null) {
      return _CatalogItemNotFoundState(l10n: l10n);
    }

    final item = catalogItem!;
    final parent = business!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final typeLabel = catalogItemKindLabel(item.kind, l10n);
    final samplePriceUzs = item.samplePriceUzs;

    return Align(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        padding: responsivePagePadding(context),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppSurfaceCard(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const DemoContentBadge(),
                    const SizedBox(height: AppSpacing.sm),
                    CategoryIconBadge(
                      icon: item.icon,
                      accent: colorScheme.primary,
                      size: 64,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      item.name,
                      style: textTheme.headlineSmall,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      typeLabel,
                      style: textTheme.titleSmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (samplePriceUzs != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      AppPriceText(
                        label: formatCatalogSamplePrice(samplePriceUzs, l10n),
                        emphasis: PriceEmphasis.total,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              AppSurfaceCard(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.storefront_outlined,
                          size: 20,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          l10n.catalogItemDetailParentBusiness,
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      parent.name,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              AppSurfaceCard(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.description_outlined,
                          size: 20,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          l10n.catalogItemDetailSectionDescription,
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      item.description,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _CatalogAddToCartSection(
                l10n: l10n,
                businessId: parent.id,
                catalogItemId: item.id,
                catalogItem: item,
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class _CatalogAddToCartSection extends StatelessWidget {
  const _CatalogAddToCartSection({
    required this.l10n,
    required this.businessId,
    required this.catalogItemId,
    required this.catalogItem,
  });

  final AppLocalizations l10n;
  final MockBusinessId businessId;
  final MockCatalogItemId catalogItemId;
  final BusinessCatalogItem catalogItem;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final cartController = getIt<CartController>();
    final hasPrice = catalogItem.samplePriceUzs != null;

    if (!hasPrice) {
      return AppSurfaceCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Text(
          l10n.cartCannotAddNoPrice,
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            height: 1.35,
          ),
        ),
      );
    }

    return FilledButton.icon(
      onPressed: () {
        final added = cartController.addCatalogItem(
          l10n: l10n,
          businessId: businessId,
          catalogItemId: catalogItemId,
        );
        if (!context.mounted) {
          return;
        }
        if (added) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.cartAddedSnackBar(catalogItem.name)),
            ),
          );
        }
      },
      icon: const Icon(Icons.add_shopping_cart_outlined),
      label: Text(l10n.cartAddToCart),
    );
  }
}

class _CatalogItemNotFoundState extends StatelessWidget {
  const _CatalogItemNotFoundState({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AppEmptyState(
        icon: Icons.inventory_2_outlined,
        title: l10n.catalogItemDetailNotFoundTitle,
        message: l10n.catalogItemDetailNotFoundBody,
      ),
    );
  }
}

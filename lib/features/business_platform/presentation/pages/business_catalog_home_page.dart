import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/responsive/responsive_layout.dart';
import 'package:qoshni/core/theme/app_tokens.dart';
import 'package:qoshni/core/widgets/app_message_banner.dart';
import 'package:qoshni/core/widgets/app_surface_card.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_demo_item.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_controller.dart';
import 'package:qoshni/routing/route_paths.dart';

class BusinessCatalogHomePage extends StatelessWidget {
  const BusinessCatalogHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final catalogController = getIt<BusinessCatalogController>();

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(l10n.catalogHomeTitle),
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: catalogController,
          builder: (context, _) {
            final stats = catalogController.overviewStats;
            return ResponsiveLayout(
              phone: _CatalogHomeBody(
                maxWidth: 520,
                l10n: l10n,
                stats: stats,
              ),
              tablet: _CatalogHomeBody(
                maxWidth: 760,
                l10n: l10n,
                stats: stats,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CatalogHomeBody extends StatelessWidget {
  const _CatalogHomeBody({
    required this.maxWidth,
    required this.l10n,
    required this.stats,
  });

  final double maxWidth;
  final AppLocalizations l10n;
  final BusinessCatalogOverviewStats stats;

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
                          const SizedBox(height: 4),
                          Text(
                            l10n.catalogManageCategoriesBody,
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              height: 1.35,
                            ),
                          ),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l10n.catalogProductsSectionTitle,
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        _ComingSoonChip(label: l10n.catalogComingSoonLabel),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.catalogProductsSectionBody,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              AppSurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.handyman_outlined,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l10n.catalogServicesSectionTitle,
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        _ComingSoonChip(label: l10n.catalogComingSoonLabel),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.catalogServicesSectionBody,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.35,
                      ),
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
            const SizedBox(height: 4),
            Text(
              label,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 480;
        final children = [
          tile(l10n.catalogStatCategories, stats.categoryCount),
          tile(l10n.catalogStatProducts, stats.productCount),
          tile(l10n.catalogStatServices, stats.serviceCount),
          tile(l10n.catalogStatActiveItems, stats.activeItemCount),
          tile(l10n.catalogStatDraftItems, stats.draftItemCount),
        ];
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

class _ComingSoonChip extends StatelessWidget {
  const _ComingSoonChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
      ),
    );
  }
}

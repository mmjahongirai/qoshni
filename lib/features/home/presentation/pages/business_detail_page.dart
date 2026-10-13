import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/responsive/responsive_layout.dart';
import 'package:qoshni/features/home/presentation/data/home_mock_data.dart';
import 'package:qoshni/features/home/presentation/data/mock_business_id.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/features/home/presentation/data/service_category_id.dart';
import 'package:qoshni/features/home/presentation/favorites/favorites_controller.dart';

class BusinessDetailPage extends StatelessWidget {
  const BusinessDetailPage({
    required this.businessId,
    super.key,
  });

  final MockBusinessId? businessId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final business = businessId == null
        ? null
        : findMockBusinessById(l10n, colorScheme, businessId!);
    final favoritesController = getIt<FavoritesController>();
    final resolvedId = businessId;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(
          business?.name ?? l10n.businessDetailNotFoundTitle,
        ),
        actions: [
          if (business != null && resolvedId != null)
            ListenableBuilder(
              listenable: favoritesController,
              builder: (context, _) {
                final isFavorite = favoritesController.isFavorite(resolvedId);
                return IconButton(
                  tooltip: isFavorite
                      ? l10n.favoritesRemoveTooltip
                      : l10n.favoritesAddTooltip,
                  onPressed: () =>
                      favoritesController.toggleFavorite(resolvedId),
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? colorScheme.primary : null,
                  ),
                );
              },
            ),
        ],
      ),
      body: SafeArea(
        child: ResponsiveLayout(
          phone: _BusinessDetailBody(
            maxWidth: 520,
            l10n: l10n,
            business: business,
          ),
          tablet: _BusinessDetailBody(
            maxWidth: 760,
            l10n: l10n,
            business: business,
          ),
        ),
      ),
    );
  }
}

class _BusinessDetailBody extends StatelessWidget {
  const _BusinessDetailBody({
    required this.maxWidth,
    required this.l10n,
    required this.business,
  });

  final double maxWidth;
  final AppLocalizations l10n;
  final NearbyBusinessItem? business;

  @override
  Widget build(BuildContext context) {
    final item = business;
    if (item == null) {
      return _BusinessNotFoundState(l10n: l10n);
    }

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final categoryLabel = serviceCategoryLabel(item.categoryId, l10n);

    return Align(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        padding: responsivePagePadding(context),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: item.accent.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(item.icon, color: item.accent, size: 28),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        item.name,
                        style: textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _InfoChip(
                            icon: Icons.category_outlined,
                            label: categoryLabel,
                          ),
                          _InfoChip(
                            icon: Icons.near_me_outlined,
                            label: item.distanceLabel,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _DetailSection(
                title: l10n.businessDetailSectionAbout,
                icon: Icons.info_outline_rounded,
                body: _sectionBody(context, item.description),
              ),
              const SizedBox(height: 12),
              _DetailSection(
                title: l10n.businessDetailSectionLocation,
                icon: Icons.place_outlined,
                body: _sectionBody(context, item.address),
              ),
              const SizedBox(height: 12),
              _DetailSection(
                title: l10n.businessDetailSectionHours,
                icon: Icons.schedule_outlined,
                body: _sectionBody(context, item.hours),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  String _sectionBody(BuildContext context, String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return l10n.businessDetailInfoNotAvailable;
    }
    return trimmed;
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: textTheme.labelLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({
    required this.title,
    required this.icon,
    required this.body,
  });

  final String title;
  final IconData icon;
  final String body;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              body,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BusinessNotFoundState extends StatelessWidget {
  const _BusinessNotFoundState({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.store_mall_directory_outlined,
                size: 48, color: colorScheme.primary),
            const SizedBox(height: 14),
            Text(
              l10n.businessDetailNotFoundTitle,
              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.businessDetailNotFoundBody,
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

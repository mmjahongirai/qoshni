import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/theme/app_tokens.dart';
import 'package:qoshni/core/widgets/app_surface_card.dart';
import 'package:qoshni/core/widgets/category_icon_badge.dart';
import 'package:qoshni/core/widgets/demo_content_badge.dart';
import 'package:qoshni/features/home/presentation/data/home_essential_place.dart';
import 'package:qoshni/routing/route_paths.dart';

class HomeNearbyChainsSection extends StatelessWidget {
  const HomeNearbyChainsSection({
    required this.l10n,
    required this.places,
    super.key,
  });

  final AppLocalizations l10n;
  final List<HomeEssentialPlaceItem> places;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.homeNearbyChainsTitle,
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          l10n.homeNearbyChainsSubtitle,
          style: textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            height: 1.35,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: 172,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: places.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
            itemBuilder: (context, index) {
              return _EssentialPlaceCard(
                item: places[index],
                onTap: () => _openPlace(context, places[index]),
              );
            },
          ),
        ),
      ],
    );
  }

  void _openPlace(BuildContext context, HomeEssentialPlaceItem item) {
    final categoryId = item.categoryId;
    if (categoryId != null) {
      context.pushNamed(
        RouteNames.categoryListing,
        pathParameters: {'categoryId': categoryId.name},
      );
      return;
    }
    context.pushNamed(RouteNames.search);
  }
}

class _EssentialPlaceCard extends StatelessWidget {
  const _EssentialPlaceCard({
    required this.item,
    required this.onTap,
  });

  final HomeEssentialPlaceItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: 156,
      child: AppSurfaceCard(
        padding: const EdgeInsets.all(AppSpacing.sm),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CategoryIconBadge(
                  icon: item.icon,
                  accent: item.accent,
                  size: 44,
                  iconSize: AppIconSize.sm,
                ),
                const Spacer(),
                const DemoContentBadge(),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              item.title,
              style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              item.subtitle,
              style: textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

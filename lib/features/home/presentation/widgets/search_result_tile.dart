import 'package:flutter/material.dart';
import 'package:qoshni/core/theme/app_tokens.dart';
import 'package:qoshni/core/widgets/app_surface_card.dart';
import 'package:qoshni/core/widgets/category_icon_badge.dart';
import 'package:qoshni/features/home/presentation/data/home_mock_data.dart';
import 'package:qoshni/features/home/presentation/navigation/business_navigation.dart';
import 'package:qoshni/features/home/presentation/widgets/business_favorite_button.dart';

class SearchResultTile extends StatelessWidget {
  const SearchResultTile({
    required this.entry,
    this.trailing,
    this.showSponsoredLabel = false,
    this.sponsoredLabel,
    super.key,
  });

  final SearchCatalogEntry entry;
  final Widget? trailing;
  final bool showSponsoredLabel;
  final String? sponsoredLabel;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final resolvedTrailing = trailing ??
        (entry.kind == SearchEntryKind.business && entry.businessId != null
            ? BusinessFavoriteButton(businessId: entry.businessId!)
            : null);

    return AppSurfaceCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      onTap: () => openSearchCatalogEntry(context, entry),
      child: Row(
        children: [
          CategoryIconBadge(icon: entry.icon, accent: entry.accent, size: 48),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        entry.title,
                        style: textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (showSponsoredLabel && sponsoredLabel != null) ...[
                      const SizedBox(width: AppSpacing.xxs),
                      Text(
                        sponsoredLabel!,
                        style: textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    ],
                  ],
                ),
                if (entry.subtitle.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    entry.subtitle,
                    style: textTheme.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          if (resolvedTrailing != null) resolvedTrailing,
        ],
      ),
    );
  }
}

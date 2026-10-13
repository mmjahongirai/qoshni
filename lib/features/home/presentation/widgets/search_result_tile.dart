import 'package:flutter/material.dart';
import 'package:qoshni/features/home/presentation/data/home_mock_data.dart';
import 'package:qoshni/features/home/presentation/navigation/business_navigation.dart';
import 'package:qoshni/features/home/presentation/widgets/business_favorite_button.dart';

class SearchResultTile extends StatelessWidget {
  const SearchResultTile({
    required this.entry,
    this.trailing,
    super.key,
  });

  final SearchCatalogEntry entry;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final resolvedTrailing = trailing ??
        (entry.kind == SearchEntryKind.business && entry.businessId != null
            ? BusinessFavoriteButton(businessId: entry.businessId!)
            : null);

    return Card(
      margin: EdgeInsets.zero,
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => openSearchCatalogEntry(context, entry),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: entry.accent.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(entry.icon, color: entry.accent),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.title,
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (entry.subtitle.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              entry.subtitle,
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (resolvedTrailing != null) resolvedTrailing,
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:qoshni/features/home/presentation/data/home_mock_data.dart';
import 'package:qoshni/features/home/presentation/navigation/business_navigation.dart';
import 'package:qoshni/features/home/presentation/widgets/business_favorite_button.dart';

class NearbyBusinessCard extends StatelessWidget {
  const NearbyBusinessCard({
    required this.business,
    super.key,
  });

  final NearbyBusinessItem business;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      width: 240,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: InkWell(
                onTap: () => openMockBusinessDetail(context, business.id),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 4, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: business.accent.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(business.icon, color: business.accent),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        business.name,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        business.subtitle,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            BusinessFavoriteButton(businessId: business.id),
          ],
        ),
      ),
    );
  }
}

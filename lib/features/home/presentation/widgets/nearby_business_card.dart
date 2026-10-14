import 'package:flutter/material.dart';
import 'package:qoshni/core/theme/app_tokens.dart';
import 'package:qoshni/core/widgets/app_image_placeholder.dart';
import 'package:qoshni/core/widgets/app_surface_card.dart';
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
      width: 248,
      child: AppSurfaceCard(
        padding: EdgeInsets.zero,
        onTap: () => openMockBusinessDetail(context, business.id),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AppImagePlaceholder(
                  icon: business.icon,
                  accent: business.accent,
                  height: 96,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppRadius.lg),
                  ),
                ),
                Positioned(
                  top: AppSpacing.xs,
                  right: AppSpacing.xs,
                  child: Material(
                    color: colorScheme.surface.withValues(alpha: 0.92),
                    borderRadius: AppRadius.smAll,
                    child: BusinessFavoriteButton(businessId: business.id),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    business.name,
                    style: textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    business.subtitle,
                    style: textTheme.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    business.distanceLabel,
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

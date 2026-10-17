import 'package:flutter/material.dart';
import 'package:qoshni/core/theme/app_tokens.dart';
import 'package:qoshni/core/widgets/demo_content_badge.dart';

/// Placeholder visual for catalog preview (no real media upload in this phase).
class CatalogListingPlaceholder extends StatelessWidget {
  const CatalogListingPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.image_outlined,
            size: 40,
            color: colorScheme.onSurfaceVariant,
          ),
          const Positioned(
            top: AppSpacing.sm,
            right: AppSpacing.sm,
            child: DemoContentBadge(),
          ),
        ],
      ),
    );
  }
}

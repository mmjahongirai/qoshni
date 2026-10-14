import 'package:flutter/material.dart';
import 'package:qoshni/core/theme/app_tokens.dart';

/// Consistent category / listing icon tile (gradient-backed, no external assets).
class CategoryIconBadge extends StatelessWidget {
  const CategoryIconBadge({
    required this.icon,
    required this.accent,
    this.size = AppIconSize.hero,
    this.iconSize = AppIconSize.md,
    super.key,
  });

  final IconData icon;
  final Color accent;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: AppRadius.mdAll,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent.withValues(alpha: 0.24),
            scheme.surfaceContainerHighest.withValues(alpha: 0.9),
          ],
        ),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.45),
        ),
      ),
      child: Icon(icon, size: iconSize, color: accent),
    );
  }
}

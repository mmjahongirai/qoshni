import 'package:flutter/material.dart';
import 'package:qoshni/core/theme/app_tokens.dart';

/// Gradient + icon placeholder for catalog/business imagery (no network URLs).
class AppImagePlaceholder extends StatelessWidget {
  const AppImagePlaceholder({
    required this.icon,
    this.accent,
    this.height = 120,
    this.borderRadius,
    super.key,
  });

  final IconData icon;
  final Color? accent;
  final double height;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = accent ?? scheme.primary;
    final radius = borderRadius ?? AppRadius.mdAll;

    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.22),
            scheme.surfaceContainerHighest.withValues(alpha: 0.85),
          ],
        ),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Icon(icon, color: color.withValues(alpha: 0.9), size: AppIconSize.lg),
    );
  }
}

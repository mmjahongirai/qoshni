import 'package:flutter/material.dart';
import 'package:qoshni/core/theme/app_tokens.dart';

/// Elevated surface card aligned with [AppTheme] — border-first, minimal shadow.
class AppSurfaceCard extends StatelessWidget {
  const AppSurfaceCard({
    required this.child,
    this.onTap,
    this.padding,
    this.clipBehavior = Clip.antiAlias,
    this.margin,
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final Clip clipBehavior;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final content = Padding(
      padding: padding ?? const EdgeInsets.all(AppSpacing.md),
      child: child,
    );

    return AnimatedContainer(
      duration: appAnimationDuration(context, AppDurations.fast),
      margin: margin,
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: AppRadius.lgAll,
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: isDark ? 0.65 : 0.55),
        ),
        boxShadow: AppElevation.subtle(scheme, isDark: isDark),
      ),
      clipBehavior: clipBehavior,
      child: Material(
        color: Colors.transparent,
        child: onTap == null
            ? content
            : InkWell(
                onTap: onTap,
                borderRadius: AppRadius.lgAll,
                child: content,
              ),
      ),
    );
  }
}

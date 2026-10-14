import 'package:flutter/material.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/theme/app_tokens.dart';

/// Marks sample/demo catalog content without implying verified business data.
class DemoContentBadge extends StatelessWidget {
  const DemoContentBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final label = l10n.demoContentBadge;

    return Semantics(
      label: label,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: AppSpacing.xxs,
        ),
        decoration: BoxDecoration(
          color: scheme.secondaryContainer.withValues(alpha: 0.65),
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(
            color: scheme.outlineVariant.withValues(alpha: 0.45),
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: scheme.onSecondaryContainer,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
        ),
      ),
    );
  }
}

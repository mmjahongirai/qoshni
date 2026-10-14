import 'package:flutter/material.dart';
import 'package:qoshni/core/theme/app_tokens.dart';

class AppMessageBanner extends StatelessWidget {
  const AppMessageBanner({
    required this.message,
    required this.icon,
    this.tone = AppMessageTone.info,
    super.key,
  });

  final String message;
  final IconData icon;
  final AppMessageTone tone;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (background, foreground) = switch (tone) {
      AppMessageTone.info => (
          scheme.surfaceContainerHighest.withValues(alpha: 0.72),
          scheme.onSurface,
        ),
      AppMessageTone.error => (
          scheme.errorContainer.withValues(alpha: 0.45),
          scheme.onErrorContainer,
        ),
      AppMessageTone.warning => (
          scheme.tertiaryContainer.withValues(alpha: 0.5),
          scheme.onTertiaryContainer,
        ),
    };

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppRadius.smAll,
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: AppIconSize.sm, color: foreground),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: foreground, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}

enum AppMessageTone { info, error, warning }

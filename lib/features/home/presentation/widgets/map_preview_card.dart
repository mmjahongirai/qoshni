import 'package:flutter/material.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/theme/app_tokens.dart';
import 'package:qoshni/core/widgets/app_surface_card.dart';
import 'package:qoshni/core/widgets/demo_content_badge.dart';
import 'package:qoshni/core/config/mapbox_access_config.dart';
import 'package:qoshni/features/home/presentation/data/home_essential_place.dart';
import 'package:qoshni/features/home/presentation/widgets/qoshni_mapbox_view.dart';

/// Premium home map preview — not a live map; no invented GPS markers.
class MapPreviewCard extends StatelessWidget {
  const MapPreviewCard({
    required this.l10n,
    required this.onOpenMap,
    super.key,
  });

  final AppLocalizations l10n;
  final VoidCallback onOpenMap;

  static double mapCanvasHeight(double maxWidth) {
    if (maxWidth >= 600) {
      return 280;
    }
    if (maxWidth >= 400) {
      return 240;
    }
    return 220;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final legend = buildHomeMapLegendEntries(l10n, colorScheme);

    return LayoutBuilder(
      builder: (context, constraints) {
        final mapHeight = mapCanvasHeight(constraints.maxWidth);

        return AppSurfaceCard(
          clipBehavior: Clip.antiAlias,
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.mapPreviewTitle,
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const DemoContentBadge(),
                ],
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                l10n.mapPreviewSubtitle,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              ClipRRect(
                borderRadius: AppRadius.lgAll,
                child: SizedBox(
                  height: mapHeight,
                  width: double.infinity,
                  child: QoshniMapboxView(
                    showDefaultViewLabel: MapboxAccessConfig.isConfigured,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                MapboxAccessConfig.isConfigured
                    ? l10n.homeMapPreviewStatusConfigured
                    : l10n.homeMapPreviewStatusNotConfigured,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.xs,
                children: [
                  for (final entry in legend)
                    _MapLegendChip(
                      icon: entry.icon,
                      label: entry.label,
                      accent: entry.accent,
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              FilledButton.icon(
                onPressed: onOpenMap,
                icon: const Icon(Icons.map_outlined, size: 20),
                label: Text(l10n.openMap),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MapLegendChip extends StatelessWidget {
  const _MapLegendChip({
    required this.icon,
    required this.label,
    required this.accent,
  });

  final IconData icon;
  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.45),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: accent),
          const SizedBox(width: AppSpacing.xxs),
          Text(
            label,
            style: textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

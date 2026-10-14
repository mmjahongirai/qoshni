import 'package:flutter/material.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/theme/app_tokens.dart';
import 'package:qoshni/core/widgets/app_surface_card.dart';
import 'package:qoshni/core/widgets/demo_content_badge.dart';
import 'package:qoshni/features/home/presentation/data/home_essential_place.dart';

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
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _MapPreviewCanvas(colorScheme: colorScheme),
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(AppSpacing.sm),
                              decoration: BoxDecoration(
                                color: colorScheme.surface.withValues(alpha: 0.92),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: colorScheme.outlineVariant
                                      .withValues(alpha: 0.65),
                                ),
                              ),
                              child: Icon(
                                Icons.my_location_outlined,
                                size: 28,
                                color: colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                              ),
                              child: Text(
                                l10n.homeMapPreviewStatus,
                                style: textTheme.labelMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
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

class _MapPreviewCanvas extends StatelessWidget {
  const _MapPreviewCanvas({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.surfaceContainerHighest.withValues(alpha: 0.85),
            colorScheme.primaryContainer.withValues(alpha: 0.35),
          ],
        ),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: CustomPaint(
        painter: _MapGridPainter(
          lineColor: colorScheme.outlineVariant.withValues(alpha: 0.28),
        ),
      ),
    );
  }
}

class _MapGridPainter extends CustomPainter {
  _MapGridPainter({required this.lineColor});

  final Color lineColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 1;

    const step = 36.0;
    for (var x = 0.0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = 0.0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _MapGridPainter oldDelegate) => false;
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

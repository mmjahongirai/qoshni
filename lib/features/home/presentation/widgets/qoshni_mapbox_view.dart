import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:qoshni/core/config/mapbox_access_config.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/theme/app_tokens.dart';
import 'package:qoshni/features/home/presentation/map/qoshni_map_defaults.dart';

/// Mapbox [MapWidget] when configured; otherwise a localized setup placeholder.
class QoshniMapboxView extends StatefulWidget {
  const QoshniMapboxView({
    this.showDefaultViewLabel = true,
    super.key,
  });

  final bool showDefaultViewLabel;

  @override
  State<QoshniMapboxView> createState() => _QoshniMapboxViewState();
}

class _QoshniMapboxViewState extends State<QoshniMapboxView> {
  String? _loadErrorKey;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (!MapboxAccessConfig.isConfigured) {
      return MapboxConfigurationPlaceholder(l10n: l10n);
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        MapWidget(
          key: const ValueKey('qoshni-mapbox-map'),
          styleUri: MapboxStyles.MAPBOX_STREETS,
          viewport: QoshniMapDefaults.uzbekistanViewport,
          gestureRecognizers: _mapGestureRecognizers,
          onMapLoadErrorListener: (event) {
            if (!mounted) {
              return;
            }
            setState(() => _loadErrorKey = event.type.name);
          },
        ),
        if (_loadErrorKey != null)
          ColoredBox(
            color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.92),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Text(
                  l10n.mapboxLoadErrorBody,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        if (widget.showDefaultViewLabel && _loadErrorKey == null)
          Positioned(
            left: AppSpacing.sm,
            top: AppSpacing.sm,
            child: Material(
              color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
              borderRadius: AppRadius.mdAll,
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xxs,
                ),
                child: Text(
                  l10n.mapboxDefaultViewLabel,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

final Set<Factory<OneSequenceGestureRecognizer>> _mapGestureRecognizers = {
  Factory<EagerGestureRecognizer>(() => EagerGestureRecognizer()),
};

class MapboxConfigurationPlaceholder extends StatelessWidget {
  const MapboxConfigurationPlaceholder({
    required this.l10n,
    super.key,
  });

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.6),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.map_outlined, size: 40, color: scheme.primary),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n.mapboxConfigRequiredTitle,
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                l10n.mapboxConfigRequiredBody,
                style: textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  height: 1.35,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

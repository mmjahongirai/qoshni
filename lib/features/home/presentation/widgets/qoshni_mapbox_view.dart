import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:qoshni/core/config/mapbox_access_config.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/theme/app_tokens.dart';
import 'package:qoshni/features/home/presentation/map/qoshni_map_branch_marker.dart';
import 'package:qoshni/features/home/presentation/map/qoshni_map_defaults.dart';
import 'package:qoshni/features/search/domain/qoshni_search_location.dart';

/// Mapbox [MapWidget] when configured; otherwise a localized setup placeholder.
class QoshniMapboxView extends StatefulWidget {
  const QoshniMapboxView({
    this.showDefaultViewLabel = true,
    this.deviceLocationLabel,
    this.viewportController,
    this.userLocation,
    this.branchMarkers = const [],
    this.mapInstanceKey = 'default',
    super.key,
  });

  final bool showDefaultViewLabel;
  final String? deviceLocationLabel;
  final ViewportController? viewportController;
  final QoshniSearchLocation? userLocation;
  final List<QoshniMapBranchMarker> branchMarkers;
  final String mapInstanceKey;

  @override
  State<QoshniMapboxView> createState() => _QoshniMapboxViewState();
}

class _QoshniMapboxViewState extends State<QoshniMapboxView> {
  String? _loadErrorKey;
  MapboxMap? _mapboxMap;
  PointAnnotationManager? _pointManager;
  bool _annotationSyncScheduled = false;

  @override
  void didUpdateWidget(covariant QoshniMapboxView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userLocation != widget.userLocation ||
        !_branchMarkersEqual(oldWidget.branchMarkers, widget.branchMarkers)) {
      _scheduleAnnotationSync();
    }
  }

  bool _branchMarkersEqual(
    List<QoshniMapBranchMarker> a,
    List<QoshniMapBranchMarker> b,
  ) {
    if (a.length != b.length) {
      return false;
    }
    for (var i = 0; i < a.length; i++) {
      if (a[i].stableId != b[i].stableId) {
        return false;
      }
    }
    return true;
  }

  void _scheduleAnnotationSync() {
    if (_mapboxMap == null || _annotationSyncScheduled) {
      return;
    }
    _annotationSyncScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _annotationSyncScheduled = false;
      if (!mounted || _mapboxMap == null) {
        return;
      }
      await _syncPointAnnotations(_mapboxMap!);
    });
  }

  Future<void> _syncPointAnnotations(MapboxMap map) async {
    _pointManager ??= await map.annotations.createPointAnnotationManager();
    await _pointManager!.deleteAll();

    final scheme = Theme.of(context).colorScheme;
    final user = widget.userLocation;
    if (user != null) {
      await _pointManager!.create(
        PointAnnotationOptions(
          geometry: Point(
            coordinates: Position(user.longitude, user.latitude),
          ),
          textField: '●',
          textSize: 18,
          textColor: scheme.primary.toARGB32(),
          textHaloColor: scheme.surface.toARGB32(),
          textHaloWidth: 1.5,
        ),
      );
    }

    for (final marker in widget.branchMarkers) {
      await _pointManager!.create(
        PointAnnotationOptions(
          geometry: Point(
            coordinates: Position(
              marker.location.longitude,
              marker.location.latitude,
            ),
          ),
          textField: '▪',
          textSize: 14,
          textColor: scheme.secondary.toARGB32(),
          textHaloColor: scheme.surface.toARGB32(),
          textHaloWidth: 1,
        ),
      );
    }
  }

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
          key: ValueKey('qoshni-mapbox-map-${widget.mapInstanceKey}'),
          styleUri: MapboxStyles.MAPBOX_STREETS,
          viewport: QoshniMapDefaults.uzbekistanViewport,
          viewportController: widget.viewportController,
          gestureRecognizers: _mapGestureRecognizers,
          onMapCreated: (map) async {
            _mapboxMap = map;
            await _syncPointAnnotations(map);
          },
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
        if (_loadErrorKey == null && widget.showDefaultViewLabel)
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
                  l10n.mapboxDefaultViewNotYourLocation,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
            ),
          ),
        if (_loadErrorKey == null &&
            !widget.showDefaultViewLabel &&
            widget.deviceLocationLabel != null)
          Positioned(
            left: AppSpacing.sm,
            top: AppSpacing.sm,
            child: Material(
              color: Theme.of(context).colorScheme.primaryContainer
                  .withValues(alpha: 0.95),
              borderRadius: AppRadius.mdAll,
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xxs,
                ),
                child: Text(
                  widget.deviceLocationLabel!,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
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
              const SizedBox(height: AppSpacing.xxs),
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

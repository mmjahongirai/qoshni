import 'package:flutter/material.dart';
import 'package:qoshni/core/config/mapbox_access_config.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/theme/app_tokens.dart';
import 'package:qoshni/core/widgets/app_surface_card.dart';
import 'package:qoshni/core/widgets/demo_content_badge.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/features/home/presentation/data/home_essential_place.dart';
import 'package:qoshni/features/home/presentation/map/qoshni_map_location_messages.dart';
import 'package:qoshni/features/home/presentation/map/qoshni_map_route_intent.dart';
import 'package:qoshni/features/home/presentation/map/qoshni_map_viewport_actions.dart';
import 'package:qoshni/features/home/presentation/widgets/qoshni_mapbox_view.dart';
import 'package:qoshni/features/location/application/qoshni_map_location_controller.dart';
import 'package:qoshni/features/location/domain/qoshni_location_failure.dart';
import 'package:qoshni/features/search/domain/qoshni_search_location.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

/// Home map preview wired to explicit device-location actions (Phase 17).
class MapPreviewCard extends StatefulWidget {
  const MapPreviewCard({
    required this.l10n,
    required this.onOpenMap,
    super.key,
  });

  final AppLocalizations l10n;
  final void Function(QoshniMapRouteIntent intent) onOpenMap;

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
  State<MapPreviewCard> createState() => _MapPreviewCardState();
}

class _MapPreviewCardState extends State<MapPreviewCard> {
  final ViewportController _viewportController = ViewportController();
  late final QoshniMapLocationController _location;

  @override
  void initState() {
    super.initState();
    _location = getIt<QoshniMapLocationController>();
    _location.addListener(_onLocationChanged);
  }

  @override
  void dispose() {
    _location.removeListener(_onLocationChanged);
    _viewportController.dispose();
    super.dispose();
  }

  void _onLocationChanged() {
    final snapshot = _location.deviceSnapshot;
    if (snapshot != null && snapshot.isDeviceDerived) {
      qoshniMapViewportFlyToDeviceSnapshot(_viewportController, snapshot);
    }
    if (mounted) {
      setState(() {});
    }
  }

  QoshniSearchLocation? _userMapLocation() {
    final snapshot = _location.deviceSnapshot;
    if (snapshot == null || !snapshot.isDeviceDerived) {
      return null;
    }
    return QoshniSearchLocation(
      latitude: snapshot.coordinates.latitude,
      longitude: snapshot.coordinates.longitude,
    );
  }

  Future<void> _onLocateTap() async {
    await _location.requestDeviceLocation();
  }

  void _onOpenMapTap() {
    if (!_location.isAcquiring) {
      _location.requestDeviceLocation();
    }
    widget.onOpenMap(
      const QoshniMapRouteIntent(requestDeviceLocationOnOpen: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final legend = buildHomeMapLegendEntries(l10n, colorScheme);
    final mapConfigured = MapboxAccessConfig.isConfigured;
    final statusMessage = qoshniHomeMapPreviewStatusMessage(
      l10n,
      mapboxConfigured: mapConfigured,
      location: _location,
    );
    final showDeviceLabel = !_location.showDefaultMapViewLabel;
    final phase = _location.phase;
    final failure = _location.lastFailure;
    final failureMessage = qoshniMapLocationFailureMessage(l10n, failure);

    return ListenableBuilder(
      listenable: _location,
      builder: (context, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final mapHeight = MapPreviewCard.mapCanvasHeight(constraints.maxWidth);

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
                          QoshniMapboxView(
                            mapInstanceKey: 'home-preview',
                            showDefaultViewLabel: _location.showDefaultMapViewLabel,
                            deviceLocationLabel:
                                showDeviceLabel ? l10n.mapLocationDeviceFixLabel : null,
                            viewportController: _viewportController,
                            userLocation: _userMapLocation(),
                          ),
                          if (phase == QoshniMapLocationUiPhase.acquiring)
                            ColoredBox(
                              color: colorScheme.surface.withValues(alpha: 0.35),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: colorScheme.primary,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    statusMessage,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                  if (phase == QoshniMapLocationUiPhase.failed &&
                      failureMessage != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Wrap(
                      spacing: AppSpacing.sm,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          failureMessage,
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.error,
                            height: 1.35,
                          ),
                        ),
                        TextButton(
                          onPressed: _location.isAcquiring ? null : _onLocateTap,
                          child: Text(l10n.mapLocationRetry),
                        ),
                        if (failure?.reason ==
                            QoshniLocationFailureReason.permissionPermanentlyDenied)
                          TextButton(
                            onPressed: _location.openAppSettingsFromUserChoice,
                            child: Text(l10n.mapLocationOpenSettings),
                          ),
                      ],
                    ),
                  ],
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
                  OutlinedButton.icon(
                    onPressed: _location.isAcquiring ? null : _onLocateTap,
                    icon: phase == QoshniMapLocationUiPhase.acquiring
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colorScheme.primary,
                            ),
                          )
                        : const Icon(Icons.my_location_outlined, size: 20),
                    label: Text(l10n.mapLocationMyLocationAction),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  FilledButton.icon(
                    onPressed: _onOpenMapTap,
                    icon: const Icon(Icons.map_outlined, size: 20),
                    label: Text(l10n.openMap),
                  ),
                ],
              ),
            );
          },
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

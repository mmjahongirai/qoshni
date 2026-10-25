import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/theme/app_tokens.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/features/home/presentation/widgets/qoshni_mapbox_view.dart';
import 'package:qoshni/features/location/application/qoshni_map_location_controller.dart';
import 'package:qoshni/features/location/application/qoshni_geocoding_service.dart';
import 'package:qoshni/features/location/application/qoshni_saved_places_controller.dart';
import 'package:qoshni/features/location/domain/qoshni_location_failure.dart';
import 'package:qoshni/features/location/presentation/qoshni_geocode_save_sheet.dart';
import 'package:qoshni/features/search/application/qoshni_search_map_focus_controller.dart';

/// Full-screen map route — Mapbox when configured, otherwise setup placeholder.
class MapPlaceholderPage extends StatefulWidget {
  const MapPlaceholderPage({super.key});

  @override
  State<MapPlaceholderPage> createState() => _MapPlaceholderPageState();
}

class _MapPlaceholderPageState extends State<MapPlaceholderPage> {
  final ViewportController _viewportController = ViewportController();
  late final QoshniMapLocationController _locationController;
  late final QoshniSearchMapFocusController _searchMapFocus;

  @override
  void initState() {
    super.initState();
    _locationController = getIt<QoshniMapLocationController>();
    _searchMapFocus = getIt<QoshniSearchMapFocusController>();
    _locationController.addListener(_onLocationSessionChanged);
    _searchMapFocus.addListener(_onSearchMapFocusChanged);
    getIt<QoshniSavedPlacesController>().refresh();
    _applySearchMapFocusIfNeeded();
  }

  @override
  void dispose() {
    _searchMapFocus.removeListener(_onSearchMapFocusChanged);
    _locationController.removeListener(_onLocationSessionChanged);
    _viewportController.dispose();
    super.dispose();
  }

  void _onSearchMapFocusChanged() {
    _applySearchMapFocusIfNeeded();
  }

  void _applySearchMapFocusIfNeeded() {
    final focus = _searchMapFocus.location;
    if (focus == null) {
      return;
    }
    _viewportController.moveTo(
      CameraViewportState(
        center: Point(
          coordinates: Position(focus.longitude, focus.latitude),
        ),
        zoom: 15,
      ),
      transition: const FlyViewportTransition(
        duration: Duration(milliseconds: 900),
      ),
    );
    if (mounted) {
      setState(() {});
    }
  }

  void _onLocationSessionChanged() {
    final snapshot = _locationController.deviceSnapshot;
    if (snapshot != null && snapshot.isDeviceDerived) {
      _viewportController.moveTo(
        CameraViewportState(
          center: Point(
            coordinates: Position(
              snapshot.coordinates.longitude,
              snapshot.coordinates.latitude,
            ),
          ),
          zoom: 14,
        ),
        transition: const FlyViewportTransition(
          duration: Duration(milliseconds: 900),
        ),
      );
    }
    if (mounted) {
      setState(() {});
    }
  }

  String? _failureMessage(AppLocalizations l10n, QoshniLocationFailure? failure) {
    if (failure == null) {
      return null;
    }
    switch (failure.reason) {
      case QoshniLocationFailureReason.permissionDenied:
        return l10n.mapLocationPermissionDenied;
      case QoshniLocationFailureReason.permissionPermanentlyDenied:
        return l10n.mapLocationPermissionDeniedForever;
      case QoshniLocationFailureReason.locationServicesDisabled:
        return l10n.mapLocationServicesDisabled;
      case QoshniLocationFailureReason.timeout:
        return l10n.mapLocationTimeout;
      case QoshniLocationFailureReason.positionUnavailable:
        return l10n.mapLocationUnavailable;
      case QoshniLocationFailureReason.unknown:
        return l10n.mapLocationUnavailable;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final phase = _locationController.phase;
    final failureMessage = _failureMessage(l10n, _locationController.lastFailure);
    final showDeviceLabel = !_locationController.showDefaultMapViewLabel;
    final searchFocusTitle = _searchMapFocus.title;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(l10n.mapPlaceholderTitle),
        actions: [
          IconButton(
            tooltip: l10n.mapLocationMyLocationAction,
            onPressed: phase == QoshniMapLocationUiPhase.acquiring
                ? null
                : () => _locationController.requestDeviceLocation(),
            icon: phase == QoshniMapLocationUiPhase.acquiring
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.my_location_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: QoshniMapboxView(
                showDefaultViewLabel: _locationController.showDefaultMapViewLabel &&
                    !_searchMapFocus.hasFocus,
                deviceLocationLabel: _searchMapFocus.hasFocus
                    ? l10n.searchMapVerifiedBranchFocusLabel(
                        searchFocusTitle ?? '',
                      )
                    : (showDeviceLabel ? l10n.mapLocationDeviceFixLabel : null),
                viewportController: _viewportController,
              ),
            ),
            if (phase == QoshniMapLocationUiPhase.acquiring)
              _MapLocationStatusBar(message: l10n.mapLocationAcquiring),
            _MapSavedPlacesToolbar(
              l10n: l10n,
              onSearchAddress: () => showQoshniGeocodeSaveSheet(
                context,
                geocodingService: getIt<QoshniGeocodingService>(),
                savedPlacesController: getIt<QoshniSavedPlacesController>(),
              ),
            ),
            if (phase == QoshniMapLocationUiPhase.failed && failureMessage != null)
              _MapLocationFailureBar(
                message: failureMessage,
                showOpenSettings: _locationController.lastFailure?.reason ==
                    QoshniLocationFailureReason.permissionPermanentlyDenied,
                onRetry: () => _locationController.retry(),
                onOpenSettings: () =>
                    _locationController.openAppSettingsFromUserChoice(),
                retryLabel: l10n.mapLocationRetry,
                openSettingsLabel: l10n.mapLocationOpenSettings,
              ),
          ],
        ),
      ),
    );
  }
}

class _MapSavedPlacesToolbar extends StatelessWidget {
  const _MapSavedPlacesToolbar({
    required this.l10n,
    required this.onSearchAddress,
  });

  final AppLocalizations l10n;
  final VoidCallback onSearchAddress;

  @override
  Widget build(BuildContext context) {
    final savedPlaces = getIt<QoshniSavedPlacesController>();
    return ListenableBuilder(
      listenable: savedPlaces,
      builder: (context, _) {
        return Material(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xxs,
            ),
            child: Row(
              children: [
                TextButton.icon(
                  onPressed: onSearchAddress,
                  icon: const Icon(Icons.travel_explore_outlined, size: 20),
                  label: Text(l10n.geocodingSearchTitle),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    l10n.savedPlacesCountLabel(savedPlaces.places.length),
                    style: Theme.of(context).textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MapLocationStatusBar extends StatelessWidget {
  const _MapLocationStatusBar({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: scheme.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }
}

class _MapLocationFailureBar extends StatelessWidget {
  const _MapLocationFailureBar({
    required this.message,
    required this.showOpenSettings,
    required this.onRetry,
    required this.onOpenSettings,
    required this.retryLabel,
    required this.openSettingsLabel,
  });

  final String message;
  final bool showOpenSettings;
  final VoidCallback onRetry;
  final VoidCallback onOpenSettings;
  final String retryLabel;
  final String openSettingsLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              message,
              style: TextStyle(color: scheme.onErrorContainer),
            ),
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: AppSpacing.sm,
              children: [
                TextButton(onPressed: onRetry, child: Text(retryLabel)),
                if (showOpenSettings)
                  TextButton(
                    onPressed: onOpenSettings,
                    child: Text(openSettingsLabel),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

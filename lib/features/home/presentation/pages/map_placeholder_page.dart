import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/theme/app_tokens.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/features/home/presentation/data/home_mock_data.dart';
import 'package:qoshni/features/home/presentation/map/qoshni_map_branch_marker.dart';
import 'package:qoshni/features/home/presentation/map/qoshni_map_location_messages.dart';
import 'package:qoshni/features/home/presentation/map/qoshni_map_nearby_loader.dart';
import 'package:qoshni/features/home/presentation/map/qoshni_map_route_intent.dart';
import 'package:qoshni/features/home/presentation/map/qoshni_map_viewport_actions.dart';
import 'package:qoshni/features/home/presentation/widgets/qoshni_mapbox_view.dart';
import 'package:qoshni/features/location/application/qoshni_geocoding_service.dart';
import 'package:qoshni/features/location/application/qoshni_map_location_controller.dart';
import 'package:qoshni/features/location/application/qoshni_saved_places_controller.dart';
import 'package:qoshni/features/location/domain/qoshni_current_location_snapshot.dart';
import 'package:qoshni/features/location/domain/qoshni_location_failure.dart';
import 'package:qoshni/features/location/presentation/qoshni_geocode_save_sheet.dart';
import 'package:qoshni/features/search/application/qoshni_search_execution_coordinator.dart';
import 'package:qoshni/features/search/application/qoshni_search_map_focus_controller.dart';
import 'package:qoshni/features/search/application/qoshni_search_query_processor.dart';
import 'package:qoshni/features/search/domain/qoshni_search_location.dart';

/// Full-screen map route — Mapbox when configured, otherwise setup placeholder.
class MapPlaceholderPage extends StatefulWidget {
  const MapPlaceholderPage({
    this.intent = const QoshniMapRouteIntent(),
    super.key,
  });

  final QoshniMapRouteIntent intent;

  @override
  State<MapPlaceholderPage> createState() => _MapPlaceholderPageState();
}

class _MapPlaceholderPageState extends State<MapPlaceholderPage> {
  final ViewportController _viewportController = ViewportController();
  late final QoshniMapLocationController _locationController;
  late final QoshniSearchMapFocusController _searchMapFocus;

  List<QoshniMapBranchMarker> _verifiedBranchMarkers = const [];
  bool _loadingNearby = false;
  int _nearbyLoadGeneration = 0;

  @override
  void initState() {
    super.initState();
    _locationController = getIt<QoshniMapLocationController>();
    _searchMapFocus = getIt<QoshniSearchMapFocusController>();
    _locationController.addListener(_onLocationSessionChanged);
    _searchMapFocus.addListener(_onSearchMapFocusChanged);
    getIt<QoshniSavedPlacesController>().refresh();
    _applySearchMapFocusIfNeeded();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final snapshot = _locationController.deviceSnapshot;
      if (snapshot != null && snapshot.isDeviceDerived) {
        _refreshVerifiedNearbyMarkers(snapshot);
      } else if (widget.intent.requestDeviceLocationOnOpen &&
          _locationController.phase != QoshniMapLocationUiPhase.deviceFixReady) {
        _locationController.requestDeviceLocation();
      }
    });
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
    qoshniMapViewportFlyToSearchLocation(_viewportController, focus, zoom: 15);
    if (mounted) {
      setState(() {});
    }
  }

  void _onLocationSessionChanged() {
    final snapshot = _locationController.deviceSnapshot;
    if (snapshot != null && snapshot.isDeviceDerived) {
      qoshniMapViewportFlyToDeviceSnapshot(_viewportController, snapshot);
      _refreshVerifiedNearbyMarkers(snapshot);
    }
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _refreshVerifiedNearbyMarkers(
    QoshniCurrentLocationSnapshot snapshot,
  ) async {
    final generation = ++_nearbyLoadGeneration;
    setState(() => _loadingNearby = true);
    final l10n = AppLocalizations.of(context);
    final catalog = buildSearchCatalog(l10n, Theme.of(context).colorScheme);
    final markers = await qoshniLoadVerifiedMapBranchMarkers(
      execution: getIt<QoshniSearchExecutionCoordinator>(),
      queryProcessor: getIt<QoshniSearchQueryProcessor>(),
      catalog: catalog,
      deviceSnapshot: snapshot,
    );
    if (!mounted || generation != _nearbyLoadGeneration) {
      return;
    }
    setState(() {
      _loadingNearby = false;
      _verifiedBranchMarkers = markers;
    });
  }

  QoshniSearchLocation? _userMapLocation() {
    final snapshot = _locationController.deviceSnapshot;
    if (snapshot == null || !snapshot.isDeviceDerived) {
      return null;
    }
    return QoshniSearchLocation(
      latitude: snapshot.coordinates.latitude,
      longitude: snapshot.coordinates.longitude,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final phase = _locationController.phase;
    final failureMessage =
        qoshniMapLocationFailureMessage(l10n, _locationController.lastFailure);
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
                mapInstanceKey: 'full',
                showDefaultViewLabel: _locationController.showDefaultMapViewLabel &&
                    !_searchMapFocus.hasFocus,
                deviceLocationLabel: _searchMapFocus.hasFocus
                    ? l10n.searchMapVerifiedBranchFocusLabel(
                        searchFocusTitle ?? '',
                      )
                    : (showDeviceLabel ? l10n.mapLocationDeviceFixLabel : null),
                viewportController: _viewportController,
                userLocation: _userMapLocation(),
                branchMarkers: _verifiedBranchMarkers,
              ),
            ),
            if (phase == QoshniMapLocationUiPhase.acquiring)
              _MapLocationStatusBar(message: l10n.mapLocationAcquiring),
            if (_loadingNearby)
              _MapLocationStatusBar(
                message: l10n.mapNearbyLoadingVerified,
                showProgress: true,
              ),
            if (showDeviceLabel &&
                !_loadingNearby &&
                _verifiedBranchMarkers.isEmpty)
              _MapLocationStatusBar(
                message: l10n.mapNearbyNoVerifiedBranches,
                showProgress: false,
              ),
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
  const _MapLocationStatusBar({
    required this.message,
    this.showProgress = true,
  });

  final String message;
  final bool showProgress;

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
            if (showProgress) ...[
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: scheme.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
            ],
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

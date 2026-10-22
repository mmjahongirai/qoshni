import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

/// Default map camera — Uzbekistan country view (not device location).
abstract final class QoshniMapDefaults {
  /// Approximate geographic center of Uzbekistan.
  static final Point uzbekistanCenter = Point(
    coordinates: Position(64.5853, 41.3775),
  );

  static const double uzbekistanCountryZoom = 5.4;

  static CameraViewportState get uzbekistanViewport => CameraViewportState(
        center: uzbekistanCenter,
        zoom: uzbekistanCountryZoom,
      );
}

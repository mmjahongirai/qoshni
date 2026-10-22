import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:qoshni/core/config/mapbox_access_config.dart';

/// Initializes Mapbox SDK once before any [MapWidget] is built.
void initializeMapboxIfConfigured() {
  if (!MapboxAccessConfig.isConfigured) {
    return;
  }
  MapboxOptions.setAccessToken(MapboxAccessConfig.accessToken.trim());
}

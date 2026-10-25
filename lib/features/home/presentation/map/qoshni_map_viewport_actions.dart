import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:qoshni/features/location/domain/qoshni_current_location_snapshot.dart';
import 'package:qoshni/features/search/domain/qoshni_search_location.dart';

void qoshniMapViewportFlyToSearchLocation(
  ViewportController controller,
  QoshniSearchLocation location, {
  double zoom = 14,
}) {
  controller.moveTo(
    CameraViewportState(
      center: Point(
        coordinates: Position(location.longitude, location.latitude),
      ),
      zoom: zoom,
    ),
    transition: const FlyViewportTransition(
      duration: Duration(milliseconds: 900),
    ),
  );
}

void qoshniMapViewportFlyToDeviceSnapshot(
  ViewportController controller,
  QoshniCurrentLocationSnapshot snapshot, {
  double zoom = 14,
}) {
  qoshniMapViewportFlyToSearchLocation(
    controller,
    QoshniSearchLocation(
      latitude: snapshot.coordinates.latitude,
      longitude: snapshot.coordinates.longitude,
    ),
    zoom: zoom,
  );
}

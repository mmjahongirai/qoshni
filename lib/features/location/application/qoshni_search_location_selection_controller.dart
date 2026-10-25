import 'package:flutter/foundation.dart';
import 'package:qoshni/features/location/application/qoshni_map_location_controller.dart';
import 'package:qoshni/features/location/domain/qoshni_location_search_policy.dart';
import 'package:qoshni/features/location/domain/qoshni_saved_place.dart';
import 'package:qoshni/features/location/domain/qoshni_search_location_origin.dart';
import 'package:qoshni/features/search/domain/qoshni_search_filters.dart';
import 'package:qoshni/features/search/domain/qoshni_search_location.dart';

/// Explicit nearby-search anchor for Search — not persisted server-side.
class QoshniSearchLocationSelectionController extends ChangeNotifier {
  QoshniSearchLocationOrigin origin = const QoshniSearchLocationOrigin.none();
  int nearbyRadiusMeters = kQoshniSearchDefaultNearbyRadiusMeters;
  bool nearbySearchEnabled = false;

  void clear() {
    origin = const QoshniSearchLocationOrigin.none();
    nearbySearchEnabled = false;
    notifyListeners();
  }

  void enableNearbyWithoutOrigin() {
    nearbySearchEnabled = true;
    notifyListeners();
  }

  void useDeviceFix(QoshniMapLocationController mapController) {
    final snapshot = mapController.deviceSnapshot;
    if (snapshot == null || !snapshot.isDeviceDerived) {
      return;
    }
    origin = QoshniSearchLocationOrigin.deviceFix(
      QoshniSearchLocation(
        latitude: snapshot.coordinates.latitude,
        longitude: snapshot.coordinates.longitude,
      ),
    );
    nearbySearchEnabled = true;
    notifyListeners();
  }

  void useSavedPlace(QoshniSavedPlace place) {
    origin = QoshniSearchLocationOrigin.savedPlace(place);
    nearbySearchEnabled = true;
    notifyListeners();
  }

  void setRadiusMeters(int value) {
    nearbyRadiusMeters = value.clamp(
      kQoshniSearchMinRadiusMeters,
      kQoshniSearchMaxRadiusMeters,
    );
    notifyListeners();
  }

  QoshniSearchFilters applyTo(QoshniSearchFilters base) {
    if (!nearbySearchEnabled || !origin.isActive || origin.location == null) {
      return base;
    }
    return QoshniSearchFilters(
      categoryScope: base.categoryScope,
      onlyOpen: base.onlyOpen,
      maxDistanceMeters: nearbyRadiusMeters,
      searchLocation: origin.location,
    );
  }
}

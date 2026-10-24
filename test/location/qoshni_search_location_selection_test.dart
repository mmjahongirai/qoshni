import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/features/location/application/qoshni_search_location_selection_controller.dart';
import 'package:qoshni/features/location/domain/qoshni_geo_coordinates.dart';
import 'package:qoshni/features/location/domain/qoshni_saved_place.dart';
import 'package:qoshni/features/search/domain/qoshni_search_filters.dart';

void main() {
  test('nearby filters apply only when origin is active', () {
    final selection = QoshniSearchLocationSelectionController();
    selection.enableNearbyWithoutOrigin();
    final withoutOrigin = selection.applyTo(const QoshniSearchFilters());
    expect(withoutOrigin.searchLocation, isNull);

    final place = QoshniSavedPlace(
      id: 'p1',
      ownerUserId: 'u1',
      label: 'Work',
      coordinates: QoshniGeoCoordinates.create(latitude: 41.31, longitude: 69.28),
    );
    selection.useSavedPlace(place);
    final withOrigin = selection.applyTo(const QoshniSearchFilters());
    expect(withOrigin.searchLocation?.latitude, 41.31);
    expect(withOrigin.maxDistanceMeters, isNotNull);
  });
}

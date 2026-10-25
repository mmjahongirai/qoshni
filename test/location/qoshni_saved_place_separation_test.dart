import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/features/home/presentation/map/qoshni_map_defaults.dart';
import 'package:qoshni/features/location/domain/qoshni_current_location_snapshot.dart';
import 'package:qoshni/features/location/domain/qoshni_geo_coordinates.dart';
import 'package:qoshni/features/location/domain/qoshni_location_kind.dart';
import 'package:qoshni/features/location/domain/qoshni_location_source.dart';
import 'package:qoshni/features/location/domain/qoshni_saved_place.dart';

void main() {
  test('saved place is not a current location snapshot', () {
    final coords = QoshniGeoCoordinates.create(latitude: 41.0, longitude: 69.0);
    final saved = QoshniSavedPlace(
      id: 'home',
      ownerUserId: 'user-1',
      label: 'Home',
      coordinates: coords,
    );
    final current = QoshniCurrentLocationSnapshot(
      coordinates: coords,
      kind: QoshniLocationKind.deviceCurrent,
      source: QoshniLocationSource.gps,
      acquiredAt: DateTime.utc(2026),
    );

    expect(saved, isNot(isA<QoshniCurrentLocationSnapshot>()));
    expect(current.isVerifiedDeliveryAddress, isFalse);
    expect(saved.label, 'Home');
  });

  test('static map default viewport is not reported as device location', () {
    final viewport = QoshniMapDefaults.uzbekistanViewport;
    expect(viewport, isNot(isA<QoshniCurrentLocationSnapshot>()));
  });
}

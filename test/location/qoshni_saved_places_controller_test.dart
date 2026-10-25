import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/features/location/data/in_memory_qoshni_saved_place_repository.dart';
import 'package:qoshni/features/location/domain/qoshni_current_location_snapshot.dart';
import 'package:qoshni/features/location/domain/qoshni_geo_coordinates.dart';
import 'package:qoshni/features/location/domain/qoshni_location_kind.dart';
import 'package:qoshni/features/location/domain/qoshni_location_source.dart';

void main() {
  test('saved place stays stable when transient GPS snapshot changes', () async {
    final repo = InMemoryQoshniSavedPlaceRepository(ownerUserId: 'user-1');
    final saved = await repo.create(
      label: 'Home',
      coordinates: QoshniGeoCoordinates.create(latitude: 41.3, longitude: 69.2),
    );

    final gps = QoshniCurrentLocationSnapshot(
      coordinates: QoshniGeoCoordinates.create(latitude: 40.0, longitude: 64.0),
      kind: QoshniLocationKind.deviceCurrent,
      source: QoshniLocationSource.gps,
      acquiredAt: DateTime.utc(2026),
    );

    expect(gps.coordinates, isNot(saved.coordinates));
    final listed = await repo.listForCurrentUser();
    expect(listed.single.label, 'Home');
    expect(listed.single.coordinates.latitude, 41.3);
  });
}

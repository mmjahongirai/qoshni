import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/features/location/domain/qoshni_geo_coordinates.dart';

void main() {
  group('QoshniGeoCoordinates', () {
    test('accepts valid bounds', () {
      final coords = QoshniGeoCoordinates.tryCreate(
        latitude: 41.3,
        longitude: 69.2,
      );
      expect(coords, isNotNull);
      expect(coords!.latitude, 41.3);
    });

    test('rejects out-of-range latitude', () {
      expect(
        QoshniGeoCoordinates.tryCreate(latitude: 91, longitude: 0),
        isNull,
      );
    });

    test('rejects out-of-range longitude', () {
      expect(
        QoshniGeoCoordinates.tryCreate(latitude: 0, longitude: -181),
        isNull,
      );
    });

    test('rejects non-finite values', () {
      expect(
        QoshniGeoCoordinates.tryCreate(
          latitude: double.nan,
          longitude: 0,
        ),
        isNull,
      );
    });
  });
}

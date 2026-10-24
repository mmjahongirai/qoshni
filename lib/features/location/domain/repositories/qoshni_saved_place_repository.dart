import 'package:qoshni/features/location/domain/qoshni_geo_coordinates.dart';
import 'package:qoshni/features/location/domain/qoshni_saved_place.dart';

abstract class QoshniSavedPlaceRepository {
  Future<List<QoshniSavedPlace>> listForCurrentUser();

  Future<QoshniSavedPlace> create({
    required String label,
    required QoshniGeoCoordinates coordinates,
    String? addressDescription,
  });

  Future<QoshniSavedPlace> update({
    required String placeId,
    String? label,
    QoshniGeoCoordinates? coordinates,
    String? addressDescription,
    bool clearAddressDescription = false,
  });

  Future<void> delete({required String placeId});
}

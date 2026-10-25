import 'package:qoshni/features/location/domain/qoshni_geo_coordinates.dart';
import 'package:qoshni/features/location/domain/qoshni_saved_place.dart';
import 'package:qoshni/features/location/domain/repositories/qoshni_saved_place_repository.dart';

/// Session-scoped demo store when the backend API is unavailable.
class InMemoryQoshniSavedPlaceRepository implements QoshniSavedPlaceRepository {
  InMemoryQoshniSavedPlaceRepository({required String ownerUserId})
      : _ownerUserId = ownerUserId;

  final String _ownerUserId;
  final Map<String, QoshniSavedPlace> _places = {};
  var _seq = 0;

  @override
  Future<List<QoshniSavedPlace>> listForCurrentUser() async {
    return _places.values.toList(growable: false);
  }

  @override
  Future<QoshniSavedPlace> create({
    required String label,
    required QoshniGeoCoordinates coordinates,
    String? addressDescription,
  }) async {
    final id = 'local-${++_seq}';
    final place = QoshniSavedPlace(
      id: id,
      ownerUserId: _ownerUserId,
      label: label,
      coordinates: coordinates,
      addressDescription: addressDescription,
      createdAt: DateTime.now().toUtc(),
      updatedAt: DateTime.now().toUtc(),
    );
    _places[id] = place;
    return place;
  }

  @override
  Future<QoshniSavedPlace> update({
    required String placeId,
    String? label,
    QoshniGeoCoordinates? coordinates,
    String? addressDescription,
    bool clearAddressDescription = false,
  }) async {
    final existing = _places[placeId];
    if (existing == null) {
      throw StateError('Saved place not found');
    }
    final updated = QoshniSavedPlace(
      id: existing.id,
      ownerUserId: existing.ownerUserId,
      label: label ?? existing.label,
      coordinates: coordinates ?? existing.coordinates,
      addressDescription: clearAddressDescription
          ? null
          : (addressDescription ?? existing.addressDescription),
      createdAt: existing.createdAt,
      updatedAt: DateTime.now().toUtc(),
    );
    _places[placeId] = updated;
    return updated;
  }

  @override
  Future<void> delete({required String placeId}) async {
    _places.remove(placeId);
  }
}

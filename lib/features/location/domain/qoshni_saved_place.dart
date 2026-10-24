import 'package:qoshni/features/location/domain/qoshni_geo_coordinates.dart';

/// User-owned named place — separate from transient [QoshniCurrentLocationSnapshot].
///
/// WP1 defines the contract only; no Flutter persistence layer is wired yet.
class QoshniSavedPlace {
  const QoshniSavedPlace({
    required this.id,
    required this.ownerUserId,
    required this.label,
    required this.coordinates,
    this.addressDescription,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String ownerUserId;
  final String label;
  final QoshniGeoCoordinates coordinates;
  final String? addressDescription;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}

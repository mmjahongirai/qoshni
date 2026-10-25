/// WGS-84 latitude/longitude with validated bounds.
class QoshniGeoCoordinates {
  const QoshniGeoCoordinates._({
    required this.latitude,
    required this.longitude,
  });

  final double latitude;
  final double longitude;

  static const double minLatitude = -90;
  static const double maxLatitude = 90;
  static const double minLongitude = -180;
  static const double maxLongitude = 180;

  /// Returns validated coordinates or `null` when out of range or non-finite.
  static QoshniGeoCoordinates? tryCreate({
    required double latitude,
    required double longitude,
  }) {
    if (!latitude.isFinite || !longitude.isFinite) {
      return null;
    }
    if (latitude < minLatitude ||
        latitude > maxLatitude ||
        longitude < minLongitude ||
        longitude > maxLongitude) {
      return null;
    }
    return QoshniGeoCoordinates._(
      latitude: latitude,
      longitude: longitude,
    );
  }

  static QoshniGeoCoordinates create({
    required double latitude,
    required double longitude,
  }) {
    final value = tryCreate(latitude: latitude, longitude: longitude);
    if (value == null) {
      throw ArgumentError(
        'Invalid coordinates: latitude=$latitude longitude=$longitude',
      );
    }
    return value;
  }

  @override
  bool operator ==(Object other) {
    return other is QoshniGeoCoordinates &&
        other.latitude == latitude &&
        other.longitude == longitude;
  }

  @override
  int get hashCode => Object.hash(latitude, longitude);
}

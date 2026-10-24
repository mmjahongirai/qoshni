import 'package:qoshni/features/location/domain/qoshni_geo_coordinates.dart';
import 'package:qoshni/features/location/domain/qoshni_location_kind.dart';
import 'package:qoshni/features/location/domain/qoshni_location_source.dart';

/// Transient device or map-selected position — not a saved address.
class QoshniCurrentLocationSnapshot {
  const QoshniCurrentLocationSnapshot({
    required this.coordinates,
    required this.kind,
    required this.source,
    required this.acquiredAt,
    this.accuracyMeters,
  });

  final QoshniGeoCoordinates coordinates;
  final QoshniLocationKind kind;
  final QoshniLocationSource source;
  final DateTime acquiredAt;
  final double? accuracyMeters;

  bool get isDeviceDerived =>
      kind == QoshniLocationKind.deviceCurrent &&
      source != QoshniLocationSource.mapSelection;

  bool get isVerifiedDeliveryAddress => false;
}

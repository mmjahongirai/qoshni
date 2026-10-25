import 'package:qoshni/features/location/domain/qoshni_saved_place.dart';
import 'package:qoshni/features/search/domain/qoshni_search_location.dart';

/// Explicit search anchor — never inferred from silent GPS.
enum QoshniSearchLocationOriginKind {
  none,
  deviceFix,
  savedPlace,
  manualMapPoint,
}

class QoshniSearchLocationOrigin {
  const QoshniSearchLocationOrigin.none() : this._(kind: QoshniSearchLocationOriginKind.none);

  const QoshniSearchLocationOrigin.deviceFix(QoshniSearchLocation location)
      : this._(kind: QoshniSearchLocationOriginKind.deviceFix, location: location);

  QoshniSearchLocationOrigin.savedPlace(QoshniSavedPlace place)
      : this._(
          kind: QoshniSearchLocationOriginKind.savedPlace,
          savedPlace: place,
          location: QoshniSearchLocation(
            latitude: place.coordinates.latitude,
            longitude: place.coordinates.longitude,
          ),
        );

  const QoshniSearchLocationOrigin.manualMapPoint(QoshniSearchLocation location)
      : this._(kind: QoshniSearchLocationOriginKind.manualMapPoint, location: location);

  const QoshniSearchLocationOrigin._({
    required this.kind,
    this.location,
    this.savedPlace,
  });

  final QoshniSearchLocationOriginKind kind;
  final QoshniSearchLocation? location;
  final QoshniSavedPlace? savedPlace;

  bool get isActive => kind != QoshniSearchLocationOriginKind.none;
}

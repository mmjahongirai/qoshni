import 'package:qoshni/features/location/domain/qoshni_geo_coordinates.dart';

/// Provider suggestion — not a saved place until the user confirms.
class QoshniGeocodingSuggestion {
  const QoshniGeocodingSuggestion({
    required this.id,
    required this.displayLabel,
    required this.coordinates,
  });

  final String id;
  final String displayLabel;
  final QoshniGeoCoordinates coordinates;

  bool get isUserConfirmedSavedPlace => false;
}

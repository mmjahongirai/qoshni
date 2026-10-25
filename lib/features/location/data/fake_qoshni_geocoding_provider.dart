import 'package:qoshni/features/location/domain/qoshni_geo_coordinates.dart';
import 'package:qoshni/features/location/domain/qoshni_geocoding_provider.dart';
import 'package:qoshni/features/location/domain/qoshni_geocoding_suggestion.dart';

class FakeQoshniGeocodingProvider implements QoshniGeocodingProvider {
  int forwardSearchCalls = 0;
  List<QoshniGeocodingSuggestion> nextResults = const [];
  Object? nextError;

  @override
  Future<List<QoshniGeocodingSuggestion>> forwardSearch({
    required String query,
    required Duration timeout,
  }) async {
    forwardSearchCalls += 1;
    if (nextError != null) {
      throw nextError!;
    }
    if (nextResults.isNotEmpty) {
      return nextResults;
    }
    if (query.trim().isEmpty) {
      return const [];
    }
    return [
      QoshniGeocodingSuggestion(
        id: 'fake-1',
        displayLabel: 'Fake match for $query',
        coordinates: QoshniGeoCoordinates.create(latitude: 41.31, longitude: 69.28),
      ),
    ];
  }
}

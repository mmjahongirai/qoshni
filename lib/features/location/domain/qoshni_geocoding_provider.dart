import 'package:qoshni/features/location/domain/qoshni_geocoding_suggestion.dart';

abstract class QoshniGeocodingProvider {
  Future<List<QoshniGeocodingSuggestion>> forwardSearch({
    required String query,
    required Duration timeout,
  });
}

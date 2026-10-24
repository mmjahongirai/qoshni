import 'package:dio/dio.dart';
import 'package:qoshni/core/config/mapbox_access_config.dart';
import 'package:qoshni/features/location/domain/qoshni_geo_coordinates.dart';
import 'package:qoshni/features/location/domain/qoshni_geocoding_provider.dart';
import 'package:qoshni/features/location/domain/qoshni_geocoding_suggestion.dart';

class QoshniGeocodingUnavailableException implements Exception {}

class MapboxQoshniGeocodingProvider implements QoshniGeocodingProvider {
  MapboxQoshniGeocodingProvider({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  @override
  Future<List<QoshniGeocodingSuggestion>> forwardSearch({
    required String query,
    required Duration timeout,
  }) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return const [];
    }
    if (!MapboxAccessConfig.isConfigured) {
      throw QoshniGeocodingUnavailableException();
    }
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        'https://api.mapbox.com/search/geocoding/v6/forward',
        queryParameters: {
          'q': trimmed,
          'access_token': MapboxAccessConfig.accessToken,
          'limit': 5,
          'language': 'en,ru,uz',
        },
        options: Options(
          sendTimeout: timeout,
          receiveTimeout: timeout,
        ),
      );
      final features = response.data?['features'] as List<dynamic>? ?? const [];
      final suggestions = <QoshniGeocodingSuggestion>[];
      for (final feature in features) {
        if (feature is! Map<String, dynamic>) {
          continue;
        }
        final id = feature['id'] as String? ?? feature['mapbox_id'] as String? ?? '';
        final properties = feature['properties'] as Map<String, dynamic>? ?? {};
        final label = properties['full_address'] as String? ??
            properties['name'] as String? ??
            properties['place_formatted'] as String? ??
            '';
        final geometry = feature['geometry'] as Map<String, dynamic>?;
        final coordinates = geometry?['coordinates'] as List<dynamic>?;
        if (coordinates == null || coordinates.length < 2) {
          continue;
        }
        final lng = (coordinates[0] as num).toDouble();
        final lat = (coordinates[1] as num).toDouble();
        final geo = QoshniGeoCoordinates.tryCreate(latitude: lat, longitude: lng);
        if (geo == null || label.isEmpty || id.isEmpty) {
          continue;
        }
        suggestions.add(
          QoshniGeocodingSuggestion(
            id: id,
            displayLabel: label,
            coordinates: geo,
          ),
        );
      }
      return suggestions;
    } on DioException {
      throw QoshniGeocodingUnavailableException();
    }
  }
}

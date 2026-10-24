import 'package:qoshni/core/config/mapbox_access_config.dart';
import 'package:qoshni/features/location/domain/qoshni_geocoding_provider.dart';
import 'package:qoshni/features/location/domain/qoshni_geocoding_suggestion.dart';

class QoshniGeocodingService {
  QoshniGeocodingService(this._provider);

  final QoshniGeocodingProvider _provider;

  static const Duration defaultTimeout = Duration(seconds: 12);

  bool get isProviderConfigured => MapboxAccessConfig.isConfigured;

  Future<List<QoshniGeocodingSuggestion>> searchAddress({
    required String query,
    Duration timeout = defaultTimeout,
  }) async {
    final trimmed = query.trim();
    if (trimmed.length < 2) {
      return const [];
    }
    return _provider.forwardSearch(query: trimmed, timeout: timeout);
  }
}

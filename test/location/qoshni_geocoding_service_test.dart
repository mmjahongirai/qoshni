import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/features/location/application/qoshni_geocoding_service.dart';
import 'package:qoshni/features/location/data/fake_qoshni_geocoding_provider.dart';

void main() {
  test('geocoding requires explicit query and does not auto-run', () async {
    final provider = FakeQoshniGeocodingProvider();
    final service = QoshniGeocodingService(provider);
    final results = await service.searchAddress(query: 'Tashkent');
    expect(provider.forwardSearchCalls, 1);
    expect(results, isNotEmpty);
    expect(results.first.isUserConfirmedSavedPlace, isFalse);
  });

  test('short query returns empty without provider call', () async {
    final provider = FakeQoshniGeocodingProvider();
    final service = QoshniGeocodingService(provider);
    final results = await service.searchAddress(query: 'a');
    expect(results, isEmpty);
    expect(provider.forwardSearchCalls, 0);
  });
}

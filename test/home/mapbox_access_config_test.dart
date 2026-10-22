import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/core/config/mapbox_access_config.dart';

void main() {
  test('isConfigured is false when MAPBOX_ACCESS_TOKEN is absent in tests', () {
    expect(MapboxAccessConfig.accessToken, isEmpty);
    expect(MapboxAccessConfig.isConfigured, isFalse);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/core/config/app_config.dart';
import 'package:qoshni/core/config/app_environment.dart';

void main() {
  test('api base url is unconfigured by default', () {
    final config = AppConfig.forEnvironment(AppEnvironment.development);
    expect(config.apiConfigured, isFalse);
    expect(config.apiBaseUrl, isEmpty);
  });

  test('defines stable api base url dart-define key', () {
    expect(AppConfigDefines.apiBaseUrl, 'QOSHNI_API_BASE_URL');
  });
}

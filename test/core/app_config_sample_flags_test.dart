import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/core/config/app_config.dart';
import 'package:qoshni/core/config/app_environment.dart';

void main() {
  group('AppConfig business sample defaults', () {
    test('development and staging enable samples by default', () {
      final dev = AppConfig.forEnvironment(AppEnvironment.development);
      final staging = AppConfig.forEnvironment(AppEnvironment.staging);

      expect(dev.apiConfigured, isFalse);
      expect(dev.enableBusinessProfileSamples, isTrue);
      expect(dev.enableBusinessOfferingSamples, isTrue);
      expect(staging.enableBusinessProfileSamples, isTrue);
      expect(staging.enableBusinessOfferingSamples, isTrue);
    });

    test('production disables samples by default', () {
      final prod = AppConfig.forEnvironment(AppEnvironment.production);

      expect(prod.enableBusinessProfileSamples, isFalse);
      expect(prod.enableBusinessOfferingSamples, isFalse);
    });
  });

  group('AppConfigDefines', () {
    test('uses stable dart-define keys', () {
      expect(
        AppConfigDefines.enableBusinessProfileSamples,
        'ENABLE_BUSINESS_PROFILE_SAMPLES',
      );
      expect(
        AppConfigDefines.enableBusinessOfferingSamples,
        'ENABLE_BUSINESS_OFFERING_SAMPLES',
      );
    });
  });

  group('parseBoolDefineValue', () {
    test('falls back when define is empty', () {
      expect(
        AppConfig.parseBoolDefineValue('', defaultValue: true),
        isTrue,
      );
    });

    test('parses true and false literals', () {
      expect(
        AppConfig.parseBoolDefineValue('true', defaultValue: false),
        isTrue,
      );
      expect(
        AppConfig.parseBoolDefineValue('false', defaultValue: true),
        isFalse,
      );
    });
  });

  group('forEnvironment bootstrap safety', () {
    test('does not throw for any environment', () {
      for (final env in AppEnvironment.values) {
        expect(() => AppConfig.forEnvironment(env), returnsNormally);
      }
    });
  });
}

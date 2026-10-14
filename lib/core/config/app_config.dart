import 'package:flutter/foundation.dart';
import 'package:qoshni/core/config/app_environment.dart';

/// Compile-time override keys (public feature flags — not security controls).
abstract final class AppConfigDefines {
  static const String enableBusinessProfileSamples =
      'ENABLE_BUSINESS_PROFILE_SAMPLES';
  static const String enableBusinessOfferingSamples =
      'ENABLE_BUSINESS_OFFERING_SAMPLES';
  static const String apiBaseUrl = 'QOSHNI_API_BASE_URL';
}

/// Immutable runtime configuration selected by flavor entrypoints.
class AppConfig {
  const AppConfig({
    required this.environment,
    required this.appName,
    required this.apiBaseUrl,
    required this.enableLogging,
    required this.enableBusinessProfileSamples,
    required this.enableBusinessOfferingSamples,
  });

  factory AppConfig.forEnvironment(AppEnvironment environment) {
    final profileSamplesDefault = switch (environment) {
      AppEnvironment.development => true,
      AppEnvironment.staging => true,
      AppEnvironment.production => false,
    };
    final offeringSamplesDefault = switch (environment) {
      AppEnvironment.development => true,
      AppEnvironment.staging => true,
      AppEnvironment.production => false,
    };

    return AppConfig(
      environment: environment,
      appName: _appNameFor(environment),
      apiBaseUrl: resolveApiBaseUrl(),
      enableLogging: !environment.isProduction,
      enableBusinessProfileSamples: _businessProfileSamplesFromEnvironment(
        defaultValue: profileSamplesDefault,
      ),
      enableBusinessOfferingSamples: _businessOfferingSamplesFromEnvironment(
        defaultValue: offeringSamplesDefault,
      ),
    );
  }

  static String _appNameFor(AppEnvironment environment) {
    return switch (environment) {
      AppEnvironment.development => "QO'SHNI Dev",
      AppEnvironment.staging => "QO'SHNI Staging",
      AppEnvironment.production => "QO'SHNI",
    };
  }

  /// Public API origin from `--dart-define=QOSHNI_API_BASE_URL=...` only.
  static String resolveApiBaseUrl() {
    const primary = String.fromEnvironment(AppConfigDefines.apiBaseUrl);
    if (primary.isNotEmpty) {
      return primary;
    }
    const legacy = String.fromEnvironment('API_BASE_URL');
    if (legacy.isNotEmpty) {
      return legacy;
    }
    return '';
  }

  /// Parses a compile-time `--dart-define` string. Empty [raw] uses [defaultValue].
  @visibleForTesting
  static bool parseBoolDefineValue(
    String raw, {
    required bool defaultValue,
  }) {
    if (raw.isEmpty) {
      return defaultValue;
    }
    final normalized = raw.toLowerCase();
    if (normalized == 'true' || normalized == '1' || normalized == 'yes') {
      return true;
    }
    if (normalized == 'false' || normalized == '0' || normalized == 'no') {
      return false;
    }
    return defaultValue;
  }

  /// Each flag uses a const [String.fromEnvironment] — required for web release.
  static bool _businessProfileSamplesFromEnvironment({
    required bool defaultValue,
  }) {
    const raw = String.fromEnvironment(
      AppConfigDefines.enableBusinessProfileSamples,
    );
    return parseBoolDefineValue(raw, defaultValue: defaultValue);
  }

  static bool _businessOfferingSamplesFromEnvironment({
    required bool defaultValue,
  }) {
    const raw = String.fromEnvironment(
      AppConfigDefines.enableBusinessOfferingSamples,
    );
    return parseBoolDefineValue(raw, defaultValue: defaultValue);
  }

  final AppEnvironment environment;
  final String appName;

  /// Backend API origin (scheme + host). Empty when not configured at build time.
  final String apiBaseUrl;
  final bool enableLogging;

  bool get apiConfigured => apiBaseUrl.trim().isNotEmpty;

  /// Read-only Business Center sample profiles (never user drafts).
  final bool enableBusinessProfileSamples;

  /// Read-only sample offerings on sample profiles only.
  final bool enableBusinessOfferingSamples;
}

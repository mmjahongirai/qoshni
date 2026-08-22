import 'package:qoshni/core/config/app_environment.dart';

/// Immutable runtime configuration selected by flavor entrypoints.
class AppConfig {
  const AppConfig({
    required this.environment,
    required this.appName,
    required this.apiBaseUrl,
    required this.enableLogging,
  });

  factory AppConfig.forEnvironment(AppEnvironment environment) {
    switch (environment) {
      case AppEnvironment.development:
        return const AppConfig(
          environment: AppEnvironment.development,
          appName: "QO'SHNI Dev",
          apiBaseUrl: 'https://api.dev.qoshni.uz',
          enableLogging: true,
        );
      case AppEnvironment.staging:
        return const AppConfig(
          environment: AppEnvironment.staging,
          appName: "QO'SHNI Staging",
          apiBaseUrl: 'https://api.staging.qoshni.uz',
          enableLogging: true,
        );
      case AppEnvironment.production:
        return const AppConfig(
          environment: AppEnvironment.production,
          appName: "QO'SHNI",
          apiBaseUrl: 'https://api.qoshni.uz',
          enableLogging: false,
        );
    }
  }

  final AppEnvironment environment;
  final String appName;

  /// Placeholder base URL — not connected to a live backend yet.
  final String apiBaseUrl;
  final bool enableLogging;
}

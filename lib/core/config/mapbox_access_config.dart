/// Compile-time Mapbox public token (`pk…`) via `--dart-define=MAPBOX_ACCESS_TOKEN=…`.
///
/// Never commit a real token. Do not use secret `sk` tokens in client builds.
abstract final class MapboxAccessConfig {
  static const String accessToken = String.fromEnvironment(
    'MAPBOX_ACCESS_TOKEN',
  );

  static bool get isConfigured => accessToken.trim().isNotEmpty;
}

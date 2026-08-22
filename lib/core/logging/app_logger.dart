import 'package:logger/logger.dart';
import 'package:qoshni/core/config/app_config.dart';

/// Thin logging façade so features do not depend on a concrete logger package.
class AppLogger {
  AppLogger(AppConfig config)
      : _enabled = config.enableLogging,
        _logger = Logger(
          printer: PrettyPrinter(
            methodCount: 0,
            errorMethodCount: 5,
            lineLength: 80,
            colors: true,
            printEmojis: false,
          ),
          level: config.enableLogging ? Level.debug : Level.off,
        );

  final bool _enabled;
  final Logger _logger;

  void debug(String message) {
    if (_enabled) _logger.d(message);
  }

  void info(String message) {
    if (_enabled) _logger.i(message);
  }

  void warning(String message) {
    if (_enabled) _logger.w(message);
  }

  void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (_enabled) {
      _logger.e(message, error: error, stackTrace: stackTrace);
    }
  }
}

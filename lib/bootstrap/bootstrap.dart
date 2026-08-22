import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:qoshni/app/app.dart';
import 'package:qoshni/core/config/app_config.dart';
import 'package:qoshni/core/config/app_environment.dart';
import 'package:qoshni/core/logging/app_logger.dart';
import 'package:qoshni/di/injection.dart';

Future<void> bootstrap(AppEnvironment environment) async {
  WidgetsFlutterBinding.ensureInitialized();

  final config = AppConfig.forEnvironment(environment);
  await configureDependencies(config);

  final logger = getIt<AppLogger>();
  logger.info('Bootstrapping QO\'SHNI (${config.environment.label})');

  FlutterError.onError = (details) {
    logger.error(
      'Flutter framework error',
      error: details.exception,
      stackTrace: details.stack,
    );
  };

  runZonedGuarded(
    () => runApp(const QoshniApp()),
    (error, stackTrace) {
      logger.error('Uncaught zone error', error: error, stackTrace: stackTrace);
    },
  );
}

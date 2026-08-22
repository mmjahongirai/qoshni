import 'package:get_it/get_it.dart';
import 'package:qoshni/core/config/app_config.dart';
import 'package:qoshni/core/error/error_handler.dart';
import 'package:qoshni/core/localization/locale_controller.dart';
import 'package:qoshni/core/logging/app_logger.dart';
import 'package:qoshni/core/network/api_client.dart';
import 'package:qoshni/core/network/network_info.dart';
import 'package:qoshni/core/theme/theme_controller.dart';
import 'package:qoshni/routing/app_router.dart';

final GetIt getIt = GetIt.instance;

/// Registers core singletons. Feature modules will extend this as they land.
Future<void> configureDependencies(AppConfig config) async {
  if (getIt.isRegistered<AppConfig>()) {
    await getIt.reset();
  }

  getIt
    ..registerSingleton<AppConfig>(config)
    ..registerLazySingleton<AppLogger>(() => AppLogger(getIt<AppConfig>()))
    ..registerLazySingleton<ErrorHandler>(
      () => ErrorHandler(getIt<AppLogger>()),
    )
    ..registerLazySingleton<ThemeController>(ThemeController.new)
    ..registerLazySingleton<LocaleController>(LocaleController.new)
    ..registerLazySingleton<NetworkInfo>(UnimplementedNetworkInfo.new)
    ..registerLazySingleton<ApiClient>(
      () => ApiClient(
        config: getIt<AppConfig>(),
        logger: getIt<AppLogger>(),
      ),
    )
    ..registerLazySingleton<AppRouter>(
      () => AppRouter(logger: getIt<AppLogger>()),
    );
}

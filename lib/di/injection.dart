import 'package:get_it/get_it.dart';
import 'package:qoshni/core/config/app_config.dart';
import 'package:qoshni/core/error/error_handler.dart';
import 'package:qoshni/core/localization/locale_controller.dart';
import 'package:qoshni/core/logging/app_logger.dart';
import 'package:qoshni/core/network/api_client.dart';
import 'package:qoshni/core/network/network_info.dart';
import 'package:qoshni/core/theme/theme_controller.dart';
import 'package:qoshni/features/auth/data/auth_api_repository.dart';
import 'package:qoshni/features/auth/data/auth_credential_store.dart';
import 'package:qoshni/features/auth/domain/auth_repository.dart';
import 'package:qoshni/features/auth/presentation/auth_controller.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_inventory_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_offering_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_profile_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_inventory_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_offering_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_profile_repository.dart';
import 'package:qoshni/features/business_platform/presentation/business_inventory_controller.dart';
import 'package:qoshni/features/business_platform/presentation/business_offerings_controller.dart';
import 'package:qoshni/features/business_platform/presentation/business_profile_controller.dart';
import 'package:qoshni/features/home/presentation/cart/cart_controller.dart';
import 'package:qoshni/features/home/presentation/favorites/favorites_controller.dart';
import 'package:qoshni/features/home/presentation/orders/demo_order_controller.dart';
import 'package:qoshni/features/user_profile/data/user_profile_api_repository.dart';
import 'package:qoshni/features/user_profile/domain/user_profile_repository.dart';
import 'package:qoshni/features/user_profile/presentation/user_profile_controller.dart';
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
    ..registerLazySingleton<FavoritesController>(FavoritesController.new)
    ..registerLazySingleton<CartController>(CartController.new)
    ..registerLazySingleton<DemoOrderController>(DemoOrderController.new)
    ..registerLazySingleton<BusinessProfileRepository>(
      InMemoryBusinessProfileRepository.new,
    )
    ..registerLazySingleton<BusinessOfferingRepository>(
      InMemoryBusinessOfferingRepository.new,
    )
    ..registerLazySingleton<BusinessInventoryRepository>(
      () => InMemoryBusinessInventoryRepository(
        getIt<BusinessOfferingRepository>(),
      ),
    )
    ..registerLazySingleton<BusinessProfileController>(
      () => BusinessProfileController(
        getIt<BusinessProfileRepository>(),
        getIt<AppConfig>(),
      ),
    )
    ..registerLazySingleton<BusinessOfferingsController>(
      () => BusinessOfferingsController(
        profileRepository: getIt<BusinessProfileRepository>(),
        offeringRepository: getIt<BusinessOfferingRepository>(),
        inventoryRepository: getIt<BusinessInventoryRepository>(),
        config: getIt<AppConfig>(),
      ),
    )
    ..registerLazySingleton<BusinessInventoryController>(
      () => BusinessInventoryController(
        profileRepository: getIt<BusinessProfileRepository>(),
        offeringRepository: getIt<BusinessOfferingRepository>(),
        inventoryRepository: getIt<BusinessInventoryRepository>(),
      ),
    )
    ..registerLazySingleton<NetworkInfo>(UnimplementedNetworkInfo.new)
    ..registerLazySingleton<ApiClient>(
      () => ApiClient(
        config: getIt<AppConfig>(),
        logger: getIt<AppLogger>(),
      ),
    )
    ..registerLazySingleton<AuthCredentialStore>(InMemoryAuthCredentialStore.new)
    ..registerLazySingleton<AuthRepository>(
      () => AuthApiRepository(
        apiClient: getIt<ApiClient>(),
        config: getIt<AppConfig>(),
      ),
    )
    ..registerLazySingleton<AuthController>(
      () => AuthController(
        repository: getIt<AuthRepository>(),
        credentialStore: getIt<AuthCredentialStore>(),
        config: getIt<AppConfig>(),
      ),
    )
    ..registerLazySingleton<UserProfileRepository>(
      () => UserProfileApiRepository(
        apiClient: getIt<ApiClient>(),
        config: getIt<AppConfig>(),
      ),
    )
    ..registerLazySingleton<UserProfileController>(
      () => UserProfileController(
        repository: getIt<UserProfileRepository>(),
        authController: getIt<AuthController>(),
        localeController: getIt<LocaleController>(),
        config: getIt<AppConfig>(),
      ),
    )
    ..registerLazySingleton<AppRouter>(
      () => AppRouter(logger: getIt<AppLogger>()),
    );
}

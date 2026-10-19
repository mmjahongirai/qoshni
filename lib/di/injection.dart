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
import 'package:qoshni/features/business_platform/data/in_memory_business_branch_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_branch_permission_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_catalog_category_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_catalog_demo_item_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_catalog_product_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_catalog_service_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_catalog_product_variant_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_catalog_product_option_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_catalog_product_media_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_catalog_listing_attribute_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_catalog_inventory_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_catalog_inventory_reservation_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_catalog_resource_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_staff_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_owner_profile_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_profile_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_inventory_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_offering_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_branch_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_branch_permission_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_catalog_category_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_catalog_demo_item_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_catalog_product_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_catalog_service_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_catalog_product_variant_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_catalog_product_option_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_catalog_product_media_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_catalog_listing_attribute_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_catalog_inventory_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_catalog_inventory_reservation_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_catalog_resource_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_staff_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_owner_profile_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_profile_repository.dart';
import 'package:qoshni/features/business_platform/presentation/business_inventory_controller.dart';
import 'package:qoshni/features/business_platform/presentation/business_offerings_controller.dart';
import 'package:qoshni/features/business_onboarding/data/onboarding_api_repository.dart';
import 'package:qoshni/features/business_onboarding/domain/onboarding_repository.dart';
import 'package:qoshni/features/business_onboarding/presentation/onboarding_controller.dart';
import 'package:qoshni/features/business_platform/presentation/business_branch_controller.dart';
import 'package:qoshni/features/business_platform/presentation/business_branch_permission_controller.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_controller.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_category_controller.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_product_controller.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_service_controller.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_product_variant_controller.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_product_option_controller.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_product_media_controller.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_listing_attribute_controller.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_inventory_controller.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_inventory_reservation_controller.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_resource_controller.dart';
import 'package:qoshni/features/business_platform/presentation/business_staff_controller.dart';
import 'package:qoshni/features/business_platform/presentation/business_owner_profile_controller.dart';
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
    ..registerLazySingleton<BusinessOwnerProfileRepository>(
      InMemoryBusinessOwnerProfileRepository.new,
    )
    ..registerLazySingleton<BusinessBranchRepository>(
      () => InMemoryBusinessBranchRepository(
        getIt<BusinessOwnerProfileRepository>(),
      ),
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
    ..registerLazySingleton<BusinessOwnerProfileController>(
      () => BusinessOwnerProfileController(
        getIt<BusinessOwnerProfileRepository>(),
      ),
    )
    ..registerLazySingleton<BusinessBranchController>(
      () => BusinessBranchController(getIt<BusinessBranchRepository>()),
    )
    ..registerLazySingleton<BusinessStaffRepository>(
      () => InMemoryBusinessStaffRepository(
        getIt<BusinessOwnerProfileRepository>(),
        getIt<BusinessBranchRepository>(),
      ),
    )
    ..registerLazySingleton<BusinessStaffController>(
      () => BusinessStaffController(getIt<BusinessStaffRepository>()),
    )
    ..registerLazySingleton<BusinessBranchPermissionRepository>(
      () => InMemoryBusinessBranchPermissionRepository(
        getIt<BusinessStaffRepository>(),
        getIt<BusinessBranchRepository>(),
      ),
    )
    ..registerLazySingleton<BusinessBranchPermissionController>(
      () => BusinessBranchPermissionController(
        getIt<BusinessBranchPermissionRepository>(),
      ),
    )
    ..registerLazySingleton<BusinessCatalogCategoryRepository>(
      () => InMemoryBusinessCatalogCategoryRepository(
        getIt<BusinessOwnerProfileRepository>(),
      ),
    )
    ..registerLazySingleton<BusinessCatalogProductRepository>(
      () => InMemoryBusinessCatalogProductRepository(
        getIt<BusinessOwnerProfileRepository>(),
        getIt<BusinessCatalogCategoryRepository>(),
      ),
    )
    ..registerLazySingleton<BusinessCatalogServiceRepository>(
      () => InMemoryBusinessCatalogServiceRepository(
        getIt<BusinessOwnerProfileRepository>(),
        getIt<BusinessCatalogCategoryRepository>(),
      ),
    )
    ..registerLazySingleton<BusinessCatalogProductVariantRepository>(
      () => InMemoryBusinessCatalogProductVariantRepository(
        getIt<BusinessOwnerProfileRepository>(),
        getIt<BusinessCatalogProductRepository>(),
      ),
    )
    ..registerLazySingleton<BusinessCatalogProductOptionRepository>(
      () => InMemoryBusinessCatalogProductOptionRepository(
        getIt<BusinessOwnerProfileRepository>(),
        getIt<BusinessCatalogProductRepository>(),
      ),
    )
    ..registerLazySingleton<BusinessCatalogProductMediaRepository>(
      () => InMemoryBusinessCatalogProductMediaRepository(
        getIt<BusinessOwnerProfileRepository>(),
        getIt<BusinessCatalogProductRepository>(),
      ),
    )
    ..registerLazySingleton<BusinessCatalogListingAttributeRepository>(
      () => InMemoryBusinessCatalogListingAttributeRepository(
        getIt<BusinessOwnerProfileRepository>(),
        getIt<BusinessCatalogProductRepository>(),
        getIt<BusinessCatalogServiceRepository>(),
      ),
    )
    ..registerLazySingleton<BusinessCatalogInventoryRepository>(
      () => InMemoryBusinessCatalogInventoryRepository(
        getIt<BusinessOwnerProfileRepository>(),
        getIt<BusinessCatalogProductRepository>(),
        getIt<BusinessCatalogProductVariantRepository>(),
        getIt<BusinessBranchRepository>(),
      ),
    )
    ..registerLazySingleton<BusinessCatalogInventoryReservationRepository>(
      () => InMemoryBusinessCatalogInventoryReservationRepository(
        getIt<BusinessOwnerProfileRepository>(),
        getIt<BusinessCatalogInventoryRepository>(),
      ),
    )
    ..registerLazySingleton<BusinessCatalogResourceRepository>(
      () => InMemoryBusinessCatalogResourceRepository(
        getIt<BusinessOwnerProfileRepository>(),
        getIt<BusinessBranchRepository>(),
        getIt<BusinessCatalogServiceRepository>(),
      ),
    )
    ..registerLazySingleton<BusinessCatalogDemoItemRepository>(
      () => InMemoryBusinessCatalogOverviewRepository(
        getIt<BusinessCatalogProductRepository>(),
        getIt<BusinessCatalogServiceRepository>(),
      ),
    )
    ..registerLazySingleton<BusinessCatalogCategoryController>(
      () => BusinessCatalogCategoryController(
        getIt<BusinessCatalogCategoryRepository>(),
      ),
    )
    ..registerLazySingleton<BusinessCatalogProductController>(
      () => BusinessCatalogProductController(
        getIt<BusinessCatalogProductRepository>(),
      ),
    )
    ..registerLazySingleton<BusinessCatalogServiceController>(
      () => BusinessCatalogServiceController(
        getIt<BusinessCatalogServiceRepository>(),
      ),
    )
    ..registerLazySingleton<BusinessCatalogProductVariantController>(
      () => BusinessCatalogProductVariantController(
        getIt<BusinessCatalogProductVariantRepository>(),
      ),
    )
    ..registerLazySingleton<BusinessCatalogProductOptionController>(
      () => BusinessCatalogProductOptionController(
        getIt<BusinessCatalogProductOptionRepository>(),
      ),
    )
    ..registerLazySingleton<BusinessCatalogProductMediaController>(
      () => BusinessCatalogProductMediaController(
        getIt<BusinessCatalogProductMediaRepository>(),
      ),
    )
    ..registerLazySingleton<BusinessCatalogListingAttributeController>(
      () => BusinessCatalogListingAttributeController(
        getIt<BusinessCatalogListingAttributeRepository>(),
      ),
    )
    ..registerLazySingleton<BusinessCatalogInventoryController>(
      () => BusinessCatalogInventoryController(
        getIt<BusinessCatalogInventoryRepository>(),
      ),
    )
    ..registerLazySingleton<BusinessCatalogInventoryReservationController>(
      () => BusinessCatalogInventoryReservationController(
        getIt<BusinessCatalogInventoryReservationRepository>(),
      ),
    )
    ..registerLazySingleton<BusinessCatalogResourceController>(
      () => BusinessCatalogResourceController(
        getIt<BusinessCatalogResourceRepository>(),
      ),
    )
    ..registerLazySingleton<BusinessCatalogController>(
      () => BusinessCatalogController(
        getIt<BusinessCatalogCategoryRepository>(),
        getIt<BusinessCatalogDemoItemRepository>(),
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
    ..registerLazySingleton<OnboardingRepository>(
      () => OnboardingApiRepository(
        apiClient: getIt<ApiClient>(),
        config: getIt<AppConfig>(),
      ),
    )
    ..registerLazySingleton<OnboardingController>(
      () => OnboardingController(
        repository: getIt<OnboardingRepository>(),
        authController: getIt<AuthController>(),
        config: getIt<AppConfig>(),
      ),
    )
    ..registerLazySingleton<AppRouter>(
      () => AppRouter(logger: getIt<AppLogger>()),
    );

  _wireBusinessCatalogRepositories();
}

void _wireBusinessCatalogRepositories() {
  (getIt<BusinessCatalogCategoryRepository>()
          as InMemoryBusinessCatalogCategoryRepository)
      .attachListingRepositories(
    productRepository: getIt<BusinessCatalogProductRepository>(),
    serviceRepository: getIt<BusinessCatalogServiceRepository>(),
  );
}

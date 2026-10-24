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
import 'package:qoshni/features/business_platform/data/in_memory_business_catalog_pricing_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_catalog_discount_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_catalog_promo_code_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_catalog_commercial_fee_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_delivery_exception_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_delivery_proof_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_review_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_complaint_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_dispute_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_reputation_event_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_demo_review_transaction_eligibility_provider.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_delivery_task_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_fulfillment_repository.dart';
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
import 'package:qoshni/features/business_platform/domain/repositories/business_catalog_pricing_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_catalog_discount_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_catalog_promo_code_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_catalog_commercial_fee_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_delivery_exception_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_delivery_proof_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_review_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_complaint_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_dispute_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_reputation_event_repository.dart';
import 'package:qoshni/features/business_platform/domain/review_transaction_eligibility_provider.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_delivery_task_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_fulfillment_repository.dart';
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
import 'package:qoshni/features/business_platform/presentation/business_catalog_pricing_controller.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_discount_controller.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_promo_code_controller.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_commercial_fee_controller.dart';
import 'package:qoshni/features/business_platform/presentation/business_delivery_exception_controller.dart';
import 'package:qoshni/features/business_platform/presentation/business_delivery_proof_controller.dart';
import 'package:qoshni/features/business_platform/presentation/business_review_controller.dart';
import 'package:qoshni/features/business_platform/presentation/business_complaint_controller.dart';
import 'package:qoshni/features/business_platform/presentation/business_dispute_controller.dart';
import 'package:qoshni/features/business_platform/presentation/business_reputation_event_controller.dart';
import 'package:qoshni/features/business_platform/presentation/business_reputation_signal_collector.dart';
import 'package:qoshni/features/business_platform/presentation/business_delivery_task_controller.dart';
import 'package:qoshni/features/business_platform/presentation/business_fulfillment_controller.dart';
import 'package:qoshni/features/business_platform/presentation/business_staff_controller.dart';
import 'package:qoshni/features/business_platform/presentation/business_owner_profile_controller.dart';
import 'package:qoshni/features/business_platform/presentation/business_profile_controller.dart';
import 'package:qoshni/features/home/presentation/cart/cart_controller.dart';
import 'package:qoshni/features/home/presentation/favorites/favorites_controller.dart';
import 'package:qoshni/features/home/presentation/orders/demo_order_controller.dart';
import 'package:qoshni/features/notifications/application/qoshni_notification_dispatch_coordinator.dart';
import 'package:qoshni/features/notifications/data/in_memory_qoshni_notification_dispatch_audit_repository.dart';
import 'package:qoshni/features/notifications/data/in_memory_qoshni_notification_template_repository.dart';
import 'package:qoshni/features/notifications/data/in_memory_qoshni_notification_preference_repository.dart';
import 'package:qoshni/features/notifications/data/in_memory_qoshni_notification_repository.dart';
import 'package:qoshni/features/notifications/data/simulated_qoshni_notification_channel_adapters.dart';
import 'package:qoshni/features/notifications/domain/repositories/qoshni_notification_dispatch_audit_repository.dart';
import 'package:qoshni/features/notifications/domain/repositories/qoshni_notification_preference_repository.dart';
import 'package:qoshni/features/notifications/domain/repositories/qoshni_notification_repository.dart';
import 'package:qoshni/features/notifications/domain/repositories/qoshni_notification_template_repository.dart';
import 'package:qoshni/features/notifications/presentation/qoshni_notification_controller.dart';
import 'package:qoshni/features/notifications/presentation/qoshni_notification_dispatch_controller.dart';
import 'package:qoshni/features/notifications/presentation/qoshni_notification_template_controller.dart';
import 'package:qoshni/features/conversations/data/in_memory_qoshni_conversation_repository.dart';
import 'package:qoshni/features/conversations/domain/repositories/qoshni_conversation_repository.dart';
import 'package:qoshni/features/conversations/presentation/qoshni_conversation_controller.dart';
import 'package:qoshni/features/platform_governance/application/qoshni_platform_governance_audit_service.dart';
import 'package:qoshni/features/platform_governance/application/qoshni_platform_governance_authorizer.dart';
import 'package:qoshni/features/platform_governance/application/qoshni_platform_governance_operations_summary_service.dart';
import 'package:qoshni/features/platform_governance/data/in_memory_qoshni_platform_approval_repository.dart';
import 'package:qoshni/features/platform_governance/data/in_memory_qoshni_platform_business_verification_queue_repository.dart';
import 'package:qoshni/features/platform_governance/data/in_memory_qoshni_platform_configuration_repository.dart';
import 'package:qoshni/features/platform_governance/data/in_memory_qoshni_platform_governance_audit_repository.dart';
import 'package:qoshni/features/platform_governance/data/in_memory_qoshni_platform_governance_repository.dart';
import 'package:qoshni/features/platform_governance/data/in_memory_qoshni_platform_moderation_queue_repository.dart';
import 'package:qoshni/features/platform_governance/data/in_memory_qoshni_platform_support_case_repository.dart';
import 'package:qoshni/features/platform_governance/domain/repositories/qoshni_platform_approval_repository.dart';
import 'package:qoshni/features/platform_governance/domain/repositories/qoshni_platform_business_verification_queue_repository.dart';
import 'package:qoshni/features/platform_governance/domain/repositories/qoshni_platform_configuration_repository.dart';
import 'package:qoshni/features/platform_governance/domain/repositories/qoshni_platform_governance_audit_repository.dart';
import 'package:qoshni/features/platform_governance/domain/repositories/qoshni_platform_governance_repository.dart';
import 'package:qoshni/features/platform_governance/domain/repositories/qoshni_platform_moderation_queue_repository.dart';
import 'package:qoshni/features/platform_governance/domain/repositories/qoshni_platform_support_case_repository.dart';
import 'package:qoshni/features/platform_governance/presentation/qoshni_platform_approval_controller.dart';
import 'package:qoshni/features/platform_governance/presentation/qoshni_platform_business_verification_queue_controller.dart';
import 'package:qoshni/features/platform_governance/presentation/qoshni_platform_configuration_controller.dart';
import 'package:qoshni/features/platform_governance/presentation/qoshni_platform_governance_audit_trail_controller.dart';
import 'package:qoshni/features/platform_governance/presentation/qoshni_platform_governance_controller.dart';
import 'package:qoshni/features/platform_governance/presentation/qoshni_platform_governance_operations_controller.dart';
import 'package:qoshni/features/platform_governance/presentation/qoshni_platform_moderation_queue_controller.dart';
import 'package:qoshni/features/platform_governance/presentation/qoshni_platform_support_case_controller.dart';
import 'package:qoshni/features/system_messages/data/in_memory_qoshni_system_message_repository.dart';
import 'package:qoshni/features/system_messages/domain/repositories/qoshni_system_message_repository.dart';
import 'package:qoshni/features/system_messages/presentation/qoshni_system_message_controller.dart';
import 'package:qoshni/features/notifications/presentation/qoshni_notification_preference_controller.dart';
import 'package:qoshni/features/user_profile/data/user_profile_api_repository.dart';
import 'package:qoshni/features/user_profile/domain/user_profile_repository.dart';
import 'package:qoshni/features/user_profile/presentation/user_profile_controller.dart';
import 'package:qoshni/features/search/application/qoshni_search_autocomplete_service.dart';
import 'package:qoshni/features/search/application/qoshni_search_execution_coordinator.dart';
import 'package:qoshni/features/search/application/qoshni_search_execution_service.dart';
import 'package:qoshni/features/search/data/remote_qoshni_search_data_source.dart';
import 'package:qoshni/features/search/application/qoshni_search_query_processor.dart';
import 'package:qoshni/features/search/data/in_memory_qoshni_search_index_repository.dart';
import 'package:qoshni/features/search/data/in_memory_qoshni_search_vocabulary_repository.dart';
import 'package:qoshni/features/search/domain/repositories/qoshni_search_index_repository.dart';
import 'package:qoshni/features/search/application/qoshni_search_map_focus_controller.dart';
import 'package:qoshni/features/search/domain/repositories/qoshni_search_vocabulary_repository.dart';
import 'package:qoshni/features/location/application/qoshni_geocoding_service.dart';
import 'package:qoshni/features/location/application/qoshni_location_service.dart';
import 'package:qoshni/features/location/application/qoshni_map_location_controller.dart';
import 'package:qoshni/features/location/application/qoshni_saved_places_controller.dart';
import 'package:qoshni/features/location/application/qoshni_search_location_selection_controller.dart';
import 'package:qoshni/features/location/data/geolocator_qoshni_location_provider.dart';
import 'package:qoshni/features/location/data/mapbox_qoshni_geocoding_provider.dart';
import 'package:qoshni/features/location/domain/qoshni_geocoding_provider.dart';
import 'package:qoshni/features/location/domain/qoshni_location_provider.dart';
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
    ..registerLazySingleton<QoshniNotificationRepository>(
      InMemoryQoshniNotificationRepository.new,
    )
    ..registerLazySingleton<QoshniNotificationController>(
      () => QoshniNotificationController(getIt<QoshniNotificationRepository>()),
    )
    ..registerLazySingleton<QoshniNotificationPreferenceRepository>(
      InMemoryQoshniNotificationPreferenceRepository.new,
    )
    ..registerLazySingleton<QoshniNotificationPreferenceController>(
      () => QoshniNotificationPreferenceController(
        getIt<QoshniNotificationPreferenceRepository>(),
      ),
    )
    ..registerLazySingleton<InMemoryQoshniNotificationDispatchAuditRepository>(
      InMemoryQoshniNotificationDispatchAuditRepository.new,
    )
    ..registerLazySingleton<QoshniNotificationDispatchAuditRepository>(
      () => getIt<InMemoryQoshniNotificationDispatchAuditRepository>(),
    )
    ..registerLazySingleton<QoshniNotificationDispatchCoordinator>(() {
      final auditRepo =
          getIt<InMemoryQoshniNotificationDispatchAuditRepository>();
      final coordinator = QoshniNotificationDispatchCoordinator(
        preferenceRepository: getIt<QoshniNotificationPreferenceRepository>(),
        inboxRepository: getIt<QoshniNotificationRepository>(),
        auditRepository: auditRepo,
        channelAdapters: buildSimulatedQoshniNotificationChannelAdapters(),
      );
      coordinator.auditIdFactory = auditRepo.nextAuditRecordId;
      return coordinator;
    })
    ..registerLazySingleton<QoshniNotificationDispatchController>(
      () => QoshniNotificationDispatchController(
        getIt<QoshniNotificationDispatchCoordinator>(),
        getIt<QoshniNotificationDispatchAuditRepository>(),
        getIt<QoshniNotificationController>(),
      ),
    )
    ..registerLazySingleton<QoshniNotificationTemplateRepository>(
      InMemoryQoshniNotificationTemplateRepository.new,
    )
    ..registerLazySingleton<QoshniNotificationTemplateController>(
      () => QoshniNotificationTemplateController(
        getIt<QoshniNotificationTemplateRepository>(),
      ),
    )
    ..registerLazySingleton<QoshniSystemMessageRepository>(
      InMemoryQoshniSystemMessageRepository.new,
    )
    ..registerLazySingleton<QoshniSystemMessageController>(
      () => QoshniSystemMessageController(
        getIt<QoshniSystemMessageRepository>(),
      ),
    )
    ..registerLazySingleton<QoshniConversationRepository>(
      InMemoryQoshniConversationRepository.new,
    )
    ..registerLazySingleton<QoshniConversationController>(
      () => QoshniConversationController(
        getIt<QoshniConversationRepository>(),
      ),
    )
    ..registerLazySingleton<QoshniPlatformGovernanceRepository>(
      InMemoryQoshniPlatformGovernanceRepository.new,
    )
    ..registerLazySingleton<QoshniPlatformGovernanceController>(
      () => QoshniPlatformGovernanceController(
        getIt<QoshniPlatformGovernanceRepository>(),
      ),
    )
    ..registerLazySingleton<QoshniPlatformGovernanceAuthorizer>(
      () => QoshniPlatformGovernanceAuthorizer(
        getIt<QoshniPlatformGovernanceRepository>(),
      ),
    )
    ..registerLazySingleton<QoshniPlatformGovernanceAuditRepository>(
      InMemoryQoshniPlatformGovernanceAuditRepository.new,
    )
    ..registerLazySingleton<QoshniPlatformGovernanceAuditService>(
      () => QoshniPlatformGovernanceAuditService(
        auditRepository: getIt<QoshniPlatformGovernanceAuditRepository>(),
        governanceRepository: getIt<QoshniPlatformGovernanceRepository>(),
      ),
    )
    ..registerLazySingleton<QoshniPlatformConfigurationRepository>(
      InMemoryQoshniPlatformConfigurationRepository.new,
    )
    ..registerLazySingleton<QoshniPlatformApprovalRepository>(
      InMemoryQoshniPlatformApprovalRepository.new,
    )
    ..registerLazySingleton<QoshniPlatformBusinessVerificationQueueRepository>(
      InMemoryQoshniPlatformBusinessVerificationQueueRepository.new,
    )
    ..registerLazySingleton<QoshniPlatformModerationQueueRepository>(
      InMemoryQoshniPlatformModerationQueueRepository.new,
    )
    ..registerLazySingleton<QoshniPlatformSupportCaseRepository>(
      InMemoryQoshniPlatformSupportCaseRepository.new,
    )
    ..registerLazySingleton<QoshniPlatformGovernanceOperationsSummaryService>(
      () => QoshniPlatformGovernanceOperationsSummaryService(
        verificationRepository:
            getIt<QoshniPlatformBusinessVerificationQueueRepository>(),
        moderationRepository: getIt<QoshniPlatformModerationQueueRepository>(),
        supportRepository: getIt<QoshniPlatformSupportCaseRepository>(),
        auditRepository: getIt<QoshniPlatformGovernanceAuditRepository>(),
        approvalRepository: getIt<QoshniPlatformApprovalRepository>(),
        configurationRepository: getIt<QoshniPlatformConfigurationRepository>(),
      ),
    )
    ..registerLazySingleton<QoshniPlatformBusinessVerificationQueueController>(
      () => QoshniPlatformBusinessVerificationQueueController(
        repository: getIt<QoshniPlatformBusinessVerificationQueueRepository>(),
        governanceRepository: getIt<QoshniPlatformGovernanceRepository>(),
        authorizer: getIt<QoshniPlatformGovernanceAuthorizer>(),
        auditService: getIt<QoshniPlatformGovernanceAuditService>(),
      ),
    )
    ..registerLazySingleton<QoshniPlatformModerationQueueController>(
      () => QoshniPlatformModerationQueueController(
        repository: getIt<QoshniPlatformModerationQueueRepository>(),
        governanceRepository: getIt<QoshniPlatformGovernanceRepository>(),
        authorizer: getIt<QoshniPlatformGovernanceAuthorizer>(),
        auditService: getIt<QoshniPlatformGovernanceAuditService>(),
      ),
    )
    ..registerLazySingleton<QoshniPlatformSupportCaseController>(
      () => QoshniPlatformSupportCaseController(
        repository: getIt<QoshniPlatformSupportCaseRepository>(),
        governanceRepository: getIt<QoshniPlatformGovernanceRepository>(),
        authorizer: getIt<QoshniPlatformGovernanceAuthorizer>(),
        auditService: getIt<QoshniPlatformGovernanceAuditService>(),
      ),
    )
    ..registerLazySingleton<QoshniPlatformGovernanceAuditTrailController>(
      () => QoshniPlatformGovernanceAuditTrailController(
        auditRepository: getIt<QoshniPlatformGovernanceAuditRepository>(),
        authorizer: getIt<QoshniPlatformGovernanceAuthorizer>(),
      ),
    )
    ..registerLazySingleton<QoshniPlatformConfigurationController>(
      () => QoshniPlatformConfigurationController(
        repository: getIt<QoshniPlatformConfigurationRepository>(),
        governanceRepository: getIt<QoshniPlatformGovernanceRepository>(),
        authorizer: getIt<QoshniPlatformGovernanceAuthorizer>(),
        auditService: getIt<QoshniPlatformGovernanceAuditService>(),
      ),
    )
    ..registerLazySingleton<QoshniPlatformApprovalController>(
      () => QoshniPlatformApprovalController(
        repository: getIt<QoshniPlatformApprovalRepository>(),
        governanceRepository: getIt<QoshniPlatformGovernanceRepository>(),
        authorizer: getIt<QoshniPlatformGovernanceAuthorizer>(),
        auditService: getIt<QoshniPlatformGovernanceAuditService>(),
      ),
    )
    ..registerLazySingleton<QoshniPlatformGovernanceOperationsController>(
      () => QoshniPlatformGovernanceOperationsController(
        summaryService: getIt<QoshniPlatformGovernanceOperationsSummaryService>(),
        authorizer: getIt<QoshniPlatformGovernanceAuthorizer>(),
      ),
    )
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
    ..registerLazySingleton<BusinessCatalogPricingRepository>(
      () => InMemoryBusinessCatalogPricingRepository(
        getIt<BusinessOwnerProfileRepository>(),
        getIt<BusinessCatalogProductRepository>(),
        getIt<BusinessCatalogServiceRepository>(),
        getIt<BusinessCatalogProductVariantRepository>(),
        getIt<BusinessBranchRepository>(),
      ),
    )
    ..registerLazySingleton<BusinessCatalogDiscountRepository>(
      () => InMemoryBusinessCatalogDiscountRepository(
        getIt<BusinessOwnerProfileRepository>(),
        getIt<BusinessCatalogProductRepository>(),
        getIt<BusinessCatalogServiceRepository>(),
        getIt<BusinessCatalogProductVariantRepository>(),
        getIt<BusinessBranchRepository>(),
      ),
    )
    ..registerLazySingleton<BusinessCatalogPromoCodeRepository>(
      () => InMemoryBusinessCatalogPromoCodeRepository(
        getIt<BusinessOwnerProfileRepository>(),
        getIt<BusinessBranchRepository>(),
        getIt<BusinessCatalogDiscountRepository>(),
      ),
    )
    ..registerLazySingleton<BusinessCatalogCommercialFeeRepository>(
      () => InMemoryBusinessCatalogCommercialFeeRepository(
        getIt<BusinessOwnerProfileRepository>(),
        getIt<BusinessBranchRepository>(),
      ),
    )
    ..registerLazySingleton<BusinessFulfillmentRepository>(
      () => InMemoryBusinessFulfillmentRepository(
        getIt<BusinessOwnerProfileRepository>(),
        getIt<BusinessBranchRepository>(),
        getIt<BusinessCatalogProductRepository>(),
        getIt<BusinessCatalogServiceRepository>(),
      ),
    )
    ..registerLazySingleton<BusinessDeliveryTaskRepository>(
      () => InMemoryBusinessDeliveryTaskRepository(
        getIt<BusinessOwnerProfileRepository>(),
        getIt<BusinessBranchRepository>(),
        getIt<BusinessFulfillmentRepository>(),
      ),
    )
    ..registerLazySingleton<BusinessDeliveryExceptionRepository>(
      () => InMemoryBusinessDeliveryExceptionRepository(
        getIt<BusinessOwnerProfileRepository>(),
        getIt<BusinessDeliveryTaskRepository>(),
      ),
    )
    ..registerLazySingleton<BusinessDeliveryProofRepository>(
      () => InMemoryBusinessDeliveryProofRepository(
        getIt<BusinessOwnerProfileRepository>(),
        getIt<BusinessDeliveryTaskRepository>(),
      ),
    )
    ..registerLazySingleton<ReviewTransactionEligibilityProvider>(
      () => InMemoryDemoReviewTransactionEligibilityProvider(
        getIt<BusinessOwnerProfileRepository>(),
      ),
    )
    ..registerLazySingleton<BusinessReputationEventRepository>(
      () => InMemoryBusinessReputationEventRepository(
        getIt<BusinessOwnerProfileRepository>(),
      ),
    )
    ..registerLazySingleton<BusinessReputationSignalCollector>(
      () => BusinessReputationSignalCollector(
        getIt<BusinessReputationEventRepository>(),
      ),
    )
    ..registerLazySingleton<BusinessReviewRepository>(
      () => InMemoryBusinessReviewRepository(
        getIt<BusinessOwnerProfileRepository>(),
        getIt<ReviewTransactionEligibilityProvider>(),
        signalCollector: getIt<BusinessReputationSignalCollector>(),
      ),
    )
    ..registerLazySingleton<BusinessComplaintRepository>(
      () => InMemoryBusinessComplaintRepository(
        getIt<BusinessOwnerProfileRepository>(),
        getIt<BusinessReviewRepository>(),
        signalCollector: getIt<BusinessReputationSignalCollector>(),
      ),
    )
    ..registerLazySingleton<BusinessDisputeRepository>(
      () => InMemoryBusinessDisputeRepository(
        getIt<BusinessOwnerProfileRepository>(),
        getIt<BusinessComplaintRepository>(),
        signalCollector: getIt<BusinessReputationSignalCollector>(),
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
    ..registerLazySingleton<BusinessCatalogPricingController>(
      () => BusinessCatalogPricingController(
        getIt<BusinessCatalogPricingRepository>(),
      ),
    )
    ..registerLazySingleton<BusinessCatalogDiscountController>(
      () => BusinessCatalogDiscountController(
        getIt<BusinessCatalogDiscountRepository>(),
      ),
    )
    ..registerLazySingleton<BusinessCatalogPromoCodeController>(
      () => BusinessCatalogPromoCodeController(
        getIt<BusinessCatalogPromoCodeRepository>(),
        getIt<BusinessCatalogDiscountRepository>(),
      ),
    )
    ..registerLazySingleton<BusinessCatalogCommercialFeeController>(
      () => BusinessCatalogCommercialFeeController(
        getIt<BusinessCatalogCommercialFeeRepository>(),
      ),
    )
    ..registerLazySingleton<BusinessFulfillmentController>(
      () => BusinessFulfillmentController(
        getIt<BusinessFulfillmentRepository>(),
      ),
    )
    ..registerLazySingleton<BusinessDeliveryTaskController>(
      () => BusinessDeliveryTaskController(
        getIt<BusinessDeliveryTaskRepository>(),
      ),
    )
    ..registerLazySingleton<BusinessDeliveryExceptionController>(
      () => BusinessDeliveryExceptionController(
        getIt<BusinessDeliveryExceptionRepository>(),
      ),
    )
    ..registerLazySingleton<BusinessDeliveryProofController>(
      () => BusinessDeliveryProofController(
        getIt<BusinessDeliveryProofRepository>(),
      ),
    )
    ..registerLazySingleton<BusinessReviewController>(
      () => BusinessReviewController(
        getIt<BusinessReviewRepository>(),
      ),
    )
    ..registerLazySingleton<BusinessComplaintController>(
      () => BusinessComplaintController(
        getIt<BusinessComplaintRepository>(),
      ),
    )
    ..registerLazySingleton<BusinessDisputeController>(
      () => BusinessDisputeController(
        getIt<BusinessDisputeRepository>(),
      ),
    )
    ..registerLazySingleton<BusinessReputationEventController>(
      () => BusinessReputationEventController(
        getIt<BusinessReputationEventRepository>(),
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
    ..registerLazySingleton<QoshniSearchVocabularyRepository>(
      InMemoryQoshniSearchVocabularyRepository.new,
    )
    ..registerLazySingleton<QoshniSearchQueryProcessor>(
      () => QoshniSearchQueryProcessor(
        getIt<QoshniSearchVocabularyRepository>(),
      ),
    )
    ..registerLazySingleton<QoshniSearchAutocompleteService>(
      () => QoshniSearchAutocompleteService(
        getIt<QoshniSearchVocabularyRepository>(),
      ),
    )
    ..registerLazySingleton<QoshniSearchIndexRepository>(
      InMemoryQoshniSearchIndexRepository.new,
    )
    ..registerLazySingleton<QoshniSearchExecutionService>(
      () => QoshniSearchExecutionService(
        queryProcessor: getIt<QoshniSearchQueryProcessor>(),
        indexRepository: getIt<QoshniSearchIndexRepository>(),
      ),
    )
    ..registerLazySingleton<RemoteQoshniSearchDataSource>(
      () => RemoteQoshniSearchDataSource(apiClient: getIt<ApiClient>()),
    )
    ..registerLazySingleton<QoshniSearchMapFocusController>(
      QoshniSearchMapFocusController.new,
    )
    ..registerLazySingleton<QoshniSearchExecutionCoordinator>(
      () => QoshniSearchExecutionCoordinator(
        config: getIt<AppConfig>(),
        demoExecutionService: getIt<QoshniSearchExecutionService>(),
        remoteDataSource: getIt<RemoteQoshniSearchDataSource>(),
        authController: getIt<AuthController>(),
      ),
    )
    ..registerLazySingleton<QoshniLocationProvider>(
      GeolocatorQoshniLocationProvider.new,
    )
    ..registerLazySingleton<QoshniLocationService>(
      () => QoshniLocationService(getIt<QoshniLocationProvider>()),
    )
    ..registerLazySingleton<QoshniMapLocationController>(
      () => QoshniMapLocationController(getIt<QoshniLocationService>()),
    )
    ..registerLazySingleton<QoshniGeocodingProvider>(
      MapboxQoshniGeocodingProvider.new,
    )
    ..registerLazySingleton<QoshniGeocodingService>(
      () => QoshniGeocodingService(getIt<QoshniGeocodingProvider>()),
    )
    ..registerLazySingleton<QoshniSavedPlacesController>(
      () => QoshniSavedPlacesController(
        config: getIt<AppConfig>(),
        authController: getIt<AuthController>(),
        apiClient: getIt<ApiClient>(),
      ),
    )
    ..registerLazySingleton<QoshniSearchLocationSelectionController>(
      QoshniSearchLocationSelectionController.new,
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

import 'package:qoshni/features/business_platform/domain/business_catalog_price_status.dart';
import 'package:qoshni/features/business_platform/domain/business_fulfillment_configuration.dart';
import 'package:qoshni/features/business_platform/domain/business_fulfillment_history_event.dart';
import 'package:qoshni/features/business_platform/domain/business_fulfillment_target_scope.dart';
import 'package:qoshni/features/business_platform/domain/business_fulfillment_type.dart';

enum BusinessFulfillmentSaveResult {
  success,
  notFound,
  emptyFulfillmentTypes,
  duplicateFulfillmentType,
  invalidTarget,
  invalidBranch,
  activeImmutable,
  activeTargetConflict,
  notDraft,
  failure,
}

enum BusinessFulfillmentStatusChangeResult {
  success,
  notFound,
  notDraft,
  activeTargetConflict,
  failure,
}

abstract class BusinessFulfillmentRepository {
  String get businessScopeId;

  List<BusinessFulfillmentConfiguration> listForCurrentScope({
    String? branchId,
    BusinessFulfillmentType? fulfillmentType,
    BusinessCatalogPriceStatus? status,
    bool includeArchived = false,
  });

  BusinessFulfillmentConfiguration? findById(String configurationId);

  BusinessFulfillmentSaveResult createDraft(
    BusinessFulfillmentConfigurationInput input,
  );

  BusinessFulfillmentSaveResult updateDraft({
    required String configurationId,
    required BusinessFulfillmentConfigurationInput input,
  });

  BusinessFulfillmentStatusChangeResult activateConfiguration(
    String configurationId,
  );

  BusinessFulfillmentStatusChangeResult archiveConfiguration(
    String configurationId,
  );

  List<BusinessFulfillmentHistoryEvent> configurationHistory(
    String configurationId,
  );

  BusinessFulfillmentConfiguration? activeConfigurationForTarget({
    required String branchId,
    required BusinessFulfillmentTargetScope targetScope,
    String? listingId,
    String? excludeConfigurationId,
  });
}

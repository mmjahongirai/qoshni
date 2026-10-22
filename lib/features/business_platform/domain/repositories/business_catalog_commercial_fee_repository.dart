import 'package:qoshni/features/business_platform/domain/business_catalog_commercial_fee_application_basis.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_commercial_fee_charge_bearer.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_commercial_fee_history_event.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_commercial_fee_rule.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_commercial_fee_type.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_price_status.dart';

enum BusinessCatalogCommercialFeeSaveResult {
  success,
  notFound,
  invalidFeeValue,
  invalidEffectiveRange,
  invalidBranch,
  activeImmutable,
  activeIntervalOverlap,
  notDraft,
  failure,
}

enum BusinessCatalogCommercialFeeStatusChangeResult {
  success,
  notFound,
  notDraft,
  invalidEffectiveRange,
  activeIntervalOverlap,
  failure,
}

abstract class BusinessCatalogCommercialFeeRepository {
  String get businessScopeId;

  List<BusinessCatalogCommercialFeeRule> listForCurrentScope({
    String? branchId,
    BusinessCatalogCommercialFeeType? feeType,
    BusinessCatalogPriceStatus? status,
    bool includeArchived = false,
  });

  BusinessCatalogCommercialFeeRule? findById(String feeRuleId);

  BusinessCatalogCommercialFeeSaveResult createDraft(
    BusinessCatalogCommercialFeeRuleInput input,
  );

  BusinessCatalogCommercialFeeSaveResult updateDraft({
    required String feeRuleId,
    required BusinessCatalogCommercialFeeRuleInput input,
  });

  BusinessCatalogCommercialFeeSaveResult createRevisionFromRule({
    required String sourceRuleId,
    required BusinessCatalogCommercialFeeRuleInput input,
  });

  BusinessCatalogCommercialFeeStatusChangeResult activateRule(String feeRuleId);

  BusinessCatalogCommercialFeeStatusChangeResult archiveRule(String feeRuleId);

  List<BusinessCatalogCommercialFeeHistoryEvent> ruleHistory(String feeRuleId);

  List<BusinessCatalogCommercialFeeRule> activeRulesOverlappingScope({
    String? branchId,
    required BusinessCatalogCommercialFeeType feeType,
    required BusinessCatalogCommercialFeeChargeBearer chargeBearer,
    required BusinessCatalogCommercialFeeApplicationBasis applicationBasis,
    required DateTime effectiveFrom,
    DateTime? effectiveUntil,
    String? excludeRuleId,
  });
}

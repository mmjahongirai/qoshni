import 'package:qoshni/features/business_platform/domain/business_catalog_discount_history_event.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_discount_rule.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_discount_target_scope.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_price_status.dart';

enum BusinessCatalogDiscountSaveResult {
  success,
  notFound,
  invalidDiscountValue,
  invalidMinimumBasket,
  invalidEffectiveRange,
  invalidTarget,
  invalidBranch,
  invalidVariant,
  activeImmutable,
  activeIntervalOverlap,
  notDraft,
  failure,
}

enum BusinessCatalogDiscountStatusChangeResult {
  success,
  notFound,
  notDraft,
  invalidEffectiveRange,
  activeIntervalOverlap,
  failure,
}

abstract class BusinessCatalogDiscountRepository {
  String get businessScopeId;

  List<BusinessCatalogDiscountRule> listForCurrentScope({
    String? branchId,
    BusinessCatalogDiscountTargetScope? targetScope,
    BusinessCatalogPriceStatus? status,
    bool includeArchived = false,
  });

  BusinessCatalogDiscountRule? findById(String discountRuleId);

  BusinessCatalogDiscountSaveResult createDraft(
    BusinessCatalogDiscountRuleInput input,
  );

  BusinessCatalogDiscountSaveResult updateDraft({
    required String discountRuleId,
    required BusinessCatalogDiscountRuleInput input,
  });

  BusinessCatalogDiscountSaveResult createRevisionFromRule({
    required String sourceRuleId,
    required BusinessCatalogDiscountRuleInput input,
  });

  BusinessCatalogDiscountStatusChangeResult activateRule(String discountRuleId);

  BusinessCatalogDiscountStatusChangeResult archiveRule(String discountRuleId);

  List<BusinessCatalogDiscountHistoryEvent> ruleHistory(String discountRuleId);

  /// Active rules with the same branch/target key and overlapping intervals.
  List<BusinessCatalogDiscountRule> activeRulesOverlappingTarget({
    required String branchId,
    required BusinessCatalogDiscountTargetScope targetScope,
    String? listingId,
    String? variantId,
    required DateTime effectiveFrom,
    DateTime? effectiveUntil,
    String? excludeRuleId,
  });
}

import 'package:qoshni/features/business_platform/data/business_catalog_discount_demo_seed.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_discount_history_event.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_discount_rule.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_discount_target_scope.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_discount_type.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_price_status.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_product.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_branch_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_catalog_discount_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_catalog_product_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_catalog_product_variant_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_catalog_service_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_owner_profile_repository.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_discount_validation.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_pricing_validation.dart';

class InMemoryBusinessCatalogDiscountRepository
    implements BusinessCatalogDiscountRepository {
  InMemoryBusinessCatalogDiscountRepository(
    this._ownerProfileRepository,
    this._productRepository,
    this._serviceRepository,
    this._variantRepository,
    this._branchRepository,
  );

  final BusinessOwnerProfileRepository _ownerProfileRepository;
  final BusinessCatalogProductRepository _productRepository;
  final BusinessCatalogServiceRepository _serviceRepository;
  final BusinessCatalogProductVariantRepository _variantRepository;
  final BusinessBranchRepository _branchRepository;

  final Map<String, List<BusinessCatalogDiscountRule>> _byScope = {};
  final Map<String, Map<String, List<BusinessCatalogDiscountHistoryEvent>>>
      _historyByScope = {};

  int _ruleCounter = 0;
  int _eventCounter = 0;

  bool failNextSave = false;

  @override
  String get businessScopeId =>
      _ownerProfileRepository.ensureSessionProfile().sessionProfileId;

  @override
  List<BusinessCatalogDiscountRule> listForCurrentScope({
    String? branchId,
    BusinessCatalogDiscountTargetScope? targetScope,
    BusinessCatalogPriceStatus? status,
    bool includeArchived = false,
  }) {
    var list = List<BusinessCatalogDiscountRule>.from(_ensureScopeList());
    if (!includeArchived) {
      list = list
          .where((r) => r.status != BusinessCatalogPriceStatus.archived)
          .toList();
    }
    if (branchId != null && branchId.trim().isNotEmpty) {
      final id = branchId.trim();
      list = list.where((r) => r.branchId == id).toList();
    }
    if (targetScope != null) {
      list = list.where((r) => r.targetScope == targetScope).toList();
    }
    if (status != null) {
      list = list.where((r) => r.status == status).toList();
    }
    return List.unmodifiable(list);
  }

  @override
  BusinessCatalogDiscountRule? findById(String discountRuleId) {
    try {
      return _ensureScopeList()
          .firstWhere((r) => r.discountRuleId == discountRuleId);
    } on StateError {
      return null;
    }
  }

  @override
  List<BusinessCatalogDiscountRule> activeRulesOverlappingTarget({
    required String branchId,
    required BusinessCatalogDiscountTargetScope targetScope,
    String? listingId,
    String? variantId,
    required DateTime effectiveFrom,
    DateTime? effectiveUntil,
    String? excludeRuleId,
  }) {
    final listing = listingId?.trim() ?? '';
    final variant = variantId?.trim() ?? '';
    return _ensureScopeList().where((r) {
      if (r.status != BusinessCatalogPriceStatus.active) {
        return false;
      }
      if (excludeRuleId != null && r.discountRuleId == excludeRuleId) {
        return false;
      }
      if (r.branchId != branchId.trim() || r.targetScope != targetScope) {
        return false;
      }
      final rListing = r.listingId?.trim() ?? '';
      final rVariant = r.variantId?.trim() ?? '';
      if (rListing != listing || rVariant != variant) {
        return false;
      }
      return catalogPriceIntervalsOverlap(
        fromA: r.effectiveFrom,
        untilA: r.effectiveUntil,
        fromB: effectiveFrom,
        untilB: effectiveUntil,
      );
    }).toList(growable: false);
  }

  @override
  BusinessCatalogDiscountSaveResult createDraft(
    BusinessCatalogDiscountRuleInput input,
  ) {
    if (failNextSave) {
      failNextSave = false;
      return BusinessCatalogDiscountSaveResult.failure;
    }
    return _saveDraftCreate(input);
  }

  @override
  BusinessCatalogDiscountSaveResult updateDraft({
    required String discountRuleId,
    required BusinessCatalogDiscountRuleInput input,
  }) {
    if (failNextSave) {
      failNextSave = false;
      return BusinessCatalogDiscountSaveResult.failure;
    }
    final list = _ensureScopeList();
    final index = list.indexWhere((r) => r.discountRuleId == discountRuleId);
    if (index < 0) {
      return BusinessCatalogDiscountSaveResult.notFound;
    }
    final existing = list[index];
    if (existing.status != BusinessCatalogPriceStatus.draft) {
      if (existing.status == BusinessCatalogPriceStatus.active) {
        return BusinessCatalogDiscountSaveResult.activeImmutable;
      }
      return BusinessCatalogDiscountSaveResult.notDraft;
    }
    final validated = _validateInput(input);
    if (validated != null) {
      return validated;
    }

    final normalized = _normalizeInput(input);
    final now = DateTime.now().toUtc();
    list[index] = _ruleFromInput(
      existing: existing,
      normalized: normalized,
      status: BusinessCatalogPriceStatus.draft,
      revision: existing.revision,
      now: now,
    );
    _appendHistory(
      BusinessCatalogDiscountHistoryEvent(
        eventId: _nextEventId(),
        discountRuleId: discountRuleId,
        action: BusinessCatalogDiscountHistoryAction.draftUpdated,
        previousRevision: existing.revision,
        newRevision: existing.revision,
        previousPercentBasisPoints: existing.percentBasisPoints,
        newPercentBasisPoints: normalized.percentBasisPoints,
        previousFixedAmountSom: existing.fixedAmountSom,
        newFixedAmountSom: normalized.fixedAmountSom,
        recordedAt: now,
      ),
    );
    return BusinessCatalogDiscountSaveResult.success;
  }

  @override
  BusinessCatalogDiscountSaveResult createRevisionFromRule({
    required String sourceRuleId,
    required BusinessCatalogDiscountRuleInput input,
  }) {
    if (failNextSave) {
      failNextSave = false;
      return BusinessCatalogDiscountSaveResult.failure;
    }
    final source = findById(sourceRuleId);
    if (source == null) {
      return BusinessCatalogDiscountSaveResult.notFound;
    }
    if (source.status != BusinessCatalogPriceStatus.active) {
      return BusinessCatalogDiscountSaveResult.notDraft;
    }
    final validated = _validateInput(input);
    if (validated != null) {
      return validated;
    }

    _ruleCounter++;
    final now = DateTime.now().toUtc();
    final normalized = _normalizeInput(input);
    final rule = BusinessCatalogDiscountRule(
      discountRuleId: 'session-catalog-discount-$_ruleCounter',
      businessScopeId: businessScopeId,
      branchId: normalized.branchId,
      targetScope: normalized.targetScope,
      listingId: normalized.listingId,
      variantId: normalized.variantId,
      discountType: normalized.discountType,
      percentBasisPoints: normalized.percentBasisPoints,
      fixedAmountSom: normalized.fixedAmountSom,
      minimumBasketAmountSom: normalized.minimumBasketAmountSom,
      status: BusinessCatalogPriceStatus.draft,
      effectiveFrom: normalized.effectiveFrom,
      effectiveUntil: normalized.effectiveUntil,
      priority: normalized.priority,
      revision: source.revision + 1,
      dataSource: BusinessCatalogProductDataSource.userSession,
      createdAt: now,
      updatedAt: now,
    );
    _ensureScopeList().add(rule);
    _appendHistory(
      BusinessCatalogDiscountHistoryEvent(
        eventId: _nextEventId(),
        discountRuleId: rule.discountRuleId,
        action: BusinessCatalogDiscountHistoryAction.revisionCreated,
        previousRevision: source.revision,
        newRevision: rule.revision,
        newPercentBasisPoints: rule.percentBasisPoints,
        newFixedAmountSom: rule.fixedAmountSom,
        recordedAt: now,
        reason: 'revision_from_${source.discountRuleId}',
      ),
    );
    return BusinessCatalogDiscountSaveResult.success;
  }

  @override
  BusinessCatalogDiscountStatusChangeResult activateRule(String discountRuleId) {
    if (failNextSave) {
      failNextSave = false;
      return BusinessCatalogDiscountStatusChangeResult.failure;
    }
    final list = _ensureScopeList();
    final index = list.indexWhere((r) => r.discountRuleId == discountRuleId);
    if (index < 0) {
      return BusinessCatalogDiscountStatusChangeResult.notFound;
    }
    final existing = list[index];
    if (existing.status != BusinessCatalogPriceStatus.draft) {
      return BusinessCatalogDiscountStatusChangeResult.notDraft;
    }
    if (!catalogPriceEffectiveRangeValid(
      effectiveFrom: existing.effectiveFrom,
      effectiveUntil: existing.effectiveUntil,
    )) {
      return BusinessCatalogDiscountStatusChangeResult.invalidEffectiveRange;
    }
    final overlaps = activeRulesOverlappingTarget(
      branchId: existing.branchId,
      targetScope: existing.targetScope,
      listingId: existing.listingId,
      variantId: existing.variantId,
      effectiveFrom: existing.effectiveFrom,
      effectiveUntil: existing.effectiveUntil,
      excludeRuleId: existing.discountRuleId,
    );
    if (overlaps.isNotEmpty) {
      return BusinessCatalogDiscountStatusChangeResult.activeIntervalOverlap;
    }

    final now = DateTime.now().toUtc();
    list[index] = existing.copyWith(
      status: BusinessCatalogPriceStatus.active,
      updatedAt: now,
    );
    _appendHistory(
      BusinessCatalogDiscountHistoryEvent(
        eventId: _nextEventId(),
        discountRuleId: discountRuleId,
        action: BusinessCatalogDiscountHistoryAction.activated,
        previousRevision: existing.revision,
        newRevision: existing.revision,
        recordedAt: now,
      ),
    );
    return BusinessCatalogDiscountStatusChangeResult.success;
  }

  @override
  BusinessCatalogDiscountStatusChangeResult archiveRule(String discountRuleId) {
    final list = _ensureScopeList();
    final index = list.indexWhere((r) => r.discountRuleId == discountRuleId);
    if (index < 0) {
      return BusinessCatalogDiscountStatusChangeResult.notFound;
    }
    final existing = list[index];
    if (existing.status == BusinessCatalogPriceStatus.archived) {
      return BusinessCatalogDiscountStatusChangeResult.success;
    }
    final now = DateTime.now().toUtc();
    list[index] = existing.copyWith(
      status: BusinessCatalogPriceStatus.archived,
      updatedAt: now,
    );
    _appendHistory(
      BusinessCatalogDiscountHistoryEvent(
        eventId: _nextEventId(),
        discountRuleId: discountRuleId,
        action: BusinessCatalogDiscountHistoryAction.archived,
        previousRevision: existing.revision,
        newRevision: existing.revision,
        recordedAt: now,
      ),
    );
    return BusinessCatalogDiscountStatusChangeResult.success;
  }

  @override
  List<BusinessCatalogDiscountHistoryEvent> ruleHistory(String discountRuleId) {
    if (findById(discountRuleId) == null) {
      return const [];
    }
    final scopeHistory = _ensureScopeHistory();
    return List.unmodifiable(scopeHistory[discountRuleId] ?? const []);
  }

  BusinessCatalogDiscountSaveResult _saveDraftCreate(
    BusinessCatalogDiscountRuleInput input,
  ) {
    final validated = _validateInput(input);
    if (validated != null) {
      return validated;
    }
    _ruleCounter++;
    final now = DateTime.now().toUtc();
    final normalized = _normalizeInput(input);
    final rule = BusinessCatalogDiscountRule(
      discountRuleId: 'session-catalog-discount-$_ruleCounter',
      businessScopeId: businessScopeId,
      branchId: normalized.branchId,
      targetScope: normalized.targetScope,
      listingId: normalized.listingId,
      variantId: normalized.variantId,
      discountType: normalized.discountType,
      percentBasisPoints: normalized.percentBasisPoints,
      fixedAmountSom: normalized.fixedAmountSom,
      minimumBasketAmountSom: normalized.minimumBasketAmountSom,
      status: BusinessCatalogPriceStatus.draft,
      effectiveFrom: normalized.effectiveFrom,
      effectiveUntil: normalized.effectiveUntil,
      priority: normalized.priority,
      revision: 1,
      dataSource: BusinessCatalogProductDataSource.userSession,
      createdAt: now,
      updatedAt: now,
    );
    _ensureScopeList().add(rule);
    _appendHistory(
      BusinessCatalogDiscountHistoryEvent(
        eventId: _nextEventId(),
        discountRuleId: rule.discountRuleId,
        action: BusinessCatalogDiscountHistoryAction.created,
        newRevision: 1,
        newPercentBasisPoints: rule.percentBasisPoints,
        newFixedAmountSom: rule.fixedAmountSom,
        recordedAt: now,
      ),
    );
    return BusinessCatalogDiscountSaveResult.success;
  }

  BusinessCatalogDiscountSaveResult? _validateInput(
    BusinessCatalogDiscountRuleInput input,
  ) {
    if (!catalogPriceEffectiveRangeValid(
      effectiveFrom: input.effectiveFrom,
      effectiveUntil: input.effectiveUntil,
    )) {
      return BusinessCatalogDiscountSaveResult.invalidEffectiveRange;
    }
    final validation = catalogDiscountInputValidationError(input);
    if (validation != null) {
      switch (validation) {
        case 'invalid_discount_value':
          return BusinessCatalogDiscountSaveResult.invalidDiscountValue;
        case 'invalid_minimum_basket':
          return BusinessCatalogDiscountSaveResult.invalidMinimumBasket;
        case 'variant_on_service':
          return BusinessCatalogDiscountSaveResult.invalidVariant;
        case 'invalid_target':
          return BusinessCatalogDiscountSaveResult.invalidTarget;
      }
    }
    final branch = _branchRepository.findById(input.branchId.trim());
    if (branch == null || branch.businessScopeId != businessScopeId) {
      return BusinessCatalogDiscountSaveResult.invalidBranch;
    }
    switch (input.targetScope) {
      case BusinessCatalogDiscountTargetScope.businessWide:
        break;
      case BusinessCatalogDiscountTargetScope.product:
        final product =
            _productRepository.findById(input.listingId!.trim());
        if (product == null || product.businessScopeId != businessScopeId) {
          return BusinessCatalogDiscountSaveResult.invalidTarget;
        }
        final variantId = input.variantId?.trim();
        if (variantId != null && variantId.isNotEmpty) {
          final variant = _variantRepository.findById(variantId);
          if (variant == null ||
              variant.businessScopeId != businessScopeId ||
              variant.productId != product.productId) {
            return BusinessCatalogDiscountSaveResult.invalidVariant;
          }
        }
      case BusinessCatalogDiscountTargetScope.service:
        final service =
            _serviceRepository.findById(input.listingId!.trim());
        if (service == null || service.businessScopeId != businessScopeId) {
          return BusinessCatalogDiscountSaveResult.invalidTarget;
        }
    }
    return null;
  }

  BusinessCatalogDiscountRule _ruleFromInput({
    required BusinessCatalogDiscountRule existing,
    required BusinessCatalogDiscountRuleInput normalized,
    required BusinessCatalogPriceStatus status,
    required int revision,
    required DateTime now,
  }) {
    return BusinessCatalogDiscountRule(
      discountRuleId: existing.discountRuleId,
      businessScopeId: existing.businessScopeId,
      branchId: normalized.branchId,
      targetScope: normalized.targetScope,
      listingId: normalized.listingId,
      variantId: normalized.variantId,
      discountType: normalized.discountType,
      percentBasisPoints: normalized.discountType ==
              BusinessCatalogDiscountType.percentage
          ? normalized.percentBasisPoints
          : null,
      fixedAmountSom:
          normalized.discountType == BusinessCatalogDiscountType.fixedAmount
              ? normalized.fixedAmountSom
              : null,
      minimumBasketAmountSom: normalized.minimumBasketAmountSom,
      status: status,
      effectiveFrom: normalized.effectiveFrom,
      effectiveUntil: normalized.effectiveUntil,
      priority: normalized.priority,
      revision: revision,
      dataSource: existing.dataSource,
      createdAt: existing.createdAt,
      updatedAt: now,
    );
  }

  BusinessCatalogDiscountRuleInput _normalizeInput(
    BusinessCatalogDiscountRuleInput input,
  ) {
    final listing = input.listingId?.trim();
    final variant = input.variantId?.trim();
    return BusinessCatalogDiscountRuleInput(
      branchId: input.branchId.trim(),
      targetScope: input.targetScope,
      listingId: listing != null && listing.isEmpty ? null : listing,
      variantId: variant != null && variant.isEmpty ? null : variant,
      discountType: input.discountType,
      percentBasisPoints: input.discountType ==
              BusinessCatalogDiscountType.percentage
          ? input.percentBasisPoints
          : null,
      fixedAmountSom: input.discountType == BusinessCatalogDiscountType.fixedAmount
          ? input.fixedAmountSom
          : null,
      minimumBasketAmountSom: input.minimumBasketAmountSom,
      effectiveFrom: input.effectiveFrom.toUtc(),
      effectiveUntil: input.effectiveUntil?.toUtc(),
      priority: input.priority,
    );
  }

  void _appendHistory(BusinessCatalogDiscountHistoryEvent event) {
    final scopeHistory = _ensureScopeHistory();
    scopeHistory.putIfAbsent(event.discountRuleId, () => []).add(event);
  }

  String _nextEventId() {
    _eventCounter++;
    return 'session-catalog-discount-event-$_eventCounter';
  }

  List<BusinessCatalogDiscountRule> _ensureScopeList() {
    return _byScope.putIfAbsent(
      businessScopeId,
      () => buildDemoCatalogDiscountRules(businessScopeId: businessScopeId),
    );
  }

  Map<String, List<BusinessCatalogDiscountHistoryEvent>> _ensureScopeHistory() {
    return _historyByScope.putIfAbsent(businessScopeId, () => {});
  }
}

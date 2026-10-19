import 'package:qoshni/features/business_platform/data/business_catalog_commercial_fee_demo_seed.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_commercial_fee_application_basis.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_commercial_fee_calculation_type.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_commercial_fee_charge_bearer.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_commercial_fee_history_event.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_commercial_fee_rule.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_commercial_fee_type.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_price_status.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_product.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_branch_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_catalog_commercial_fee_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_owner_profile_repository.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_commercial_fee_validation.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_pricing_validation.dart';

class InMemoryBusinessCatalogCommercialFeeRepository
    implements BusinessCatalogCommercialFeeRepository {
  InMemoryBusinessCatalogCommercialFeeRepository(
    this._ownerProfileRepository,
    this._branchRepository,
  );

  final BusinessOwnerProfileRepository _ownerProfileRepository;
  final BusinessBranchRepository _branchRepository;

  final Map<String, List<BusinessCatalogCommercialFeeRule>> _byScope = {};
  final Map<String, Map<String, List<BusinessCatalogCommercialFeeHistoryEvent>>>
      _historyByScope = {};

  int _ruleCounter = 0;
  int _eventCounter = 0;

  bool failNextSave = false;

  @override
  String get businessScopeId =>
      _ownerProfileRepository.ensureSessionProfile().sessionProfileId;

  @override
  List<BusinessCatalogCommercialFeeRule> listForCurrentScope({
    String? branchId,
    BusinessCatalogCommercialFeeType? feeType,
    BusinessCatalogPriceStatus? status,
    bool includeArchived = false,
  }) {
    var list = List<BusinessCatalogCommercialFeeRule>.from(_ensureScopeList());
    if (!includeArchived) {
      list = list
          .where((r) => r.status != BusinessCatalogPriceStatus.archived)
          .toList();
    }
    if (branchId != null && branchId.trim().isNotEmpty) {
      final id = branchId.trim();
      list = list
          .where((r) =>
              r.branchId == null ||
              r.branchId!.isEmpty ||
              r.branchId == id)
          .toList();
    }
    if (feeType != null) {
      list = list.where((r) => r.feeType == feeType).toList();
    }
    if (status != null) {
      list = list.where((r) => r.status == status).toList();
    }
    return List.unmodifiable(list);
  }

  @override
  BusinessCatalogCommercialFeeRule? findById(String feeRuleId) {
    try {
      return _ensureScopeList().firstWhere((r) => r.feeRuleId == feeRuleId);
    } on StateError {
      return null;
    }
  }

  @override
  List<BusinessCatalogCommercialFeeRule> activeRulesOverlappingScope({
    String? branchId,
    required BusinessCatalogCommercialFeeType feeType,
    required BusinessCatalogCommercialFeeChargeBearer chargeBearer,
    required BusinessCatalogCommercialFeeApplicationBasis applicationBasis,
    required DateTime effectiveFrom,
    DateTime? effectiveUntil,
    String? excludeRuleId,
  }) {
    final key = catalogCommercialFeeScopeKey(
      branchId: branchId,
      feeType: feeType,
      chargeBearer: chargeBearer,
      applicationBasis: applicationBasis,
    );
    return _ensureScopeList().where((r) {
      if (r.status != BusinessCatalogPriceStatus.active) {
        return false;
      }
      if (excludeRuleId != null && r.feeRuleId == excludeRuleId) {
        return false;
      }
      final ruleKey = catalogCommercialFeeScopeKey(
        branchId: r.branchId,
        feeType: r.feeType,
        chargeBearer: r.chargeBearer,
        applicationBasis: r.applicationBasis,
      );
      if (ruleKey != key) {
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
  BusinessCatalogCommercialFeeSaveResult createDraft(
    BusinessCatalogCommercialFeeRuleInput input,
  ) {
    if (failNextSave) {
      failNextSave = false;
      return BusinessCatalogCommercialFeeSaveResult.failure;
    }
    return _saveDraftCreate(input);
  }

  @override
  BusinessCatalogCommercialFeeSaveResult updateDraft({
    required String feeRuleId,
    required BusinessCatalogCommercialFeeRuleInput input,
  }) {
    if (failNextSave) {
      failNextSave = false;
      return BusinessCatalogCommercialFeeSaveResult.failure;
    }
    final list = _ensureScopeList();
    final index = list.indexWhere((r) => r.feeRuleId == feeRuleId);
    if (index < 0) {
      return BusinessCatalogCommercialFeeSaveResult.notFound;
    }
    final existing = list[index];
    if (existing.status != BusinessCatalogPriceStatus.draft) {
      if (existing.status == BusinessCatalogPriceStatus.active) {
        return BusinessCatalogCommercialFeeSaveResult.activeImmutable;
      }
      return BusinessCatalogCommercialFeeSaveResult.notDraft;
    }
    final validated = _validateInput(input);
    if (validated != null) {
      return validated;
    }
    final now = DateTime.now().toUtc();
    final normalized = _normalizeInput(input);
    list[index] = _ruleFromInput(
      existing: existing,
      normalized: normalized,
      status: BusinessCatalogPriceStatus.draft,
      revision: existing.revision,
      now: now,
    );
    _appendHistory(
      BusinessCatalogCommercialFeeHistoryEvent(
        eventId: _nextEventId(),
        feeRuleId: feeRuleId,
        action: BusinessCatalogCommercialFeeHistoryAction.draftUpdated,
        previousRevision: existing.revision,
        newRevision: existing.revision,
        previousPercentBasisPoints: existing.percentBasisPoints,
        newPercentBasisPoints: normalized.percentBasisPoints,
        previousFixedAmountSom: existing.fixedAmountSom,
        newFixedAmountSom: normalized.fixedAmountSom,
        recordedAt: now,
      ),
    );
    return BusinessCatalogCommercialFeeSaveResult.success;
  }

  @override
  BusinessCatalogCommercialFeeSaveResult createRevisionFromRule({
    required String sourceRuleId,
    required BusinessCatalogCommercialFeeRuleInput input,
  }) {
    if (failNextSave) {
      failNextSave = false;
      return BusinessCatalogCommercialFeeSaveResult.failure;
    }
    final source = findById(sourceRuleId);
    if (source == null) {
      return BusinessCatalogCommercialFeeSaveResult.notFound;
    }
    if (source.status != BusinessCatalogPriceStatus.active) {
      return BusinessCatalogCommercialFeeSaveResult.notDraft;
    }
    final validated = _validateInput(input);
    if (validated != null) {
      return validated;
    }
    _ruleCounter++;
    final now = DateTime.now().toUtc();
    final normalized = _normalizeInput(input);
    final rule = BusinessCatalogCommercialFeeRule(
      feeRuleId: 'session-catalog-fee-$_ruleCounter',
      businessScopeId: businessScopeId,
      branchId: normalized.branchId,
      feeType: normalized.feeType,
      chargeBearer: normalized.chargeBearer,
      calculationType: normalized.calculationType,
      fixedAmountSom: normalized.fixedAmountSom,
      percentBasisPoints: normalized.percentBasisPoints,
      applicationBasis: normalized.applicationBasis,
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
      BusinessCatalogCommercialFeeHistoryEvent(
        eventId: _nextEventId(),
        feeRuleId: rule.feeRuleId,
        action: BusinessCatalogCommercialFeeHistoryAction.revisionCreated,
        previousRevision: source.revision,
        newRevision: rule.revision,
        newPercentBasisPoints: rule.percentBasisPoints,
        newFixedAmountSom: rule.fixedAmountSom,
        recordedAt: now,
        reason: 'revision_from_${source.feeRuleId}',
      ),
    );
    return BusinessCatalogCommercialFeeSaveResult.success;
  }

  @override
  BusinessCatalogCommercialFeeStatusChangeResult activateRule(String feeRuleId) {
    if (failNextSave) {
      failNextSave = false;
      return BusinessCatalogCommercialFeeStatusChangeResult.failure;
    }
    final list = _ensureScopeList();
    final index = list.indexWhere((r) => r.feeRuleId == feeRuleId);
    if (index < 0) {
      return BusinessCatalogCommercialFeeStatusChangeResult.notFound;
    }
    final existing = list[index];
    if (existing.status != BusinessCatalogPriceStatus.draft) {
      return BusinessCatalogCommercialFeeStatusChangeResult.notDraft;
    }
    if (!catalogPriceEffectiveRangeValid(
      effectiveFrom: existing.effectiveFrom,
      effectiveUntil: existing.effectiveUntil,
    )) {
      return BusinessCatalogCommercialFeeStatusChangeResult.invalidEffectiveRange;
    }
    final overlaps = activeRulesOverlappingScope(
      branchId: existing.branchId,
      feeType: existing.feeType,
      chargeBearer: existing.chargeBearer,
      applicationBasis: existing.applicationBasis,
      effectiveFrom: existing.effectiveFrom,
      effectiveUntil: existing.effectiveUntil,
      excludeRuleId: existing.feeRuleId,
    );
    if (overlaps.isNotEmpty) {
      return BusinessCatalogCommercialFeeStatusChangeResult.activeIntervalOverlap;
    }

    final now = DateTime.now().toUtc();
    list[index] = existing.copyWith(
      status: BusinessCatalogPriceStatus.active,
      updatedAt: now,
    );
    _appendHistory(
      BusinessCatalogCommercialFeeHistoryEvent(
        eventId: _nextEventId(),
        feeRuleId: feeRuleId,
        action: BusinessCatalogCommercialFeeHistoryAction.activated,
        previousRevision: existing.revision,
        newRevision: existing.revision,
        recordedAt: now,
      ),
    );
    return BusinessCatalogCommercialFeeStatusChangeResult.success;
  }

  @override
  BusinessCatalogCommercialFeeStatusChangeResult archiveRule(String feeRuleId) {
    final list = _ensureScopeList();
    final index = list.indexWhere((r) => r.feeRuleId == feeRuleId);
    if (index < 0) {
      return BusinessCatalogCommercialFeeStatusChangeResult.notFound;
    }
    final existing = list[index];
    if (existing.status == BusinessCatalogPriceStatus.archived) {
      return BusinessCatalogCommercialFeeStatusChangeResult.success;
    }
    final now = DateTime.now().toUtc();
    list[index] = existing.copyWith(
      status: BusinessCatalogPriceStatus.archived,
      updatedAt: now,
    );
    _appendHistory(
      BusinessCatalogCommercialFeeHistoryEvent(
        eventId: _nextEventId(),
        feeRuleId: feeRuleId,
        action: BusinessCatalogCommercialFeeHistoryAction.archived,
        previousRevision: existing.revision,
        newRevision: existing.revision,
        recordedAt: now,
      ),
    );
    return BusinessCatalogCommercialFeeStatusChangeResult.success;
  }

  @override
  List<BusinessCatalogCommercialFeeHistoryEvent> ruleHistory(String feeRuleId) {
    if (findById(feeRuleId) == null) {
      return const [];
    }
    return List.unmodifiable(_ensureScopeHistory()[feeRuleId] ?? const []);
  }

  BusinessCatalogCommercialFeeSaveResult _saveDraftCreate(
    BusinessCatalogCommercialFeeRuleInput input,
  ) {
    final validated = _validateInput(input);
    if (validated != null) {
      return validated;
    }
    _ruleCounter++;
    final now = DateTime.now().toUtc();
    final normalized = _normalizeInput(input);
    final rule = BusinessCatalogCommercialFeeRule(
      feeRuleId: 'session-catalog-fee-$_ruleCounter',
      businessScopeId: businessScopeId,
      branchId: normalized.branchId,
      feeType: normalized.feeType,
      chargeBearer: normalized.chargeBearer,
      calculationType: normalized.calculationType,
      fixedAmountSom: normalized.fixedAmountSom,
      percentBasisPoints: normalized.percentBasisPoints,
      applicationBasis: normalized.applicationBasis,
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
      BusinessCatalogCommercialFeeHistoryEvent(
        eventId: _nextEventId(),
        feeRuleId: rule.feeRuleId,
        action: BusinessCatalogCommercialFeeHistoryAction.created,
        newRevision: 1,
        newPercentBasisPoints: rule.percentBasisPoints,
        newFixedAmountSom: rule.fixedAmountSom,
        recordedAt: now,
      ),
    );
    return BusinessCatalogCommercialFeeSaveResult.success;
  }

  BusinessCatalogCommercialFeeSaveResult? _validateInput(
    BusinessCatalogCommercialFeeRuleInput input,
  ) {
    if (!catalogPriceEffectiveRangeValid(
      effectiveFrom: input.effectiveFrom,
      effectiveUntil: input.effectiveUntil,
    )) {
      return BusinessCatalogCommercialFeeSaveResult.invalidEffectiveRange;
    }
    final validation = catalogCommercialFeeInputValidationError(input);
    if (validation != null) {
      return BusinessCatalogCommercialFeeSaveResult.invalidFeeValue;
    }
    final branch = input.branchId?.trim();
    if (branch != null && branch.isNotEmpty) {
      final found = _branchRepository.findById(branch);
      if (found == null || found.businessScopeId != businessScopeId) {
        return BusinessCatalogCommercialFeeSaveResult.invalidBranch;
      }
    }
    return null;
  }

  ({
    String? branchId,
    BusinessCatalogCommercialFeeType feeType,
    BusinessCatalogCommercialFeeChargeBearer chargeBearer,
    BusinessCatalogCommercialFeeCalculationType calculationType,
    int? fixedAmountSom,
    int? percentBasisPoints,
    BusinessCatalogCommercialFeeApplicationBasis applicationBasis,
    DateTime effectiveFrom,
    DateTime? effectiveUntil,
    int priority,
  }) _normalizeInput(BusinessCatalogCommercialFeeRuleInput input) {
    final branch = input.branchId?.trim();
    return (
      branchId: branch != null && branch.isEmpty ? null : branch,
      feeType: input.feeType,
      chargeBearer: input.chargeBearer,
      calculationType: input.calculationType,
      fixedAmountSom: input.calculationType ==
              BusinessCatalogCommercialFeeCalculationType.fixedAmount
          ? input.fixedAmountSom
          : null,
      percentBasisPoints: input.calculationType ==
              BusinessCatalogCommercialFeeCalculationType.percentage
          ? input.percentBasisPoints
          : null,
      applicationBasis: input.applicationBasis,
      effectiveFrom: input.effectiveFrom.toUtc(),
      effectiveUntil: input.effectiveUntil?.toUtc(),
      priority: input.priority,
    );
  }

  BusinessCatalogCommercialFeeRule _ruleFromInput({
    required BusinessCatalogCommercialFeeRule existing,
    required ({
      String? branchId,
      BusinessCatalogCommercialFeeType feeType,
      BusinessCatalogCommercialFeeChargeBearer chargeBearer,
      BusinessCatalogCommercialFeeCalculationType calculationType,
      int? fixedAmountSom,
      int? percentBasisPoints,
      BusinessCatalogCommercialFeeApplicationBasis applicationBasis,
      DateTime effectiveFrom,
      DateTime? effectiveUntil,
      int priority,
    }) normalized,
    required BusinessCatalogPriceStatus status,
    required int revision,
    required DateTime now,
  }) {
    return BusinessCatalogCommercialFeeRule(
      feeRuleId: existing.feeRuleId,
      businessScopeId: existing.businessScopeId,
      branchId: normalized.branchId,
      feeType: normalized.feeType,
      chargeBearer: normalized.chargeBearer,
      calculationType: normalized.calculationType,
      fixedAmountSom: normalized.fixedAmountSom,
      percentBasisPoints: normalized.percentBasisPoints,
      applicationBasis: normalized.applicationBasis,
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

  void _appendHistory(BusinessCatalogCommercialFeeHistoryEvent event) {
    _ensureScopeHistory().putIfAbsent(event.feeRuleId, () => []).add(event);
  }

  String _nextEventId() {
    _eventCounter++;
    return 'session-catalog-fee-event-$_eventCounter';
  }

  List<BusinessCatalogCommercialFeeRule> _ensureScopeList() {
    return _byScope.putIfAbsent(
      businessScopeId,
      () => buildDemoCatalogCommercialFeeRules(businessScopeId: businessScopeId),
    );
  }

  Map<String, List<BusinessCatalogCommercialFeeHistoryEvent>> _ensureScopeHistory() {
    return _historyByScope.putIfAbsent(businessScopeId, () => {});
  }
}

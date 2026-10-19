import 'package:qoshni/features/business_platform/data/business_catalog_promo_code_demo_seed.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_price_status.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_product.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_promo_code.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_promo_code_history_event.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_promo_code_usage_record.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_branch_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_catalog_discount_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_catalog_promo_code_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_owner_profile_repository.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_promo_code_validation.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_pricing_validation.dart';

class InMemoryBusinessCatalogPromoCodeRepository
    implements BusinessCatalogPromoCodeRepository {
  InMemoryBusinessCatalogPromoCodeRepository(
    this._ownerProfileRepository,
    this._branchRepository,
    this._discountRepository,
  );

  final BusinessOwnerProfileRepository _ownerProfileRepository;
  final BusinessBranchRepository _branchRepository;
  final BusinessCatalogDiscountRepository _discountRepository;

  final Map<String, List<BusinessCatalogPromoCode>> _byScope = {};
  final Map<String, Map<String, List<BusinessCatalogPromoCodeHistoryEvent>>>
      _historyByScope = {};
  final Map<String, List<BusinessCatalogPromoCodeUsageRecord>> _usageByScope =
      {};

  int _promoCounter = 0;
  int _eventCounter = 0;

  bool failNextSave = false;

  @override
  String get businessScopeId =>
      _ownerProfileRepository.ensureSessionProfile().sessionProfileId;

  @override
  List<BusinessCatalogPromoCode> listForCurrentScope({
    String? branchId,
    BusinessCatalogPriceStatus? status,
    bool includeArchived = false,
  }) {
    var list = List<BusinessCatalogPromoCode>.from(_ensureScopeList());
    if (!includeArchived) {
      list = list
          .where((p) => p.status != BusinessCatalogPriceStatus.archived)
          .toList();
    }
    if (branchId != null && branchId.trim().isNotEmpty) {
      final id = branchId.trim();
      list = list
          .where((p) => p.branchId == null || p.branchId!.isEmpty || p.branchId == id)
          .toList();
    }
    if (status != null) {
      list = list.where((p) => p.status == status).toList();
    }
    return List.unmodifiable(list);
  }

  @override
  BusinessCatalogPromoCode? findById(String promoCodeId) {
    try {
      return _ensureScopeList().firstWhere((p) => p.promoCodeId == promoCodeId);
    } on StateError {
      return null;
    }
  }

  @override
  BusinessCatalogPromoCode? findByNormalizedCode(String normalizedCode) {
    final code = catalogPromoCodeNormalize(normalizedCode);
    if (code == null) {
      return null;
    }
    try {
      return _ensureScopeList().firstWhere((p) => p.normalizedCode == code);
    } on StateError {
      return null;
    }
  }

  @override
  BusinessCatalogPromoCodeSaveResult createDraft(
    BusinessCatalogPromoCodeInput input,
  ) {
    if (failNextSave) {
      failNextSave = false;
      return BusinessCatalogPromoCodeSaveResult.failure;
    }
    return _createDraftInternal(input);
  }

  @override
  BusinessCatalogPromoCodeSaveResult updateDraft({
    required String promoCodeId,
    required BusinessCatalogPromoCodeInput input,
  }) {
    if (failNextSave) {
      failNextSave = false;
      return BusinessCatalogPromoCodeSaveResult.failure;
    }
    final list = _ensureScopeList();
    final index = list.indexWhere((p) => p.promoCodeId == promoCodeId);
    if (index < 0) {
      return BusinessCatalogPromoCodeSaveResult.notFound;
    }
    final existing = list[index];
    if (existing.status != BusinessCatalogPriceStatus.draft) {
      if (existing.status == BusinessCatalogPriceStatus.active) {
        return BusinessCatalogPromoCodeSaveResult.activeImmutable;
      }
      return BusinessCatalogPromoCodeSaveResult.notDraft;
    }
    final validated = _validateInput(input, excludePromoId: promoCodeId);
    if (validated != null) {
      return validated;
    }
    final normalized = _normalizeInput(input);
    final now = DateTime.now().toUtc();
    list[index] = existing.copyWith(
      branchId: normalized.branchId,
      clearBranchId: normalized.branchId == null,
      code: normalized.displayCode,
      normalizedCode: normalized.normalizedCode,
      discountRuleId: normalized.input.discountRuleId,
      effectiveFrom: normalized.input.effectiveFrom,
      effectiveUntil: normalized.input.effectiveUntil,
      clearEffectiveUntil: normalized.input.effectiveUntil == null,
      minimumBasketAmountSom: normalized.input.minimumBasketAmountSom,
      clearMinimumBasketAmountSom:
          normalized.input.minimumBasketAmountSom == null,
      maxTotalUses: normalized.input.maxTotalUses,
      clearMaxTotalUses: normalized.input.maxTotalUses == null,
      maxUsesPerCustomer: normalized.input.maxUsesPerCustomer,
      clearMaxUsesPerCustomer: normalized.input.maxUsesPerCustomer == null,
      updatedAt: now,
    );
    _appendHistory(
      BusinessCatalogPromoCodeHistoryEvent(
        eventId: _nextEventId(),
        promoCodeId: promoCodeId,
        action: BusinessCatalogPromoCodeHistoryAction.draftUpdated,
        previousRevision: existing.revision,
        newRevision: existing.revision,
        recordedAt: now,
      ),
    );
    return BusinessCatalogPromoCodeSaveResult.success;
  }

  @override
  BusinessCatalogPromoCodeSaveResult createRevisionFromPromo({
    required String sourcePromoCodeId,
    required BusinessCatalogPromoCodeInput input,
  }) {
    if (failNextSave) {
      failNextSave = false;
      return BusinessCatalogPromoCodeSaveResult.failure;
    }
    final source = findById(sourcePromoCodeId);
    if (source == null) {
      return BusinessCatalogPromoCodeSaveResult.notFound;
    }
    if (source.status != BusinessCatalogPriceStatus.active) {
      return BusinessCatalogPromoCodeSaveResult.notDraft;
    }
    final validated = _validateInput(input);
    if (validated != null) {
      return validated;
    }
    _promoCounter++;
    final now = DateTime.now().toUtc();
    final normalized = _normalizeInput(input);
    final promo = BusinessCatalogPromoCode(
      promoCodeId: 'session-catalog-promo-$_promoCounter',
      businessScopeId: businessScopeId,
      branchId: normalized.branchId,
      code: normalized.displayCode,
      normalizedCode: normalized.normalizedCode,
      discountRuleId: normalized.input.discountRuleId.trim(),
      status: BusinessCatalogPriceStatus.draft,
      effectiveFrom: normalized.input.effectiveFrom,
      effectiveUntil: normalized.input.effectiveUntil,
      minimumBasketAmountSom: normalized.input.minimumBasketAmountSom,
      maxTotalUses: normalized.input.maxTotalUses,
      maxUsesPerCustomer: normalized.input.maxUsesPerCustomer,
      revision: source.revision + 1,
      dataSource: BusinessCatalogProductDataSource.userSession,
      createdAt: now,
      updatedAt: now,
    );
    _ensureScopeList().add(promo);
    _appendHistory(
      BusinessCatalogPromoCodeHistoryEvent(
        eventId: _nextEventId(),
        promoCodeId: promo.promoCodeId,
        action: BusinessCatalogPromoCodeHistoryAction.revisionCreated,
        previousRevision: source.revision,
        newRevision: promo.revision,
        recordedAt: now,
        reason: 'revision_from_${source.promoCodeId}',
      ),
    );
    return BusinessCatalogPromoCodeSaveResult.success;
  }

  @override
  BusinessCatalogPromoCodeStatusChangeResult activatePromoCode(
    String promoCodeId,
  ) {
    if (failNextSave) {
      failNextSave = false;
      return BusinessCatalogPromoCodeStatusChangeResult.failure;
    }
    final list = _ensureScopeList();
    final index = list.indexWhere((p) => p.promoCodeId == promoCodeId);
    if (index < 0) {
      return BusinessCatalogPromoCodeStatusChangeResult.notFound;
    }
    final existing = list[index];
    if (existing.status != BusinessCatalogPriceStatus.draft) {
      return BusinessCatalogPromoCodeStatusChangeResult.notDraft;
    }
    if (!catalogPriceEffectiveRangeValid(
      effectiveFrom: existing.effectiveFrom,
      effectiveUntil: existing.effectiveUntil,
    )) {
      return BusinessCatalogPromoCodeStatusChangeResult.invalidEffectiveRange;
    }
    final linkResult = _validateDiscountLink(existing, asOf: DateTime.now().toUtc());
    if (linkResult != null) {
      return linkResult;
    }
    final now = DateTime.now().toUtc();
    list[index] = existing.copyWith(
      status: BusinessCatalogPriceStatus.active,
      updatedAt: now,
    );
    _appendHistory(
      BusinessCatalogPromoCodeHistoryEvent(
        eventId: _nextEventId(),
        promoCodeId: promoCodeId,
        action: BusinessCatalogPromoCodeHistoryAction.activated,
        previousRevision: existing.revision,
        newRevision: existing.revision,
        recordedAt: now,
      ),
    );
    return BusinessCatalogPromoCodeStatusChangeResult.success;
  }

  @override
  BusinessCatalogPromoCodeStatusChangeResult archivePromoCode(
    String promoCodeId,
  ) {
    final list = _ensureScopeList();
    final index = list.indexWhere((p) => p.promoCodeId == promoCodeId);
    if (index < 0) {
      return BusinessCatalogPromoCodeStatusChangeResult.notFound;
    }
    final existing = list[index];
    if (existing.status == BusinessCatalogPriceStatus.archived) {
      return BusinessCatalogPromoCodeStatusChangeResult.success;
    }
    final now = DateTime.now().toUtc();
    list[index] = existing.copyWith(
      status: BusinessCatalogPriceStatus.archived,
      updatedAt: now,
    );
    _appendHistory(
      BusinessCatalogPromoCodeHistoryEvent(
        eventId: _nextEventId(),
        promoCodeId: promoCodeId,
        action: BusinessCatalogPromoCodeHistoryAction.archived,
        previousRevision: existing.revision,
        newRevision: existing.revision,
        recordedAt: now,
      ),
    );
    return BusinessCatalogPromoCodeStatusChangeResult.success;
  }

  @override
  List<BusinessCatalogPromoCodeHistoryEvent> promoHistory(String promoCodeId) {
    if (findById(promoCodeId) == null) {
      return const [];
    }
    return List.unmodifiable(
      _ensureScopeHistory()[promoCodeId] ?? const [],
    );
  }

  @override
  List<BusinessCatalogPromoCodeUsageRecord> usageRecords(String promoCodeId) {
    if (findById(promoCodeId) == null) {
      return const [];
    }
    return List.unmodifiable(
      _ensureScopeUsage().where((u) => u.promoCodeId == promoCodeId).toList(),
    );
  }

  @override
  CatalogPromoUsageSnapshot usageSnapshot({
    required String promoCodeId,
    String? demoCustomerReference,
  }) {
    final records = usageRecords(promoCodeId);
    final customerRef = demoCustomerReference?.trim();
    final customerUses = customerRef == null || customerRef.isEmpty
        ? 0
        : records
            .where((r) => r.demoCustomerReference == customerRef)
            .length;
    return CatalogPromoUsageSnapshot(
      totalUses: records.length,
      usesForCustomer: customerUses,
    );
  }

  BusinessCatalogPromoCodeSaveResult _createDraftInternal(
    BusinessCatalogPromoCodeInput input,
  ) {
    final validated = _validateInput(input);
    if (validated != null) {
      return validated;
    }
    _promoCounter++;
    final now = DateTime.now().toUtc();
    final normalized = _normalizeInput(input);
    final promo = BusinessCatalogPromoCode(
      promoCodeId: 'session-catalog-promo-$_promoCounter',
      businessScopeId: businessScopeId,
      branchId: normalized.branchId,
      code: normalized.displayCode,
      normalizedCode: normalized.normalizedCode,
      discountRuleId: normalized.input.discountRuleId.trim(),
      status: BusinessCatalogPriceStatus.draft,
      effectiveFrom: normalized.input.effectiveFrom,
      effectiveUntil: normalized.input.effectiveUntil,
      minimumBasketAmountSom: normalized.input.minimumBasketAmountSom,
      maxTotalUses: normalized.input.maxTotalUses,
      maxUsesPerCustomer: normalized.input.maxUsesPerCustomer,
      revision: 1,
      dataSource: BusinessCatalogProductDataSource.userSession,
      createdAt: now,
      updatedAt: now,
    );
    _ensureScopeList().add(promo);
    _appendHistory(
      BusinessCatalogPromoCodeHistoryEvent(
        eventId: _nextEventId(),
        promoCodeId: promo.promoCodeId,
        action: BusinessCatalogPromoCodeHistoryAction.created,
        newRevision: 1,
        recordedAt: now,
      ),
    );
    return BusinessCatalogPromoCodeSaveResult.success;
  }

  BusinessCatalogPromoCodeSaveResult? _validateInput(
    BusinessCatalogPromoCodeInput input, {
    String? excludePromoId,
  }) {
    final validation = catalogPromoCodeInputValidationError(input);
    if (validation != null) {
      switch (validation) {
        case 'invalid_code':
          return BusinessCatalogPromoCodeSaveResult.invalidCode;
        case 'invalid_effective_range':
          return BusinessCatalogPromoCodeSaveResult.invalidEffectiveRange;
        case 'invalid_limits':
          return BusinessCatalogPromoCodeSaveResult.invalidCode;
      }
    }
    final normalized = catalogPromoCodeNormalize(input.code)!;
    final duplicate = _ensureScopeList().any(
      (p) =>
          p.normalizedCode == normalized &&
          (excludePromoId == null || p.promoCodeId != excludePromoId),
    );
    if (duplicate) {
      return BusinessCatalogPromoCodeSaveResult.duplicateCode;
    }
    final branchId = input.branchId?.trim();
    if (branchId != null && branchId.isNotEmpty) {
      final branch = _branchRepository.findById(branchId);
      if (branch == null || branch.businessScopeId != businessScopeId) {
        return BusinessCatalogPromoCodeSaveResult.invalidBranch;
      }
    }
    final discount =
        _discountRepository.findById(input.discountRuleId.trim());
    if (discount == null || discount.businessScopeId != businessScopeId) {
      return BusinessCatalogPromoCodeSaveResult.invalidDiscountLink;
    }
    return null;
  }

  BusinessCatalogPromoCodeStatusChangeResult? _validateDiscountLink(
    BusinessCatalogPromoCode promo, {
    required DateTime asOf,
  }) {
    final discount = _discountRepository.findById(promo.discountRuleId);
    if (discount == null) {
      return BusinessCatalogPromoCodeStatusChangeResult.invalidDiscountLink;
    }
    if (!catalogPromoDiscountLinkValidForActivate(
      promo: promo,
      discount: discount,
      asOf: asOf,
    )) {
      if (discount.status != BusinessCatalogPriceStatus.active) {
        return BusinessCatalogPromoCodeStatusChangeResult.discountLinkInactive;
      }
      return BusinessCatalogPromoCodeStatusChangeResult.discountIntervalMismatch;
    }
    return null;
  }

  ({BusinessCatalogPromoCodeInput input, String normalizedCode, String displayCode, String? branchId})
      _normalizeInput(BusinessCatalogPromoCodeInput input) {
    final normalized = catalogPromoCodeNormalize(input.code)!;
    final branch = input.branchId?.trim();
    return (
      input: BusinessCatalogPromoCodeInput(
        branchId: branch != null && branch.isEmpty ? null : branch,
        code: normalized,
        discountRuleId: input.discountRuleId.trim(),
        effectiveFrom: input.effectiveFrom.toUtc(),
        effectiveUntil: input.effectiveUntil?.toUtc(),
        minimumBasketAmountSom: input.minimumBasketAmountSom,
        maxTotalUses: input.maxTotalUses,
        maxUsesPerCustomer: input.maxUsesPerCustomer,
      ),
      normalizedCode: normalized,
      displayCode: normalized,
      branchId: branch != null && branch.isEmpty ? null : branch,
    );
  }

  void _appendHistory(BusinessCatalogPromoCodeHistoryEvent event) {
    _ensureScopeHistory().putIfAbsent(event.promoCodeId, () => []).add(event);
  }

  String _nextEventId() {
    _eventCounter++;
    return 'session-catalog-promo-event-$_eventCounter';
  }

  List<BusinessCatalogPromoCode> _ensureScopeList() {
    return _byScope.putIfAbsent(
      businessScopeId,
      () => buildDemoCatalogPromoCodes(businessScopeId: businessScopeId),
    );
  }

  Map<String, List<BusinessCatalogPromoCodeHistoryEvent>> _ensureScopeHistory() {
    return _historyByScope.putIfAbsent(businessScopeId, () => {});
  }

  List<BusinessCatalogPromoCodeUsageRecord> _ensureScopeUsage() {
    return _usageByScope.putIfAbsent(
      businessScopeId,
      () => buildDemoCatalogPromoUsageRecords(),
    );
  }
}

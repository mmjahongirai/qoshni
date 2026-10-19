import 'package:qoshni/features/business_platform/data/business_catalog_pricing_demo_seed.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_listing_kind.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_price.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_price_history_event.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_price_status.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_product.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_branch_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_catalog_pricing_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_catalog_product_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_catalog_product_variant_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_catalog_service_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_owner_profile_repository.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_pricing_validation.dart';

class InMemoryBusinessCatalogPricingRepository
    implements BusinessCatalogPricingRepository {
  InMemoryBusinessCatalogPricingRepository(
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

  final Map<String, List<BusinessCatalogPrice>> _byScope = {};
  final Map<String, Map<String, List<BusinessCatalogPriceHistoryEvent>>>
      _historyByScope = {};

  int _priceCounter = 0;
  int _eventCounter = 0;

  bool failNextSave = false;

  @override
  String get businessScopeId =>
      _ownerProfileRepository.ensureSessionProfile().sessionProfileId;

  @override
  List<BusinessCatalogPrice> listForCurrentScope({
    String? branchId,
    BusinessCatalogListingKind? listingKind,
    BusinessCatalogPriceStatus? status,
    bool includeArchived = false,
  }) {
    var list = List<BusinessCatalogPrice>.from(_ensureScopeList());
    if (!includeArchived) {
      list = list
          .where((p) => p.status != BusinessCatalogPriceStatus.archived)
          .toList();
    }
    if (branchId != null && branchId.trim().isNotEmpty) {
      final id = branchId.trim();
      list = list.where((p) => p.branchId == id).toList();
    }
    if (listingKind != null) {
      list = list.where((p) => p.listingKind == listingKind).toList();
    }
    if (status != null) {
      list = list.where((p) => p.status == status).toList();
    }
    return List.unmodifiable(list);
  }

  @override
  BusinessCatalogPrice? findById(String priceId) {
    try {
      return _ensureScopeList().firstWhere((p) => p.priceId == priceId);
    } on StateError {
      return null;
    }
  }

  @override
  List<BusinessCatalogPrice> findForListingTarget({
    required String branchId,
    required BusinessCatalogListingKind listingKind,
    required String listingId,
    String? variantId,
  }) {
    final branch = branchId.trim();
    final listing = listingId.trim();
    final variant = variantId?.trim();
    return listForCurrentScope(includeArchived: true).where((p) {
      if (p.branchId != branch ||
          p.listingKind != listingKind ||
          p.listingId != listing) {
        return false;
      }
      final pVariant = p.variantId?.trim();
      if (variant == null || variant.isEmpty) {
        return pVariant == null || pVariant.isEmpty;
      }
      return pVariant == variant;
    }).toList(growable: false);
  }

  @override
  List<BusinessCatalogPrice> activePricesOverlappingTarget({
    required String branchId,
    required BusinessCatalogListingKind listingKind,
    required String listingId,
    String? variantId,
    required DateTime effectiveFrom,
    DateTime? effectiveUntil,
    String? excludePriceId,
  }) {
    final variant = variantId?.trim();
    return _ensureScopeList().where((p) {
      if (p.status != BusinessCatalogPriceStatus.active) {
        return false;
      }
      if (excludePriceId != null && p.priceId == excludePriceId) {
        return false;
      }
      if (p.branchId != branchId.trim() ||
          p.listingKind != listingKind ||
          p.listingId != listingId.trim()) {
        return false;
      }
      final pVariant = p.variantId?.trim();
      if (variant == null || variant.isEmpty) {
        if (pVariant != null && pVariant.isNotEmpty) {
          return false;
        }
      } else if (pVariant != variant) {
        return false;
      }
      return catalogPriceIntervalsOverlap(
        fromA: p.effectiveFrom,
        untilA: p.effectiveUntil,
        fromB: effectiveFrom,
        untilB: effectiveUntil,
      );
    }).toList(growable: false);
  }

  @override
  BusinessCatalogPricingSaveResult createDraft(BusinessCatalogPriceInput input) {
    if (failNextSave) {
      failNextSave = false;
      return BusinessCatalogPricingSaveResult.failure;
    }
    final scopeResult = _validateScope(input);
    if (scopeResult != null) {
      return scopeResult;
    }
    final validation = catalogPriceInputValidationError(input);
    if (validation != null) {
      if (validation == 'invalid_amount') {
        return BusinessCatalogPricingSaveResult.invalidAmount;
      }
      if (validation == 'invalid_currency') {
        return BusinessCatalogPricingSaveResult.invalidCurrency;
      }
      if (validation == 'invalid_effective_range') {
        return BusinessCatalogPricingSaveResult.invalidEffectiveRange;
      }
      if (validation == 'variant_on_service') {
        return BusinessCatalogPricingSaveResult.invalidVariant;
      }
    }

    _priceCounter++;
    final now = DateTime.now().toUtc();
    final normalized = _normalizeInput(input);
    final price = BusinessCatalogPrice(
      priceId: 'session-catalog-price-$_priceCounter',
      businessScopeId: businessScopeId,
      branchId: normalized.branchId,
      listingKind: normalized.listingKind,
      listingId: normalized.listingId,
      variantId: normalized.variantId,
      amountSom: normalized.amountSom,
      currencyCode: normalized.currencyCode,
      status: BusinessCatalogPriceStatus.draft,
      effectiveFrom: normalized.effectiveFrom.toUtc(),
      effectiveUntil: normalized.effectiveUntil?.toUtc(),
      revision: 1,
      dataSource: BusinessCatalogProductDataSource.userSession,
      createdAt: now,
      updatedAt: now,
    );
    _ensureScopeList().add(price);
    _appendHistory(
      BusinessCatalogPriceHistoryEvent(
        eventId: _nextEventId(),
        priceId: price.priceId,
        action: BusinessCatalogPriceHistoryAction.created,
        newAmountSom: price.amountSom,
        newRevision: price.revision,
        recordedAt: now,
      ),
    );
    return BusinessCatalogPricingSaveResult.success;
  }

  @override
  BusinessCatalogPricingSaveResult updateDraft({
    required String priceId,
    required BusinessCatalogPriceInput input,
  }) {
    if (failNextSave) {
      failNextSave = false;
      return BusinessCatalogPricingSaveResult.failure;
    }
    final list = _ensureScopeList();
    final index = list.indexWhere((p) => p.priceId == priceId);
    if (index < 0) {
      return BusinessCatalogPricingSaveResult.notFound;
    }
    final existing = list[index];
    if (existing.status != BusinessCatalogPriceStatus.draft) {
      if (existing.status == BusinessCatalogPriceStatus.active) {
        return BusinessCatalogPricingSaveResult.activeImmutable;
      }
      return BusinessCatalogPricingSaveResult.notDraft;
    }
    final scopeResult = _validateScope(input);
    if (scopeResult != null) {
      return scopeResult;
    }
    final validation = catalogPriceInputValidationError(input);
    if (validation != null) {
      if (validation == 'invalid_amount') {
        return BusinessCatalogPricingSaveResult.invalidAmount;
      }
      if (validation == 'invalid_currency') {
        return BusinessCatalogPricingSaveResult.invalidCurrency;
      }
      if (validation == 'invalid_effective_range') {
        return BusinessCatalogPricingSaveResult.invalidEffectiveRange;
      }
      if (validation == 'variant_on_service') {
        return BusinessCatalogPricingSaveResult.invalidVariant;
      }
    }

    final normalized = _normalizeInput(input);
    final now = DateTime.now().toUtc();
    final beforeAmount = existing.amountSom;
    list[index] = existing.copyWith(
      branchId: normalized.branchId,
      listingKind: normalized.listingKind,
      listingId: normalized.listingId,
      variantId: normalized.variantId,
      amountSom: normalized.amountSom,
      currencyCode: normalized.currencyCode,
      effectiveFrom: normalized.effectiveFrom.toUtc(),
      effectiveUntil: normalized.effectiveUntil?.toUtc(),
      clearEffectiveUntil: normalized.effectiveUntil == null,
      updatedAt: now,
    );
    _appendHistory(
      BusinessCatalogPriceHistoryEvent(
        eventId: _nextEventId(),
        priceId: priceId,
        action: BusinessCatalogPriceHistoryAction.draftUpdated,
        previousAmountSom: beforeAmount,
        newAmountSom: normalized.amountSom,
        previousRevision: existing.revision,
        newRevision: existing.revision,
        recordedAt: now,
      ),
    );
    return BusinessCatalogPricingSaveResult.success;
  }

  @override
  BusinessCatalogPricingSaveResult createRevisionFromPrice({
    required String sourcePriceId,
    required BusinessCatalogPriceInput input,
  }) {
    if (failNextSave) {
      failNextSave = false;
      return BusinessCatalogPricingSaveResult.failure;
    }
    final source = findById(sourcePriceId);
    if (source == null) {
      return BusinessCatalogPricingSaveResult.notFound;
    }
    if (source.status != BusinessCatalogPriceStatus.active) {
      return BusinessCatalogPricingSaveResult.notDraft;
    }
    final scopeResult = _validateScope(input);
    if (scopeResult != null) {
      return scopeResult;
    }
    final validation = catalogPriceInputValidationError(input);
    if (validation != null) {
      if (validation == 'invalid_amount') {
        return BusinessCatalogPricingSaveResult.invalidAmount;
      }
      if (validation == 'invalid_currency') {
        return BusinessCatalogPricingSaveResult.invalidCurrency;
      }
      if (validation == 'invalid_effective_range') {
        return BusinessCatalogPricingSaveResult.invalidEffectiveRange;
      }
      if (validation == 'variant_on_service') {
        return BusinessCatalogPricingSaveResult.invalidVariant;
      }
    }

    _priceCounter++;
    final now = DateTime.now().toUtc();
    final normalized = _normalizeInput(input);
    final nextRevision = source.revision + 1;
    final price = BusinessCatalogPrice(
      priceId: 'session-catalog-price-$_priceCounter',
      businessScopeId: businessScopeId,
      branchId: normalized.branchId,
      listingKind: normalized.listingKind,
      listingId: normalized.listingId,
      variantId: normalized.variantId,
      amountSom: normalized.amountSom,
      currencyCode: normalized.currencyCode,
      status: BusinessCatalogPriceStatus.draft,
      effectiveFrom: normalized.effectiveFrom.toUtc(),
      effectiveUntil: normalized.effectiveUntil?.toUtc(),
      revision: nextRevision,
      dataSource: BusinessCatalogProductDataSource.userSession,
      createdAt: now,
      updatedAt: now,
    );
    _ensureScopeList().add(price);
    _appendHistory(
      BusinessCatalogPriceHistoryEvent(
        eventId: _nextEventId(),
        priceId: price.priceId,
        action: BusinessCatalogPriceHistoryAction.revisionCreated,
        previousRevision: source.revision,
        newRevision: nextRevision,
        newAmountSom: price.amountSom,
        recordedAt: now,
        reason: 'revision_from_${source.priceId}',
      ),
    );
    return BusinessCatalogPricingSaveResult.success;
  }

  @override
  BusinessCatalogPricingStatusChangeResult activatePrice(String priceId) {
    if (failNextSave) {
      failNextSave = false;
      return BusinessCatalogPricingStatusChangeResult.failure;
    }
    final list = _ensureScopeList();
    final index = list.indexWhere((p) => p.priceId == priceId);
    if (index < 0) {
      return BusinessCatalogPricingStatusChangeResult.notFound;
    }
    final existing = list[index];
    if (existing.status != BusinessCatalogPriceStatus.draft) {
      return BusinessCatalogPricingStatusChangeResult.notDraft;
    }
    if (!catalogPriceEffectiveRangeValid(
      effectiveFrom: existing.effectiveFrom,
      effectiveUntil: existing.effectiveUntil,
    )) {
      return BusinessCatalogPricingStatusChangeResult.invalidEffectiveRange;
    }
    final overlaps = activePricesOverlappingTarget(
      branchId: existing.branchId,
      listingKind: existing.listingKind,
      listingId: existing.listingId,
      variantId: existing.variantId,
      effectiveFrom: existing.effectiveFrom,
      effectiveUntil: existing.effectiveUntil,
      excludePriceId: existing.priceId,
    );
    if (overlaps.isNotEmpty) {
      return BusinessCatalogPricingStatusChangeResult.activeIntervalOverlap;
    }

    final now = DateTime.now().toUtc();
    list[index] = existing.copyWith(
      status: BusinessCatalogPriceStatus.active,
      updatedAt: now,
    );
    _appendHistory(
      BusinessCatalogPriceHistoryEvent(
        eventId: _nextEventId(),
        priceId: priceId,
        action: BusinessCatalogPriceHistoryAction.activated,
        previousAmountSom: existing.amountSom,
        newAmountSom: existing.amountSom,
        previousRevision: existing.revision,
        newRevision: existing.revision,
        recordedAt: now,
      ),
    );
    return BusinessCatalogPricingStatusChangeResult.success;
  }

  @override
  BusinessCatalogPricingStatusChangeResult archivePrice(String priceId) {
    final list = _ensureScopeList();
    final index = list.indexWhere((p) => p.priceId == priceId);
    if (index < 0) {
      return BusinessCatalogPricingStatusChangeResult.notFound;
    }
    final existing = list[index];
    if (existing.status == BusinessCatalogPriceStatus.archived) {
      return BusinessCatalogPricingStatusChangeResult.success;
    }

    final now = DateTime.now().toUtc();
    list[index] = existing.copyWith(
      status: BusinessCatalogPriceStatus.archived,
      updatedAt: now,
    );
    _appendHistory(
      BusinessCatalogPriceHistoryEvent(
        eventId: _nextEventId(),
        priceId: priceId,
        action: BusinessCatalogPriceHistoryAction.archived,
        previousAmountSom: existing.amountSom,
        newAmountSom: existing.amountSom,
        previousRevision: existing.revision,
        newRevision: existing.revision,
        recordedAt: now,
      ),
    );
    return BusinessCatalogPricingStatusChangeResult.success;
  }

  @override
  List<BusinessCatalogPriceHistoryEvent> priceHistory(String priceId) {
    if (findById(priceId) == null) {
      return const [];
    }
    final scopeHistory = _ensureScopeHistory();
    return List.unmodifiable(scopeHistory[priceId] ?? const []);
  }

  BusinessCatalogPricingSaveResult? _validateScope(
    BusinessCatalogPriceInput input,
  ) {
    final branch = _branchRepository.findById(input.branchId.trim());
    if (branch == null || branch.businessScopeId != businessScopeId) {
      return BusinessCatalogPricingSaveResult.invalidBranch;
    }
    switch (input.listingKind) {
      case BusinessCatalogListingKind.product:
        final product = _productRepository.findById(input.listingId.trim());
        if (product == null || product.businessScopeId != businessScopeId) {
          return BusinessCatalogPricingSaveResult.invalidListing;
        }
        final variantId = input.variantId?.trim();
        if (variantId != null && variantId.isNotEmpty) {
          final variant = _variantRepository.findById(variantId);
          if (variant == null ||
              variant.businessScopeId != businessScopeId ||
              variant.productId != product.productId) {
            return BusinessCatalogPricingSaveResult.invalidVariant;
          }
        }
      case BusinessCatalogListingKind.service:
        final service = _serviceRepository.findById(input.listingId.trim());
        if (service == null || service.businessScopeId != businessScopeId) {
          return BusinessCatalogPricingSaveResult.invalidListing;
        }
    }
    return null;
  }

  BusinessCatalogPriceInput _normalizeInput(BusinessCatalogPriceInput input) {
    final variant = input.variantId?.trim();
    return BusinessCatalogPriceInput(
      listingKind: input.listingKind,
      listingId: input.listingId.trim(),
      variantId: variant != null && variant.isEmpty ? null : variant,
      branchId: input.branchId.trim(),
      amountSom: input.amountSom,
      currencyCode: input.currencyCode.trim().toUpperCase(),
      effectiveFrom: input.effectiveFrom.toUtc(),
      effectiveUntil: input.effectiveUntil?.toUtc(),
    );
  }

  void _appendHistory(BusinessCatalogPriceHistoryEvent event) {
    final scopeHistory = _ensureScopeHistory();
    scopeHistory.putIfAbsent(event.priceId, () => []).add(event);
  }

  String _nextEventId() {
    _eventCounter++;
    return 'session-catalog-price-event-$_eventCounter';
  }

  List<BusinessCatalogPrice> _ensureScopeList() {
    return _byScope.putIfAbsent(
      businessScopeId,
      () => buildDemoCatalogPrices(businessScopeId: businessScopeId),
    );
  }

  Map<String, List<BusinessCatalogPriceHistoryEvent>> _ensureScopeHistory() {
    return _historyByScope.putIfAbsent(businessScopeId, () => {});
  }
}

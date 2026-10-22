import 'package:qoshni/features/business_platform/data/business_fulfillment_demo_seed.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_price_status.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_product.dart';
import 'package:qoshni/features/business_platform/domain/business_fulfillment_configuration.dart';
import 'package:qoshni/features/business_platform/domain/business_fulfillment_history_event.dart';
import 'package:qoshni/features/business_platform/domain/business_fulfillment_target_scope.dart';
import 'package:qoshni/features/business_platform/domain/business_fulfillment_type.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_branch_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_catalog_product_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_catalog_service_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_fulfillment_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_owner_profile_repository.dart';
import 'package:qoshni/features/business_platform/presentation/business_fulfillment_validation.dart';

class InMemoryBusinessFulfillmentRepository
    implements BusinessFulfillmentRepository {
  InMemoryBusinessFulfillmentRepository(
    this._ownerProfileRepository,
    this._branchRepository,
    this._productRepository,
    this._serviceRepository,
  );

  final BusinessOwnerProfileRepository _ownerProfileRepository;
  final BusinessBranchRepository _branchRepository;
  final BusinessCatalogProductRepository _productRepository;
  final BusinessCatalogServiceRepository _serviceRepository;

  final Map<String, List<BusinessFulfillmentConfiguration>> _byScope = {};
  final Map<String, Map<String, List<BusinessFulfillmentHistoryEvent>>>
      _historyByScope = {};

  int _configCounter = 0;
  int _eventCounter = 0;

  bool failNextSave = false;

  @override
  String get businessScopeId =>
      _ownerProfileRepository.ensureSessionProfile().sessionProfileId;

  @override
  List<BusinessFulfillmentConfiguration> listForCurrentScope({
    String? branchId,
    BusinessFulfillmentType? fulfillmentType,
    BusinessCatalogPriceStatus? status,
    bool includeArchived = false,
  }) {
    var list = List<BusinessFulfillmentConfiguration>.from(_ensureScopeList());
    if (!includeArchived) {
      list = list
          .where((c) => c.status != BusinessCatalogPriceStatus.archived)
          .toList();
    }
    if (branchId != null && branchId.trim().isNotEmpty) {
      final id = branchId.trim();
      list = list.where((c) => c.branchId == id).toList();
    }
    if (fulfillmentType != null) {
      list = list
          .where((c) => c.supportedFulfillmentTypes.contains(fulfillmentType))
          .toList();
    }
    if (status != null) {
      list = list.where((c) => c.status == status).toList();
    }
    return List.unmodifiable(list);
  }

  @override
  BusinessFulfillmentConfiguration? findById(String configurationId) {
    try {
      return _ensureScopeList()
          .firstWhere((c) => c.configurationId == configurationId);
    } on StateError {
      return null;
    }
  }

  @override
  BusinessFulfillmentConfiguration? activeConfigurationForTarget({
    required String branchId,
    required BusinessFulfillmentTargetScope targetScope,
    String? listingId,
    String? excludeConfigurationId,
  }) {
    final key = catalogFulfillmentTargetKey(
      branchId: branchId,
      targetScope: targetScope,
      listingId: listingId,
    );
    for (final c in _ensureScopeList()) {
      if (c.status != BusinessCatalogPriceStatus.active) {
        continue;
      }
      if (excludeConfigurationId != null &&
          c.configurationId == excludeConfigurationId) {
        continue;
      }
      final cKey = catalogFulfillmentTargetKey(
        branchId: c.branchId,
        targetScope: c.targetScope,
        listingId: c.listingId,
      );
      if (cKey == key) {
        return c;
      }
    }
    return null;
  }

  @override
  BusinessFulfillmentSaveResult createDraft(
    BusinessFulfillmentConfigurationInput input,
  ) {
    if (failNextSave) {
      failNextSave = false;
      return BusinessFulfillmentSaveResult.failure;
    }
    return _createDraftInternal(input);
  }

  @override
  BusinessFulfillmentSaveResult updateDraft({
    required String configurationId,
    required BusinessFulfillmentConfigurationInput input,
  }) {
    if (failNextSave) {
      failNextSave = false;
      return BusinessFulfillmentSaveResult.failure;
    }
    final list = _ensureScopeList();
    final index =
        list.indexWhere((c) => c.configurationId == configurationId);
    if (index < 0) {
      return BusinessFulfillmentSaveResult.notFound;
    }
    final existing = list[index];
    if (existing.status != BusinessCatalogPriceStatus.draft) {
      if (existing.status == BusinessCatalogPriceStatus.active) {
        return BusinessFulfillmentSaveResult.activeImmutable;
      }
      return BusinessFulfillmentSaveResult.notDraft;
    }
    final validated = _validateInput(input);
    if (validated != null) {
      return validated;
    }
    final normalized = _normalizeInput(input);
    final now = DateTime.now().toUtc();
    list[index] = BusinessFulfillmentConfiguration(
      configurationId: existing.configurationId,
      businessScopeId: existing.businessScopeId,
      branchId: normalized.branchId,
      targetScope: normalized.targetScope,
      listingId: normalized.listingId,
      supportedFulfillmentTypes: normalized.types,
      status: BusinessCatalogPriceStatus.draft,
      revision: existing.revision,
      dataSource: existing.dataSource,
      createdAt: existing.createdAt,
      updatedAt: now,
    );
    _appendHistory(
      BusinessFulfillmentHistoryEvent(
        eventId: _nextEventId(),
        configurationId: configurationId,
        action: BusinessFulfillmentHistoryAction.draftUpdated,
        previousRevision: existing.revision,
        newRevision: existing.revision,
        recordedAt: now,
      ),
    );
    return BusinessFulfillmentSaveResult.success;
  }

  @override
  BusinessFulfillmentStatusChangeResult activateConfiguration(
    String configurationId,
  ) {
    if (failNextSave) {
      failNextSave = false;
      return BusinessFulfillmentStatusChangeResult.failure;
    }
    final list = _ensureScopeList();
    final index =
        list.indexWhere((c) => c.configurationId == configurationId);
    if (index < 0) {
      return BusinessFulfillmentStatusChangeResult.notFound;
    }
    final existing = list[index];
    if (existing.status != BusinessCatalogPriceStatus.draft) {
      return BusinessFulfillmentStatusChangeResult.notDraft;
    }
    final conflict = activeConfigurationForTarget(
      branchId: existing.branchId,
      targetScope: existing.targetScope,
      listingId: existing.listingId,
      excludeConfigurationId: existing.configurationId,
    );
    if (conflict != null) {
      return BusinessFulfillmentStatusChangeResult.activeTargetConflict;
    }
    final now = DateTime.now().toUtc();
    list[index] = existing.copyWith(
      status: BusinessCatalogPriceStatus.active,
      updatedAt: now,
    );
    _appendHistory(
      BusinessFulfillmentHistoryEvent(
        eventId: _nextEventId(),
        configurationId: configurationId,
        action: BusinessFulfillmentHistoryAction.activated,
        previousRevision: existing.revision,
        newRevision: existing.revision,
        recordedAt: now,
      ),
    );
    return BusinessFulfillmentStatusChangeResult.success;
  }

  @override
  BusinessFulfillmentStatusChangeResult archiveConfiguration(
    String configurationId,
  ) {
    final list = _ensureScopeList();
    final index =
        list.indexWhere((c) => c.configurationId == configurationId);
    if (index < 0) {
      return BusinessFulfillmentStatusChangeResult.notFound;
    }
    final existing = list[index];
    if (existing.status == BusinessCatalogPriceStatus.archived) {
      return BusinessFulfillmentStatusChangeResult.success;
    }
    final now = DateTime.now().toUtc();
    list[index] = existing.copyWith(
      status: BusinessCatalogPriceStatus.archived,
      updatedAt: now,
    );
    _appendHistory(
      BusinessFulfillmentHistoryEvent(
        eventId: _nextEventId(),
        configurationId: configurationId,
        action: BusinessFulfillmentHistoryAction.archived,
        previousRevision: existing.revision,
        newRevision: existing.revision,
        recordedAt: now,
      ),
    );
    return BusinessFulfillmentStatusChangeResult.success;
  }

  @override
  List<BusinessFulfillmentHistoryEvent> configurationHistory(
    String configurationId,
  ) {
    if (findById(configurationId) == null) {
      return const [];
    }
    return List.unmodifiable(_ensureScopeHistory()[configurationId] ?? const []);
  }

  BusinessFulfillmentSaveResult _createDraftInternal(
    BusinessFulfillmentConfigurationInput input,
  ) {
    final validated = _validateInput(input);
    if (validated != null) {
      return validated;
    }
    _configCounter++;
    final now = DateTime.now().toUtc();
    final normalized = _normalizeInput(input);
    final config = BusinessFulfillmentConfiguration(
      configurationId: 'session-fulfillment-$_configCounter',
      businessScopeId: businessScopeId,
      branchId: normalized.branchId,
      targetScope: normalized.targetScope,
      listingId: normalized.listingId,
      supportedFulfillmentTypes: normalized.types,
      status: BusinessCatalogPriceStatus.draft,
      revision: 1,
      dataSource: BusinessCatalogProductDataSource.userSession,
      createdAt: now,
      updatedAt: now,
    );
    _ensureScopeList().add(config);
    _appendHistory(
      BusinessFulfillmentHistoryEvent(
        eventId: _nextEventId(),
        configurationId: config.configurationId,
        action: BusinessFulfillmentHistoryAction.created,
        newRevision: 1,
        recordedAt: now,
      ),
    );
    return BusinessFulfillmentSaveResult.success;
  }

  BusinessFulfillmentSaveResult? _validateInput(
    BusinessFulfillmentConfigurationInput input,
  ) {
    final validation = catalogFulfillmentInputValidationError(input);
    if (validation != null) {
      switch (validation) {
        case 'empty_types':
          return BusinessFulfillmentSaveResult.emptyFulfillmentTypes;
        case 'duplicate_type':
          return BusinessFulfillmentSaveResult.duplicateFulfillmentType;
        case 'invalid_target':
          return BusinessFulfillmentSaveResult.invalidTarget;
      }
    }
    final branch = _branchRepository.findById(input.branchId.trim());
    if (branch == null || branch.businessScopeId != businessScopeId) {
      return BusinessFulfillmentSaveResult.invalidBranch;
    }
    switch (input.targetScope) {
      case BusinessFulfillmentTargetScope.businessWide:
        break;
      case BusinessFulfillmentTargetScope.product:
        final product =
            _productRepository.findById(input.listingId!.trim());
        if (product == null || product.businessScopeId != businessScopeId) {
          return BusinessFulfillmentSaveResult.invalidTarget;
        }
      case BusinessFulfillmentTargetScope.service:
        final service =
            _serviceRepository.findById(input.listingId!.trim());
        if (service == null || service.businessScopeId != businessScopeId) {
          return BusinessFulfillmentSaveResult.invalidTarget;
        }
    }
    return null;
  }

  ({
    String branchId,
    BusinessFulfillmentTargetScope targetScope,
    String? listingId,
    List<BusinessFulfillmentType> types,
  }) _normalizeInput(BusinessFulfillmentConfigurationInput input) {
    final types = catalogFulfillmentTypesNormalize(input.supportedFulfillmentTypes);
    String? listing;
    switch (input.targetScope) {
      case BusinessFulfillmentTargetScope.businessWide:
        listing = null;
      case BusinessFulfillmentTargetScope.product:
      case BusinessFulfillmentTargetScope.service:
        listing = input.listingId?.trim();
    }
    return (
      branchId: input.branchId.trim(),
      targetScope: input.targetScope,
      listingId: listing,
      types: types,
    );
  }

  void _appendHistory(BusinessFulfillmentHistoryEvent event) {
    _ensureScopeHistory().putIfAbsent(event.configurationId, () => []).add(event);
  }

  String _nextEventId() {
    _eventCounter++;
    return 'session-fulfillment-event-$_eventCounter';
  }

  List<BusinessFulfillmentConfiguration> _ensureScopeList() {
    return _byScope.putIfAbsent(
      businessScopeId,
      () => buildDemoFulfillmentConfigurations(businessScopeId: businessScopeId),
    );
  }

  Map<String, List<BusinessFulfillmentHistoryEvent>> _ensureScopeHistory() {
    return _historyByScope.putIfAbsent(businessScopeId, () => {});
  }
}

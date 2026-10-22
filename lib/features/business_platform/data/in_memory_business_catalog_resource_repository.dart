import 'package:qoshni/features/business_platform/data/business_catalog_resource_demo_seed.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_resource.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_resource_capacity_event.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_resource_status.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_resource_type.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_branch_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_catalog_resource_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_catalog_service_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_owner_profile_repository.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_resource_validation.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_product.dart';

class InMemoryBusinessCatalogResourceRepository
    implements BusinessCatalogResourceRepository {
  InMemoryBusinessCatalogResourceRepository(
    this._ownerProfileRepository,
    this._branchRepository,
    this._serviceRepository,
  );

  final BusinessOwnerProfileRepository _ownerProfileRepository;
  final BusinessBranchRepository _branchRepository;
  final BusinessCatalogServiceRepository _serviceRepository;

  final Map<String, List<BusinessCatalogResource>> _byScope = {};
  final Map<String, Map<String, List<BusinessCatalogResourceCapacityEvent>>>
      _historyByScope = {};

  int _resourceCounter = 0;
  int _eventCounter = 0;

  bool failNextSave = false;

  @override
  String get businessScopeId =>
      _ownerProfileRepository.ensureSessionProfile().sessionProfileId;

  @override
  List<BusinessCatalogResource> listForCurrentScope({
    String? branchId,
    BusinessCatalogResourceType? type,
    BusinessCatalogResourceStatus? status,
    bool includeArchived = false,
  }) {
    var list = List<BusinessCatalogResource>.from(_ensureScopeList());
    if (!includeArchived) {
      list = list
          .where((r) => r.status != BusinessCatalogResourceStatus.archived)
          .toList();
    }
    if (branchId != null && branchId.trim().isNotEmpty) {
      final id = branchId.trim();
      list = list.where((r) => r.branchId == id).toList();
    }
    if (type != null) {
      list = list.where((r) => r.type == type).toList();
    }
    if (status != null) {
      list = list.where((r) => r.status == status).toList();
    }
    return List.unmodifiable(list);
  }

  @override
  BusinessCatalogResource? findById(String resourceId) {
    try {
      return _ensureScopeList().firstWhere((r) => r.resourceId == resourceId);
    } on StateError {
      return null;
    }
  }

  @override
  BusinessCatalogResourceSaveResult createResource(
    BusinessCatalogResourceInput input,
  ) {
    if (failNextSave) {
      failNextSave = false;
      return BusinessCatalogResourceSaveResult.failure;
    }
    final validation = catalogResourceInputValidationError(input);
    if (validation != null) {
      return BusinessCatalogResourceSaveResult.invalidInput;
    }
    if (!_branchInScope(input.branchId)) {
      return BusinessCatalogResourceSaveResult.invalidBranch;
    }
    if (!_serviceInScope(input.serviceId)) {
      return BusinessCatalogResourceSaveResult.invalidService;
    }
    if (input.status == BusinessCatalogResourceStatus.archived) {
      return BusinessCatalogResourceSaveResult.invalidInput;
    }

    _resourceCounter++;
    final now = DateTime.now();
    _ensureScopeList().add(
      BusinessCatalogResource(
        resourceId: 'session-catalog-resource-$_resourceCounter',
        businessScopeId: businessScopeId,
        branchId: input.branchId.trim(),
        dataSource: BusinessCatalogProductDataSource.userSession,
        type: input.type,
        capacityUnit: input.capacityUnit.trim(),
        localized: input.localized.trimmed(),
        totalCapacity: input.totalCapacity,
        allocatedCapacity: 0,
        status: input.status,
        serviceId: _trimOptional(input.serviceId),
        productId: _trimOptional(input.productId),
        createdAt: now,
        updatedAt: now,
      ),
    );
    return BusinessCatalogResourceSaveResult.success;
  }

  @override
  BusinessCatalogResourceSaveResult updateResource(
    String resourceId,
    BusinessCatalogResourceInput input,
  ) {
    if (failNextSave) {
      failNextSave = false;
      return BusinessCatalogResourceSaveResult.failure;
    }
    final list = _ensureScopeList();
    final index = list.indexWhere((r) => r.resourceId == resourceId);
    if (index < 0) {
      return BusinessCatalogResourceSaveResult.notFound;
    }
    final existing = list[index];
    if (existing.status == BusinessCatalogResourceStatus.archived) {
      return BusinessCatalogResourceSaveResult.invalidInput;
    }
    final validation = catalogResourceInputValidationError(input);
    if (validation != null) {
      return BusinessCatalogResourceSaveResult.invalidInput;
    }
    if (!_branchInScope(input.branchId)) {
      return BusinessCatalogResourceSaveResult.invalidBranch;
    }
    if (!_serviceInScope(input.serviceId)) {
      return BusinessCatalogResourceSaveResult.invalidService;
    }
    if (input.totalCapacity < existing.allocatedCapacity) {
      return BusinessCatalogResourceSaveResult.invalidCapacity;
    }
    if (input.status == BusinessCatalogResourceStatus.archived) {
      return BusinessCatalogResourceSaveResult.invalidInput;
    }

    list[index] = BusinessCatalogResource(
      resourceId: existing.resourceId,
      businessScopeId: existing.businessScopeId,
      branchId: input.branchId.trim(),
      dataSource: existing.dataSource,
      type: input.type,
      capacityUnit: input.capacityUnit.trim(),
      localized: input.localized.trimmed(),
      totalCapacity: input.totalCapacity,
      allocatedCapacity: existing.allocatedCapacity,
      status: input.status,
      serviceId: _trimOptional(input.serviceId),
      productId: _trimOptional(input.productId),
      createdAt: existing.createdAt,
      updatedAt: DateTime.now(),
    );
    return BusinessCatalogResourceSaveResult.success;
  }

  @override
  BusinessCatalogResourceSaveResult setStatus({
    required String resourceId,
    required BusinessCatalogResourceStatus status,
  }) {
    final list = _ensureScopeList();
    final index = list.indexWhere((r) => r.resourceId == resourceId);
    if (index < 0) {
      return BusinessCatalogResourceSaveResult.notFound;
    }
    list[index] = list[index].copyWith(
      status: status,
      updatedAt: DateTime.now(),
    );
    return BusinessCatalogResourceSaveResult.success;
  }

  @override
  BusinessCatalogResourceCapacityChangeResult changeTotalCapacity({
    required String resourceId,
    required BusinessCatalogResourceCapacityChangeInput input,
  }) {
    if (failNextSave) {
      failNextSave = false;
      return BusinessCatalogResourceCapacityChangeResult.failure;
    }
    final resource = findById(resourceId);
    if (resource == null) {
      return BusinessCatalogResourceCapacityChangeResult.notFound;
    }
    if (resource.status == BusinessCatalogResourceStatus.archived) {
      return BusinessCatalogResourceCapacityChangeResult.invalidCapacity;
    }
    final validation = catalogResourceCapacityChangeValidationError(
      resource,
      input,
    );
    if (validation == 'reason_required') {
      return BusinessCatalogResourceCapacityChangeResult.invalidReason;
    }
    if (validation == 'no_change') {
      return BusinessCatalogResourceCapacityChangeResult.noChange;
    }
    if (validation != null) {
      return BusinessCatalogResourceCapacityChangeResult.invalidCapacity;
    }

    final list = _ensureScopeList();
    final index = list.indexWhere((r) => r.resourceId == resourceId);
    final before = list[index].totalCapacity;
    list[index] = list[index].copyWith(
      totalCapacity: input.newTotalCapacity,
      updatedAt: DateTime.now(),
    );
    _appendHistory(
      BusinessCatalogResourceCapacityEvent(
        eventId: _nextEventId(),
        resourceId: resourceId,
        totalBefore: before,
        totalAfter: input.newTotalCapacity,
        reason: input.reason.trim(),
        recordedAt: DateTime.now(),
      ),
    );
    return BusinessCatalogResourceCapacityChangeResult.success;
  }

  @override
  List<BusinessCatalogResourceCapacityEvent> capacityHistory(String resourceId) {
    if (findById(resourceId) == null) {
      return const [];
    }
    final scopeHistory = _ensureScopeHistory();
    return List.unmodifiable(scopeHistory[resourceId] ?? const []);
  }

  bool _branchInScope(String branchId) {
    final branch = _branchRepository.findById(branchId.trim());
    return branch != null && branch.businessScopeId == businessScopeId;
  }

  bool _serviceInScope(String? serviceId) {
    final id = _trimOptional(serviceId);
    if (id == null) {
      return true;
    }
    final service = _serviceRepository.findById(id);
    return service != null && service.businessScopeId == businessScopeId;
  }

  String? _trimOptional(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }

  void _appendHistory(BusinessCatalogResourceCapacityEvent event) {
    final scopeHistory = _ensureScopeHistory();
    scopeHistory.putIfAbsent(event.resourceId, () => []).add(event);
  }

  String _nextEventId() {
    _eventCounter++;
    return 'session-catalog-resource-event-$_eventCounter';
  }

  List<BusinessCatalogResource> _ensureScopeList() {
    return _byScope.putIfAbsent(
      businessScopeId,
      () => buildDemoCatalogResources(businessScopeId: businessScopeId),
    );
  }

  Map<String, List<BusinessCatalogResourceCapacityEvent>> _ensureScopeHistory() {
    return _historyByScope.putIfAbsent(businessScopeId, () => {});
  }
}

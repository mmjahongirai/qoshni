import 'package:qoshni/features/business_platform/data/business_catalog_service_demo_seed.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_service.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_catalog_category_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_catalog_service_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_owner_profile_repository.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_listing_validation.dart';

class InMemoryBusinessCatalogServiceRepository
    implements BusinessCatalogServiceRepository {
  InMemoryBusinessCatalogServiceRepository(
    this._ownerProfileRepository,
    this._categoryRepository,
  );

  final BusinessOwnerProfileRepository _ownerProfileRepository;
  final BusinessCatalogCategoryRepository _categoryRepository;

  final Map<String, List<BusinessCatalogService>> _servicesByScope = {};
  int _userServiceCounter = 0;

  bool failNextSave = false;

  @override
  String get businessScopeId =>
      _ownerProfileRepository.ensureSessionProfile().sessionProfileId;

  @override
  List<BusinessCatalogService> listForCurrentScope() {
    return List.unmodifiable(_ensureScopeList());
  }

  @override
  BusinessCatalogService? findById(String serviceId) {
    try {
      return _ensureScopeList().firstWhere((s) => s.serviceId == serviceId);
    } on StateError {
      return null;
    }
  }

  @override
  int countReferencingCategory(String categoryId) {
    return _ensureScopeList().where((s) => s.categoryId == categoryId).length;
  }

  @override
  BusinessCatalogServiceSaveResult createService(
    BusinessCatalogServiceInput input,
  ) {
    if (failNextSave) {
      failNextSave = false;
      return BusinessCatalogServiceSaveResult.failure;
    }
    if (!catalogListingHasName(input.localized)) {
      return BusinessCatalogServiceSaveResult.failure;
    }
    if (input.durationMinutes != null && input.durationMinutes! <= 0) {
      return BusinessCatalogServiceSaveResult.invalidDuration;
    }
    if (!_categoryInScope(input.categoryId)) {
      return BusinessCatalogServiceSaveResult.invalidCategory;
    }
    final now = DateTime.now();
    _userServiceCounter++;
    _ensureScopeList().add(
      BusinessCatalogService(
        serviceId: 'session-catalog-service-$_userServiceCounter',
        businessScopeId: businessScopeId,
        categoryId: input.categoryId.trim(),
        dataSource: BusinessCatalogServiceDataSource.userSession,
        status: input.status,
        localized: input.localized.trimmed(),
        durationMinutes: input.durationMinutes,
        createdAt: now,
        updatedAt: now,
      ),
    );
    return BusinessCatalogServiceSaveResult.success;
  }

  @override
  BusinessCatalogServiceSaveResult updateService(
    String serviceId,
    BusinessCatalogServiceInput input,
  ) {
    if (failNextSave) {
      failNextSave = false;
      return BusinessCatalogServiceSaveResult.failure;
    }
    final list = _ensureScopeList();
    final index = list.indexWhere((s) => s.serviceId == serviceId);
    if (index < 0) {
      return BusinessCatalogServiceSaveResult.notFound;
    }
    if (!catalogListingHasName(input.localized)) {
      return BusinessCatalogServiceSaveResult.failure;
    }
    if (input.durationMinutes != null && input.durationMinutes! <= 0) {
      return BusinessCatalogServiceSaveResult.invalidDuration;
    }
    if (!_categoryInScope(input.categoryId)) {
      return BusinessCatalogServiceSaveResult.invalidCategory;
    }
    list[index] = list[index].copyWith(
      categoryId: input.categoryId.trim(),
      status: input.status,
      localized: input.localized.trimmed(),
      durationMinutes: input.durationMinutes,
      clearDuration: input.durationMinutes == null,
      updatedAt: DateTime.now(),
    );
    return BusinessCatalogServiceSaveResult.success;
  }

  bool _categoryInScope(String categoryId) {
    final category = _categoryRepository.findById(categoryId.trim());
    return category != null &&
        category.businessScopeId == businessScopeId;
  }

  List<BusinessCatalogService> _ensureScopeList() {
    final scope = businessScopeId;
    return _servicesByScope.putIfAbsent(
      scope,
      () => buildDemoCatalogServices(businessScopeId: scope),
    );
  }
}

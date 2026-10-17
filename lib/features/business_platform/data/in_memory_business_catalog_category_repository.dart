import 'package:qoshni/features/business_platform/data/business_catalog_category_demo_seed.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_category.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_catalog_category_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_catalog_product_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_catalog_service_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_owner_profile_repository.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_category_validation.dart';

class InMemoryBusinessCatalogCategoryRepository
    implements BusinessCatalogCategoryRepository {
  InMemoryBusinessCatalogCategoryRepository(this._ownerProfileRepository);

  final BusinessOwnerProfileRepository _ownerProfileRepository;
  BusinessCatalogProductRepository? _productRepository;
  BusinessCatalogServiceRepository? _serviceRepository;

  void attachListingRepositories({
    required BusinessCatalogProductRepository productRepository,
    required BusinessCatalogServiceRepository serviceRepository,
  }) {
    _productRepository = productRepository;
    _serviceRepository = serviceRepository;
  }

  final Map<String, List<BusinessCatalogCategory>> _categoriesByScope = {};
  int _userCategoryCounter = 0;

  bool failNextSave = false;

  @override
  String get businessScopeId =>
      _ownerProfileRepository.ensureSessionProfile().sessionProfileId;

  @override
  List<BusinessCatalogCategory> listForCurrentScope() {
    return List.unmodifiable(_ensureScopeList());
  }

  @override
  BusinessCatalogCategory? findById(String categoryId) {
    try {
      return _ensureScopeList().firstWhere((c) => c.categoryId == categoryId);
    } on StateError {
      return null;
    }
  }

  @override
  BusinessCatalogCategorySaveResult createCategory(
    BusinessCatalogCategoryInput input,
  ) {
    if (failNextSave) {
      failNextSave = false;
      return BusinessCatalogCategorySaveResult.failure;
    }
    final list = _ensureScopeList();
    final issue = validateCategoryInput(input: input, existing: list);
    if (issue != null) {
      return switch (issue) {
        BusinessCatalogCategoryValidationIssue.duplicateName =>
          BusinessCatalogCategorySaveResult.duplicateName,
        BusinessCatalogCategoryValidationIssue.invalidParent ||
        BusinessCatalogCategoryValidationIssue.selfParent =>
          BusinessCatalogCategorySaveResult.invalidParent,
        BusinessCatalogCategoryValidationIssue.missingName =>
          BusinessCatalogCategorySaveResult.failure,
      };
    }

    final now = DateTime.now();
    _userCategoryCounter++;
    final category = BusinessCatalogCategory(
      categoryId: 'session-catalog-cat-$_userCategoryCounter',
      businessScopeId: businessScopeId,
      dataSource: BusinessCatalogCategoryDataSource.userSession,
      status: input.status,
      localized: input.localized.trimmed(),
      parentCategoryId: _normalizeParent(input.parentCategoryId),
      createdAt: now,
      updatedAt: now,
    );
    list.add(category);
    return BusinessCatalogCategorySaveResult.success;
  }

  @override
  BusinessCatalogCategorySaveResult updateCategory(
    String categoryId,
    BusinessCatalogCategoryInput input,
  ) {
    if (failNextSave) {
      failNextSave = false;
      return BusinessCatalogCategorySaveResult.failure;
    }
    final list = _ensureScopeList();
    final index = list.indexWhere((c) => c.categoryId == categoryId);
    if (index < 0) {
      return BusinessCatalogCategorySaveResult.notFound;
    }
    final issue = validateCategoryInput(
      input: input,
      existing: list,
      editingCategoryId: categoryId,
    );
    if (issue != null) {
      return switch (issue) {
        BusinessCatalogCategoryValidationIssue.duplicateName =>
          BusinessCatalogCategorySaveResult.duplicateName,
        BusinessCatalogCategoryValidationIssue.invalidParent ||
        BusinessCatalogCategoryValidationIssue.selfParent =>
          BusinessCatalogCategorySaveResult.invalidParent,
        BusinessCatalogCategoryValidationIssue.missingName =>
          BusinessCatalogCategorySaveResult.failure,
      };
    }

    final existing = list[index];
    list[index] = existing.copyWith(
      status: input.status,
      localized: input.localized.trimmed(),
      parentCategoryId: _normalizeParent(input.parentCategoryId),
      clearParent: _normalizeParent(input.parentCategoryId) == null,
      updatedAt: DateTime.now(),
    );
    return BusinessCatalogCategorySaveResult.success;
  }

  @override
  BusinessCatalogCategoryDeleteResult deleteCategory(String categoryId) {
    final list = _ensureScopeList();
    final index = list.indexWhere((c) => c.categoryId == categoryId);
    if (index < 0) {
      return BusinessCatalogCategoryDeleteResult.notFound;
    }
    if (_countItemsReferencingCategory(categoryId) > 0) {
      return BusinessCatalogCategoryDeleteResult.inUse;
    }
    list.removeAt(index);
    return BusinessCatalogCategoryDeleteResult.success;
  }

  @override
  void resetScopeToDemoSeed() {
    _categoriesByScope[businessScopeId] =
        buildDemoCatalogCategories(businessScopeId: businessScopeId);
  }

  List<BusinessCatalogCategory> _ensureScopeList() {
    final scope = businessScopeId;
    return _categoriesByScope.putIfAbsent(
      scope,
      () => buildDemoCatalogCategories(businessScopeId: scope),
    );
  }

  int _countItemsReferencingCategory(String categoryId) {
    final products =
        _productRepository?.countReferencingCategory(categoryId) ?? 0;
    final services =
        _serviceRepository?.countReferencingCategory(categoryId) ?? 0;
    return products + services;
  }

  String? _normalizeParent(String? raw) {
    final trimmed = raw?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }
}

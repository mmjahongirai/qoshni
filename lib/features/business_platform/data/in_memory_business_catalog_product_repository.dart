import 'package:qoshni/features/business_platform/data/business_catalog_product_demo_seed.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_product.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_catalog_category_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_catalog_product_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_owner_profile_repository.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_listing_validation.dart';

class InMemoryBusinessCatalogProductRepository
    implements BusinessCatalogProductRepository {
  InMemoryBusinessCatalogProductRepository(
    this._ownerProfileRepository,
    this._categoryRepository,
  );

  final BusinessOwnerProfileRepository _ownerProfileRepository;
  final BusinessCatalogCategoryRepository _categoryRepository;

  final Map<String, List<BusinessCatalogProduct>> _productsByScope = {};
  int _userProductCounter = 0;

  bool failNextSave = false;

  @override
  String get businessScopeId =>
      _ownerProfileRepository.ensureSessionProfile().sessionProfileId;

  @override
  List<BusinessCatalogProduct> listForCurrentScope() {
    return List.unmodifiable(_ensureScopeList());
  }

  @override
  BusinessCatalogProduct? findById(String productId) {
    try {
      return _ensureScopeList().firstWhere((p) => p.productId == productId);
    } on StateError {
      return null;
    }
  }

  @override
  int countReferencingCategory(String categoryId) {
    return _ensureScopeList().where((p) => p.categoryId == categoryId).length;
  }

  @override
  BusinessCatalogProductSaveResult createProduct(
    BusinessCatalogProductInput input,
  ) {
    if (failNextSave) {
      failNextSave = false;
      return BusinessCatalogProductSaveResult.failure;
    }
    if (!catalogListingHasName(input.localized)) {
      return BusinessCatalogProductSaveResult.failure;
    }
    if (!_categoryInScope(input.categoryId)) {
      return BusinessCatalogProductSaveResult.invalidCategory;
    }
    final now = DateTime.now();
    _userProductCounter++;
    _ensureScopeList().add(
      BusinessCatalogProduct(
        productId: 'session-catalog-product-$_userProductCounter',
        businessScopeId: businessScopeId,
        categoryId: input.categoryId.trim(),
        dataSource: BusinessCatalogProductDataSource.userSession,
        status: input.status,
        localized: input.localized.trimmed(),
        attributes: _normalizeAttributes(input.attributes),
        createdAt: now,
        updatedAt: now,
      ),
    );
    return BusinessCatalogProductSaveResult.success;
  }

  @override
  BusinessCatalogProductSaveResult updateProduct(
    String productId,
    BusinessCatalogProductInput input,
  ) {
    if (failNextSave) {
      failNextSave = false;
      return BusinessCatalogProductSaveResult.failure;
    }
    final list = _ensureScopeList();
    final index = list.indexWhere((p) => p.productId == productId);
    if (index < 0) {
      return BusinessCatalogProductSaveResult.notFound;
    }
    if (!catalogListingHasName(input.localized)) {
      return BusinessCatalogProductSaveResult.failure;
    }
    if (!_categoryInScope(input.categoryId)) {
      return BusinessCatalogProductSaveResult.invalidCategory;
    }
    list[index] = list[index].copyWith(
      categoryId: input.categoryId.trim(),
      status: input.status,
      localized: input.localized.trimmed(),
      attributes: _normalizeAttributes(input.attributes),
      updatedAt: DateTime.now(),
    );
    return BusinessCatalogProductSaveResult.success;
  }

  bool _categoryInScope(String categoryId) {
    final category = _categoryRepository.findById(categoryId.trim());
    return category != null &&
        category.businessScopeId == businessScopeId;
  }

  List<CatalogProductAttribute> _normalizeAttributes(
    List<CatalogProductAttribute> raw,
  ) {
    return raw
        .map(
          (a) => CatalogProductAttribute(
            key: a.key.trim(),
            value: a.value.trim(),
          ),
        )
        .where((a) => a.key.isNotEmpty)
        .toList(growable: false);
  }

  List<BusinessCatalogProduct> _ensureScopeList() {
    final scope = businessScopeId;
    return _productsByScope.putIfAbsent(
      scope,
      () => buildDemoCatalogProducts(businessScopeId: scope),
    );
  }
}

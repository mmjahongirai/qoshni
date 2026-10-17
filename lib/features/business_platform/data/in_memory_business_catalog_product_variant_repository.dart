import 'package:qoshni/features/business_platform/data/business_catalog_product_variant_demo_seed.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_product_variant.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_catalog_product_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_catalog_product_variant_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_owner_profile_repository.dart';

class InMemoryBusinessCatalogProductVariantRepository
    implements BusinessCatalogProductVariantRepository {
  InMemoryBusinessCatalogProductVariantRepository(
    this._ownerProfileRepository,
    this._productRepository,
  );

  final BusinessOwnerProfileRepository _ownerProfileRepository;
  final BusinessCatalogProductRepository _productRepository;

  final Map<String, List<BusinessCatalogProductVariant>> _variantsByScope = {};
  int _userVariantCounter = 0;

  bool failNextSave = false;

  @override
  String get businessScopeId =>
      _ownerProfileRepository.ensureSessionProfile().sessionProfileId;

  @override
  List<BusinessCatalogProductVariant> variantsForProduct(String productId) {
    return _ensureScopeList()
        .where((v) => v.productId == productId)
        .toList(growable: false);
  }

  @override
  BusinessCatalogProductVariant? findById(String variantId) {
    try {
      return _ensureScopeList().firstWhere((v) => v.variantId == variantId);
    } on StateError {
      return null;
    }
  }

  @override
  BusinessCatalogProductVariantSaveResult createVariant({
    required String productId,
    required BusinessCatalogProductVariantInput input,
  }) {
    if (failNextSave) {
      failNextSave = false;
      return BusinessCatalogProductVariantSaveResult.failure;
    }
    final product = _productRepository.findById(productId);
    if (product == null || product.businessScopeId != businessScopeId) {
      return BusinessCatalogProductVariantSaveResult.invalidProduct;
    }
    final sku = input.sku.trim();
    if (sku.isEmpty || input.label.trim().isEmpty) {
      return BusinessCatalogProductVariantSaveResult.failure;
    }
    if (_skuTaken(sku)) {
      return BusinessCatalogProductVariantSaveResult.duplicateSku;
    }
    final now = DateTime.now();
    _userVariantCounter++;
    _ensureScopeList().add(
      BusinessCatalogProductVariant(
        variantId: 'session-catalog-variant-$_userVariantCounter',
        productId: productId,
        businessScopeId: businessScopeId,
        dataSource: BusinessCatalogProductVariantDataSource.userSession,
        label: input.label.trim(),
        sku: sku,
        status: input.status,
        createdAt: now,
        updatedAt: now,
      ),
    );
    return BusinessCatalogProductVariantSaveResult.success;
  }

  @override
  BusinessCatalogProductVariantSaveResult updateVariant({
    required String variantId,
    required BusinessCatalogProductVariantInput input,
  }) {
    if (failNextSave) {
      failNextSave = false;
      return BusinessCatalogProductVariantSaveResult.failure;
    }
    final list = _ensureScopeList();
    final index = list.indexWhere((v) => v.variantId == variantId);
    if (index < 0) {
      return BusinessCatalogProductVariantSaveResult.notFound;
    }
    final sku = input.sku.trim();
    if (sku.isEmpty || input.label.trim().isEmpty) {
      return BusinessCatalogProductVariantSaveResult.failure;
    }
    if (_skuTaken(sku, exceptVariantId: variantId)) {
      return BusinessCatalogProductVariantSaveResult.duplicateSku;
    }
    final existing = list[index];
    if (_productRepository.findById(existing.productId) == null) {
      return BusinessCatalogProductVariantSaveResult.invalidProduct;
    }
    list[index] = existing.copyWith(
      label: input.label.trim(),
      sku: sku,
      status: input.status,
      updatedAt: DateTime.now(),
    );
    return BusinessCatalogProductVariantSaveResult.success;
  }

  @override
  BusinessCatalogProductVariantDeleteResult deleteVariant(String variantId) {
    final list = _ensureScopeList();
    final index = list.indexWhere((v) => v.variantId == variantId);
    if (index < 0) {
      return BusinessCatalogProductVariantDeleteResult.notFound;
    }
    list.removeAt(index);
    return BusinessCatalogProductVariantDeleteResult.success;
  }

  bool _skuTaken(String sku, {String? exceptVariantId}) {
    final normalized = sku.toLowerCase();
    for (final variant in _ensureScopeList()) {
      if (variant.variantId == exceptVariantId) {
        continue;
      }
      if (variant.sku.toLowerCase() == normalized) {
        return true;
      }
    }
    return false;
  }

  List<BusinessCatalogProductVariant> _ensureScopeList() {
    final scope = businessScopeId;
    return _variantsByScope.putIfAbsent(
      scope,
      () => buildDemoCatalogProductVariants(businessScopeId: scope),
    );
  }
}

import 'package:flutter/foundation.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_product_variant.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_catalog_product_variant_repository.dart';

class BusinessCatalogProductVariantController extends ChangeNotifier {
  BusinessCatalogProductVariantController(this._repository);

  final BusinessCatalogProductVariantRepository _repository;

  bool _saveBusy = false;

  bool get saveBusy => _saveBusy;

  List<BusinessCatalogProductVariant> variantsForProduct(String productId) =>
      _repository.variantsForProduct(productId);

  BusinessCatalogProductVariant? variantById(String variantId) =>
      _repository.findById(variantId);

  void refresh() => notifyListeners();

  Future<BusinessCatalogProductVariantSaveResult> createVariant({
    required String productId,
    required BusinessCatalogProductVariantInput input,
  }) async {
    return _save(
      () => _repository.createVariant(productId: productId, input: input),
    );
  }

  Future<BusinessCatalogProductVariantSaveResult> updateVariant({
    required String variantId,
    required BusinessCatalogProductVariantInput input,
  }) async {
    return _save(
      () => _repository.updateVariant(variantId: variantId, input: input),
    );
  }

  Future<BusinessCatalogProductVariantSaveResult> _save(
    BusinessCatalogProductVariantSaveResult Function() action,
  ) async {
    if (_saveBusy) {
      return BusinessCatalogProductVariantSaveResult.failure;
    }
    _saveBusy = true;
    notifyListeners();
    await Future<void>.delayed(Duration.zero);
    final result = action();
    _saveBusy = false;
    notifyListeners();
    return result;
  }
}

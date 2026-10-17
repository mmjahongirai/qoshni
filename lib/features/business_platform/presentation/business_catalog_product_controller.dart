import 'package:flutter/foundation.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_product.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_catalog_product_repository.dart';

class BusinessCatalogProductController extends ChangeNotifier {
  BusinessCatalogProductController(this._repository);

  final BusinessCatalogProductRepository _repository;

  bool _saveBusy = false;

  bool get saveBusy => _saveBusy;

  List<BusinessCatalogProduct> get products => _repository.listForCurrentScope();

  BusinessCatalogProduct? productById(String productId) =>
      _repository.findById(productId);

  void refresh() => notifyListeners();

  Future<BusinessCatalogProductSaveResult> createProduct(
    BusinessCatalogProductInput input,
  ) async {
    return _save(() => _repository.createProduct(input));
  }

  Future<BusinessCatalogProductSaveResult> updateProduct(
    String productId,
    BusinessCatalogProductInput input,
  ) async {
    return _save(() => _repository.updateProduct(productId, input));
  }

  Future<BusinessCatalogProductSaveResult> _save(
    BusinessCatalogProductSaveResult Function() action,
  ) async {
    if (_saveBusy) {
      return BusinessCatalogProductSaveResult.failure;
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

import 'package:flutter/foundation.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_category.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_catalog_category_repository.dart';

class BusinessCatalogCategoryController extends ChangeNotifier {
  BusinessCatalogCategoryController(this._repository);

  final BusinessCatalogCategoryRepository _repository;

  bool _saveBusy = false;

  bool get saveBusy => _saveBusy;

  String get businessScopeId => _repository.businessScopeId;

  List<BusinessCatalogCategory> get categories =>
      _repository.listForCurrentScope();

  BusinessCatalogCategory? categoryById(String categoryId) =>
      _repository.findById(categoryId);

  void refresh() {
    notifyListeners();
  }

  Future<BusinessCatalogCategorySaveResult> createCategory(
    BusinessCatalogCategoryInput input,
  ) async {
    return _save(() => _repository.createCategory(input));
  }

  Future<BusinessCatalogCategorySaveResult> updateCategory(
    String categoryId,
    BusinessCatalogCategoryInput input,
  ) async {
    return _save(() => _repository.updateCategory(categoryId, input));
  }

  Future<BusinessCatalogCategoryDeleteResult> deleteCategory(
    String categoryId,
  ) async {
    if (_saveBusy) {
      return BusinessCatalogCategoryDeleteResult.failure;
    }
    _saveBusy = true;
    notifyListeners();
    await Future<void>.delayed(Duration.zero);
    final result = _repository.deleteCategory(categoryId);
    _saveBusy = false;
    notifyListeners();
    return result;
  }

  Future<BusinessCatalogCategorySaveResult> _save(
    BusinessCatalogCategorySaveResult Function() action,
  ) async {
    if (_saveBusy) {
      return BusinessCatalogCategorySaveResult.failure;
    }
    _saveBusy = true;
    notifyListeners();
    await Future<void>.delayed(Duration.zero);
    final result = action();
    _saveBusy = false;
    notifyListeners();
    return result;
  }

  void resetToDemoSeed() {
    _repository.resetScopeToDemoSeed();
    notifyListeners();
  }
}

import 'package:flutter/foundation.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_demo_item.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_catalog_category_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_catalog_demo_item_repository.dart';

class BusinessCatalogController extends ChangeNotifier {
  BusinessCatalogController(
    this._categoryRepository,
    this._itemRepository,
  );

  final BusinessCatalogCategoryRepository _categoryRepository;
  final BusinessCatalogDemoItemRepository _itemRepository;

  String get businessScopeId => _categoryRepository.businessScopeId;

  BusinessCatalogOverviewStats get overviewStats {
    final categories = _categoryRepository.listForCurrentScope();
    return _itemRepository.overviewStatsForScope(
      categoryCount: categories.length,
    );
  }

  void refresh() {
    notifyListeners();
  }
}

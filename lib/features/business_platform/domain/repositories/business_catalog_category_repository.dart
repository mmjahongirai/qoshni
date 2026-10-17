import 'package:qoshni/features/business_platform/domain/business_catalog_category.dart';

enum BusinessCatalogCategorySaveResult {
  success,
  notFound,
  duplicateName,
  invalidParent,
  failure,
}

enum BusinessCatalogCategoryDeleteResult {
  success,
  notFound,
  inUse,
  failure,
}

abstract class BusinessCatalogCategoryRepository {
  String get businessScopeId;

  List<BusinessCatalogCategory> listForCurrentScope();

  BusinessCatalogCategory? findById(String categoryId);

  BusinessCatalogCategorySaveResult createCategory(
    BusinessCatalogCategoryInput input,
  );

  BusinessCatalogCategorySaveResult updateCategory(
    String categoryId,
    BusinessCatalogCategoryInput input,
  );

  BusinessCatalogCategoryDeleteResult deleteCategory(String categoryId);

  void resetScopeToDemoSeed();
}

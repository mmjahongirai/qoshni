import 'package:qoshni/features/business_platform/domain/business_catalog_product.dart';

enum BusinessCatalogProductSaveResult {
  success,
  notFound,
  invalidCategory,
  failure,
}

abstract class BusinessCatalogProductRepository {
  String get businessScopeId;

  List<BusinessCatalogProduct> listForCurrentScope();

  BusinessCatalogProduct? findById(String productId);

  int countReferencingCategory(String categoryId);

  BusinessCatalogProductSaveResult createProduct(BusinessCatalogProductInput input);

  BusinessCatalogProductSaveResult updateProduct(
    String productId,
    BusinessCatalogProductInput input,
  );
}

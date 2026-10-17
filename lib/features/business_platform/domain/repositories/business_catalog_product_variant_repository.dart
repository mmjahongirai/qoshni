import 'package:qoshni/features/business_platform/domain/business_catalog_product_variant.dart';

enum BusinessCatalogProductVariantSaveResult {
  success,
  notFound,
  invalidProduct,
  duplicateSku,
  failure,
}

enum BusinessCatalogProductVariantDeleteResult {
  success,
  notFound,
  failure,
}

abstract class BusinessCatalogProductVariantRepository {
  String get businessScopeId;

  List<BusinessCatalogProductVariant> variantsForProduct(String productId);

  BusinessCatalogProductVariant? findById(String variantId);

  BusinessCatalogProductVariantSaveResult createVariant({
    required String productId,
    required BusinessCatalogProductVariantInput input,
  });

  BusinessCatalogProductVariantSaveResult updateVariant({
    required String variantId,
    required BusinessCatalogProductVariantInput input,
  });

  BusinessCatalogProductVariantDeleteResult deleteVariant(String variantId);
}

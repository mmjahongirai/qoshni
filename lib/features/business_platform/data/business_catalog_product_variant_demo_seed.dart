import 'package:qoshni/features/business_platform/data/business_catalog_product_demo_seed.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_listing_status.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_product_variant.dart';

const String kDemoCatalogVariantBreadStandardId =
    'demo-catalog-variant-bread-standard';

List<BusinessCatalogProductVariant> buildDemoCatalogProductVariants({
  required String businessScopeId,
}) {
  final now = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

  return [
    BusinessCatalogProductVariant(
      variantId: kDemoCatalogVariantBreadStandardId,
      productId: kDemoCatalogProductBreadId,
      businessScopeId: businessScopeId,
      dataSource: BusinessCatalogProductVariantDataSource.demoSeed,
      label: 'Standard loaf',
      sku: 'BRD-STD-001',
      status: BusinessCatalogListingStatus.active,
      createdAt: now,
      updatedAt: now,
    ),
  ];
}

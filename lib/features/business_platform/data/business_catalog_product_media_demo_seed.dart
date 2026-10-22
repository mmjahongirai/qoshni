import 'package:qoshni/features/business_platform/data/business_catalog_product_demo_seed.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_product.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_product_media_item.dart';

const String kDemoCatalogMediaBreadPrimaryId = 'demo-catalog-media-bread-primary';

List<BusinessCatalogProductMediaItem> buildDemoCatalogProductMedia({
  required String businessScopeId,
}) {
  final now = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

  return [
    BusinessCatalogProductMediaItem(
      mediaId: kDemoCatalogMediaBreadPrimaryId,
      productId: kDemoCatalogProductBreadId,
      businessScopeId: businessScopeId,
      dataSource: BusinessCatalogProductDataSource.demoSeed,
      previewKind: BusinessCatalogProductMediaPreviewKind.demoPlaceholder,
      sortIndex: 0,
      isPrimary: true,
      displayLabel: 'Demo bread preview',
      createdAt: now,
      updatedAt: now,
    ),
  ];
}

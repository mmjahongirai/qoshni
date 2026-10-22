import 'package:qoshni/features/business_platform/data/business_catalog_product_demo_seed.dart';
import 'package:qoshni/features/business_platform/data/business_catalog_product_variant_demo_seed.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_inventory_item.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_inventory_track_status.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_product.dart';

const String kDemoCatalogInventoryBreadTashkentId =
    'demo-catalog-inventory-bread-tashkent';
const String kDemoCatalogInventoryBreadSamarkandLowId =
    'demo-catalog-inventory-bread-samarkand-low';
const String kDemoCatalogInventoryPlovOutId =
    'demo-catalog-inventory-plov-out';
const String kDemoCatalogInventoryBasketUnavailableId =
    'demo-catalog-inventory-basket-unavailable';

const String kDemoBranchTashkentCenterId = 'demo-branch-tashkent-center';
const String kDemoBranchSamarkandId = 'demo-branch-samarkand';

List<BusinessCatalogInventoryItem> buildDemoCatalogInventory({
  required String businessScopeId,
}) {
  final now = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

  return [
    BusinessCatalogInventoryItem(
      inventoryItemId: kDemoCatalogInventoryBreadTashkentId,
      businessScopeId: businessScopeId,
      productId: kDemoCatalogProductBreadId,
      variantId: kDemoCatalogVariantBreadStandardId,
      branchId: kDemoBranchTashkentCenterId,
      dataSource: BusinessCatalogProductDataSource.demoSeed,
      onHandQuantity: 48,
      reservedQuantity: 3,
      lowStockThreshold: 10,
      trackStatus: BusinessCatalogInventoryTrackStatus.active,
      updatedAt: now,
    ),
    BusinessCatalogInventoryItem(
      inventoryItemId: kDemoCatalogInventoryBreadSamarkandLowId,
      businessScopeId: businessScopeId,
      productId: kDemoCatalogProductBreadId,
      branchId: kDemoBranchSamarkandId,
      dataSource: BusinessCatalogProductDataSource.demoSeed,
      onHandQuantity: 5,
      reservedQuantity: 1,
      lowStockThreshold: 8,
      trackStatus: BusinessCatalogInventoryTrackStatus.active,
      updatedAt: now,
    ),
    BusinessCatalogInventoryItem(
      inventoryItemId: kDemoCatalogInventoryPlovOutId,
      businessScopeId: businessScopeId,
      productId: kDemoCatalogProductPlovId,
      branchId: kDemoBranchTashkentCenterId,
      dataSource: BusinessCatalogProductDataSource.demoSeed,
      onHandQuantity: 0,
      reservedQuantity: 0,
      lowStockThreshold: 5,
      trackStatus: BusinessCatalogInventoryTrackStatus.active,
      updatedAt: now,
    ),
    BusinessCatalogInventoryItem(
      inventoryItemId: kDemoCatalogInventoryBasketUnavailableId,
      businessScopeId: businessScopeId,
      productId: kDemoCatalogProductDailyBasketId,
      branchId: kDemoBranchSamarkandId,
      dataSource: BusinessCatalogProductDataSource.demoSeed,
      onHandQuantity: 20,
      reservedQuantity: 0,
      lowStockThreshold: 3,
      trackStatus: BusinessCatalogInventoryTrackStatus.manuallyUnavailable,
      updatedAt: now,
    ),
  ];
}

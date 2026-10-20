import 'package:qoshni/features/business_platform/data/business_catalog_inventory_demo_seed.dart';
import 'package:qoshni/features/business_platform/data/business_catalog_product_demo_seed.dart';
import 'package:qoshni/features/business_platform/data/business_catalog_service_demo_seed.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_price_status.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_product.dart';
import 'package:qoshni/features/business_platform/domain/business_fulfillment_configuration.dart';
import 'package:qoshni/features/business_platform/domain/business_fulfillment_target_scope.dart';
import 'package:qoshni/features/business_platform/domain/business_fulfillment_type.dart';

const String kDemoFulfillmentStoreDeliveryPickupId =
    'demo-fulfillment-store-delivery-pickup';
const String kDemoFulfillmentShopSamarkandId =
    'demo-fulfillment-shop-samarkand';
const String kDemoFulfillmentServiceAtLocationId =
    'demo-fulfillment-service-at-location';
const String kDemoFulfillmentDraftId = 'demo-fulfillment-draft';
const String kDemoFulfillmentArchivedId = 'demo-fulfillment-archived';

final DateTime kDemoFulfillmentEpoch =
    DateTime.utc(2025, 1, 1, 0, 0, 0);

List<BusinessFulfillmentConfiguration> buildDemoFulfillmentConfigurations({
  required String businessScopeId,
}) {
  return [
    BusinessFulfillmentConfiguration(
      configurationId: kDemoFulfillmentStoreDeliveryPickupId,
      businessScopeId: businessScopeId,
      branchId: kDemoBranchTashkentCenterId,
      targetScope: BusinessFulfillmentTargetScope.businessWide,
      supportedFulfillmentTypes: const [
        BusinessFulfillmentType.delivery,
        BusinessFulfillmentType.pickup,
      ],
      status: BusinessCatalogPriceStatus.active,
      revision: 1,
      dataSource: BusinessCatalogProductDataSource.demoSeed,
      createdAt: kDemoFulfillmentEpoch,
      updatedAt: kDemoFulfillmentEpoch,
    ),
    BusinessFulfillmentConfiguration(
      configurationId: kDemoFulfillmentShopSamarkandId,
      businessScopeId: businessScopeId,
      branchId: kDemoBranchSamarkandId,
      targetScope: BusinessFulfillmentTargetScope.businessWide,
      supportedFulfillmentTypes: const [
        BusinessFulfillmentType.delivery,
        BusinessFulfillmentType.pickup,
      ],
      status: BusinessCatalogPriceStatus.active,
      revision: 1,
      dataSource: BusinessCatalogProductDataSource.demoSeed,
      createdAt: kDemoFulfillmentEpoch,
      updatedAt: kDemoFulfillmentEpoch,
    ),
    BusinessFulfillmentConfiguration(
      configurationId: kDemoFulfillmentServiceAtLocationId,
      businessScopeId: businessScopeId,
      branchId: kDemoBranchTashkentCenterId,
      targetScope: BusinessFulfillmentTargetScope.service,
      listingId: kDemoCatalogServicePackingId,
      supportedFulfillmentTypes: const [
        BusinessFulfillmentType.serviceAtLocation,
      ],
      status: BusinessCatalogPriceStatus.active,
      revision: 1,
      dataSource: BusinessCatalogProductDataSource.demoSeed,
      createdAt: kDemoFulfillmentEpoch,
      updatedAt: kDemoFulfillmentEpoch,
    ),
    BusinessFulfillmentConfiguration(
      configurationId: kDemoFulfillmentDraftId,
      businessScopeId: businessScopeId,
      branchId: kDemoBranchTashkentCenterId,
      targetScope: BusinessFulfillmentTargetScope.product,
      listingId: kDemoCatalogProductBreadId,
      supportedFulfillmentTypes: const [BusinessFulfillmentType.pickup],
      status: BusinessCatalogPriceStatus.draft,
      revision: 1,
      dataSource: BusinessCatalogProductDataSource.demoSeed,
      createdAt: kDemoFulfillmentEpoch,
      updatedAt: kDemoFulfillmentEpoch,
    ),
    BusinessFulfillmentConfiguration(
      configurationId: kDemoFulfillmentArchivedId,
      businessScopeId: businessScopeId,
      branchId: kDemoBranchTashkentCenterId,
      targetScope: BusinessFulfillmentTargetScope.businessWide,
      supportedFulfillmentTypes: const [BusinessFulfillmentType.delivery],
      status: BusinessCatalogPriceStatus.archived,
      revision: 1,
      dataSource: BusinessCatalogProductDataSource.demoSeed,
      createdAt: kDemoFulfillmentEpoch,
      updatedAt: kDemoFulfillmentEpoch,
    ),
  ];
}

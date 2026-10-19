import 'package:qoshni/features/business_platform/data/business_catalog_inventory_demo_seed.dart';
import 'package:qoshni/features/business_platform/data/business_catalog_service_demo_seed.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_localized_fields.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_product.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_resource.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_resource_status.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_resource_type.dart';

const String kDemoCatalogResourceOvenTashkentId =
    'demo-catalog-resource-oven-tashkent';
const String kDemoCatalogResourceStylistSamarkandId =
    'demo-catalog-resource-stylist-samarkand';
const String kDemoCatalogResourcePackingCapacityId =
    'demo-catalog-resource-packing-capacity';
const String kDemoCatalogResourceUnavailableRoomId =
    'demo-catalog-resource-room-unavailable';

List<BusinessCatalogResource> buildDemoCatalogResources({
  required String businessScopeId,
}) {
  final now = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

  return [
    BusinessCatalogResource(
      resourceId: kDemoCatalogResourceOvenTashkentId,
      businessScopeId: businessScopeId,
      branchId: kDemoBranchTashkentCenterId,
      dataSource: BusinessCatalogProductDataSource.demoSeed,
      type: BusinessCatalogResourceType.equipment,
      capacityUnit: 'units',
      localized: const BusinessCatalogLocalizedFields(
        nameEn: 'Demo bakery oven',
        nameRu: 'Demo печь',
        nameUz: 'Demo non pechi',
        descriptionEn: 'Parallel baking capacity (preview).',
      ),
      totalCapacity: 4,
      allocatedCapacity: 1,
      status: BusinessCatalogResourceStatus.active,
      createdAt: now,
      updatedAt: now,
    ),
    BusinessCatalogResource(
      resourceId: kDemoCatalogResourceStylistSamarkandId,
      businessScopeId: businessScopeId,
      branchId: kDemoBranchSamarkandId,
      dataSource: BusinessCatalogProductDataSource.demoSeed,
      type: BusinessCatalogResourceType.staff,
      capacityUnit: 'technicians',
      localized: const BusinessCatalogLocalizedFields(
        nameEn: 'Styling team (low availability)',
        nameRu: 'Команда стилистов',
        nameUz: 'Stilistlar jamoasi',
        descriptionEn: 'Most slots booked in demo data.',
      ),
      totalCapacity: 3,
      allocatedCapacity: 2,
      status: BusinessCatalogResourceStatus.active,
      createdAt: now,
      updatedAt: now,
    ),
    BusinessCatalogResource(
      resourceId: kDemoCatalogResourcePackingCapacityId,
      businessScopeId: businessScopeId,
      branchId: kDemoBranchTashkentCenterId,
      dataSource: BusinessCatalogProductDataSource.demoSeed,
      type: BusinessCatalogResourceType.serviceCapacity,
      capacityUnit: 'concurrent_jobs',
      localized: const BusinessCatalogLocalizedFields(
        nameEn: 'Packing station capacity',
        nameRu: 'Упаковочная станция',
        nameUz: 'Qadoqlash stansiyasi',
        descriptionEn: 'Linked to packing service preview.',
      ),
      totalCapacity: 6,
      allocatedCapacity: 2,
      status: BusinessCatalogResourceStatus.active,
      serviceId: kDemoCatalogServicePackingId,
      createdAt: now,
      updatedAt: now,
    ),
    BusinessCatalogResource(
      resourceId: kDemoCatalogResourceUnavailableRoomId,
      businessScopeId: businessScopeId,
      branchId: kDemoBranchSamarkandId,
      dataSource: BusinessCatalogProductDataSource.demoSeed,
      type: BusinessCatalogResourceType.equipment,
      capacityUnit: 'rooms',
      localized: const BusinessCatalogLocalizedFields(
        nameEn: 'Prep room (unavailable)',
        nameRu: 'Подготовительная комната',
        nameUz: 'Tayyorlov xonasi',
        descriptionEn: 'Manually blocked in demo.',
      ),
      totalCapacity: 2,
      allocatedCapacity: 0,
      status: BusinessCatalogResourceStatus.manuallyUnavailable,
      createdAt: now,
      updatedAt: now,
    ),
  ];
}

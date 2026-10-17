import 'package:qoshni/features/business_platform/data/business_catalog_category_demo_seed.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_listing_status.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_localized_fields.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_service.dart';

const String kDemoCatalogServicePackingId = 'demo-catalog-item-packing-service';
const String kDemoCatalogServiceDeliveryDraftId =
    'demo-catalog-item-delivery-draft';

List<BusinessCatalogService> buildDemoCatalogServices({
  required String businessScopeId,
}) {
  final now = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

  return [
    BusinessCatalogService(
      serviceId: kDemoCatalogServicePackingId,
      businessScopeId: businessScopeId,
      categoryId: kDemoCatalogCategoryInStoreServicesId,
      dataSource: BusinessCatalogServiceDataSource.demoSeed,
      status: BusinessCatalogListingStatus.active,
      localized: const BusinessCatalogLocalizedFields(
        nameUz: 'Qadoqlash xizmati',
        nameRu: 'Упаковка',
        nameEn: 'Packing service',
        descriptionUz: 'Do‘konda qadoqlash preview xizmati.',
        descriptionRu: 'Preview-услуга упаковки в магазине.',
        descriptionEn: 'In-store packing preview service.',
      ),
      durationMinutes: 15,
      createdAt: now,
      updatedAt: now,
    ),
    BusinessCatalogService(
      serviceId: kDemoCatalogServiceDeliveryDraftId,
      businessScopeId: businessScopeId,
      categoryId: kDemoCatalogCategoryInStoreServicesId,
      dataSource: BusinessCatalogServiceDataSource.demoSeed,
      status: BusinessCatalogListingStatus.draft,
      localized: const BusinessCatalogLocalizedFields(
        nameUz: 'Yetkazib berish (qoralama)',
        nameRu: 'Доставка (черновик)',
        nameEn: 'Delivery (draft)',
        descriptionUz: 'Preview yetkazib berish — hali faol emas.',
        descriptionRu: 'Preview-доставка — пока не активна.',
        descriptionEn: 'Preview delivery — not active yet.',
      ),
      createdAt: now,
      updatedAt: now,
    ),
  ];
}

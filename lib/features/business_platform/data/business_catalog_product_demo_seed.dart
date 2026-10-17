import 'package:qoshni/features/business_platform/data/business_catalog_category_demo_seed.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_listing_status.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_localized_fields.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_product.dart';

const String kDemoCatalogProductBreadId = 'demo-catalog-item-bread';
const String kDemoCatalogProductDailyBasketId = 'demo-catalog-item-daily-basket';
const String kDemoCatalogProductPlovId = 'demo-catalog-item-plov';

List<BusinessCatalogProduct> buildDemoCatalogProducts({
  required String businessScopeId,
}) {
  final now = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

  return [
    BusinessCatalogProduct(
      productId: kDemoCatalogProductBreadId,
      businessScopeId: businessScopeId,
      categoryId: kDemoCatalogCategoryFreshGoodsId,
      dataSource: BusinessCatalogProductDataSource.demoSeed,
      status: BusinessCatalogListingStatus.active,
      localized: const BusinessCatalogLocalizedFields(
        nameUz: 'Non',
        nameRu: 'Хлеб',
        nameEn: 'Fresh bread',
        descriptionUz: 'Har kuni yangi pishirilgan non (preview).',
        descriptionRu: 'Ежедневно свежий хлеб (preview).',
        descriptionEn: 'Daily baked bread (preview).',
      ),
      attributes: const [],
      createdAt: now,
      updatedAt: now,
    ),
    BusinessCatalogProduct(
      productId: kDemoCatalogProductDailyBasketId,
      businessScopeId: businessScopeId,
      categoryId: kDemoCatalogCategoryFreshGoodsId,
      dataSource: BusinessCatalogProductDataSource.demoSeed,
      status: BusinessCatalogListingStatus.active,
      localized: const BusinessCatalogLocalizedFields(
        nameUz: 'Kundalik savat',
        nameRu: 'Дневная корзина',
        nameEn: 'Daily basket',
        descriptionUz: 'Kundalik oziq-ovqat to‘plami preview.',
        descriptionRu: 'Preview-набор продуктов на день.',
        descriptionEn: 'Preview daily grocery basket.',
      ),
      attributes: const [],
      createdAt: now,
      updatedAt: now,
    ),
    BusinessCatalogProduct(
      productId: kDemoCatalogProductPlovId,
      businessScopeId: businessScopeId,
      categoryId: kDemoCatalogCategoryReadyMealsId,
      dataSource: BusinessCatalogProductDataSource.demoSeed,
      status: BusinessCatalogListingStatus.active,
      localized: const BusinessCatalogLocalizedFields(
        nameUz: 'Osh',
        nameRu: 'Плов',
        nameEn: 'Plov',
        descriptionUz: 'Tayyor osh preview pozitsiyasi.',
        descriptionRu: 'Preview-позиция плова.',
        descriptionEn: 'Preview plov offering.',
      ),
      attributes: const [],
      createdAt: now,
      updatedAt: now,
    ),
  ];
}

import 'package:qoshni/features/business_platform/domain/business_catalog_category.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_category_status.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_localized_fields.dart';

const String kDemoCatalogCategoryFreshGoodsId = 'demo-catalog-cat-fresh-goods';
const String kDemoCatalogCategoryReadyMealsId = 'demo-catalog-cat-ready-meals';
const String kDemoCatalogCategoryInStoreServicesId =
    'demo-catalog-cat-in-store-services';

List<BusinessCatalogCategory> buildDemoCatalogCategories({
  required String businessScopeId,
}) {
  final now = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

  return [
    BusinessCatalogCategory(
      categoryId: kDemoCatalogCategoryFreshGoodsId,
      businessScopeId: businessScopeId,
      dataSource: BusinessCatalogCategoryDataSource.demoSeed,
      status: BusinessCatalogCategoryStatus.active,
      localized: const BusinessCatalogLocalizedFields(
        nameUz: 'Yangi mahsulotlar',
        nameRu: 'Свежие товары',
        nameEn: 'Fresh goods',
        descriptionUz: 'Kundalik yangi oziq-ovqat va non mahsulotlari.',
        descriptionRu: 'Ежедневные свежие продукты и хлеб.',
        descriptionEn: 'Daily fresh groceries and bakery items.',
      ),
      createdAt: now,
      updatedAt: now,
    ),
    BusinessCatalogCategory(
      categoryId: kDemoCatalogCategoryReadyMealsId,
      businessScopeId: businessScopeId,
      dataSource: BusinessCatalogCategoryDataSource.demoSeed,
      status: BusinessCatalogCategoryStatus.active,
      parentCategoryId: kDemoCatalogCategoryFreshGoodsId,
      localized: const BusinessCatalogLocalizedFields(
        nameUz: 'Tayyor taomlar',
        nameRu: 'Готовые блюда',
        nameEn: 'Ready meals',
        descriptionUz: 'Issiq va sof taomlar preview ro‘yxati.',
        descriptionRu: 'Preview-список горячих блюд.',
        descriptionEn: 'Preview list of hot meals.',
      ),
      createdAt: now,
      updatedAt: now,
    ),
    BusinessCatalogCategory(
      categoryId: kDemoCatalogCategoryInStoreServicesId,
      businessScopeId: businessScopeId,
      dataSource: BusinessCatalogCategoryDataSource.demoSeed,
      status: BusinessCatalogCategoryStatus.draft,
      localized: const BusinessCatalogLocalizedFields(
        nameUz: 'Do‘kon xizmatlari',
        nameRu: 'Услуги магазина',
        nameEn: 'In-store services',
        descriptionUz: 'Qadoqlash va yetkazib berish preview xizmatlari.',
        descriptionRu: 'Preview-услуги упаковки и доставки.',
        descriptionEn: 'Preview packing and delivery services.',
      ),
      createdAt: now,
      updatedAt: now,
    ),
  ];
}

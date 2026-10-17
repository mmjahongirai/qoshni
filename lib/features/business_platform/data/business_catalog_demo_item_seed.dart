import 'package:qoshni/features/business_platform/data/business_catalog_category_demo_seed.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_demo_item.dart';
import 'package:qoshni/features/business_platform/domain/business_offering_kind.dart';

const String kDemoCatalogItemBreadId = 'demo-catalog-item-bread';
const String kDemoCatalogItemDailyBasketId = 'demo-catalog-item-daily-basket';
const String kDemoCatalogItemPlovId = 'demo-catalog-item-plov';
const String kDemoCatalogItemPackingServiceId =
    'demo-catalog-item-packing-service';
const String kDemoCatalogItemDeliveryDraftId =
    'demo-catalog-item-delivery-draft';

List<BusinessCatalogDemoItem> buildDemoCatalogItems({
  required String businessScopeId,
}) {
  return [
    BusinessCatalogDemoItem(
      itemId: kDemoCatalogItemBreadId,
      businessScopeId: businessScopeId,
      categoryId: kDemoCatalogCategoryFreshGoodsId,
      kind: BusinessOfferingKind.product,
      status: BusinessCatalogDemoItemStatus.active,
      dataSource: BusinessCatalogDemoItemDataSource.demoSeed,
    ),
    BusinessCatalogDemoItem(
      itemId: kDemoCatalogItemDailyBasketId,
      businessScopeId: businessScopeId,
      categoryId: kDemoCatalogCategoryFreshGoodsId,
      kind: BusinessOfferingKind.product,
      status: BusinessCatalogDemoItemStatus.active,
      dataSource: BusinessCatalogDemoItemDataSource.demoSeed,
    ),
    BusinessCatalogDemoItem(
      itemId: kDemoCatalogItemPlovId,
      businessScopeId: businessScopeId,
      categoryId: kDemoCatalogCategoryReadyMealsId,
      kind: BusinessOfferingKind.product,
      status: BusinessCatalogDemoItemStatus.active,
      dataSource: BusinessCatalogDemoItemDataSource.demoSeed,
    ),
    BusinessCatalogDemoItem(
      itemId: kDemoCatalogItemPackingServiceId,
      businessScopeId: businessScopeId,
      categoryId: kDemoCatalogCategoryInStoreServicesId,
      kind: BusinessOfferingKind.service,
      status: BusinessCatalogDemoItemStatus.active,
      dataSource: BusinessCatalogDemoItemDataSource.demoSeed,
    ),
    BusinessCatalogDemoItem(
      itemId: kDemoCatalogItemDeliveryDraftId,
      businessScopeId: businessScopeId,
      categoryId: kDemoCatalogCategoryInStoreServicesId,
      kind: BusinessOfferingKind.service,
      status: BusinessCatalogDemoItemStatus.draft,
      dataSource: BusinessCatalogDemoItemDataSource.demoSeed,
    ),
  ];
}

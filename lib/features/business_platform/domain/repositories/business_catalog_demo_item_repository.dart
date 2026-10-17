import 'package:qoshni/features/business_platform/domain/business_catalog_demo_item.dart';

abstract class BusinessCatalogDemoItemRepository {
  String get businessScopeId;

  List<BusinessCatalogDemoItem> listForCurrentScope();

  int countItemsReferencingCategory(String categoryId);

  BusinessCatalogOverviewStats overviewStatsForScope({
    required int categoryCount,
  });
}

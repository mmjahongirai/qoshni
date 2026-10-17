import 'package:qoshni/features/business_platform/domain/business_catalog_service.dart';

enum BusinessCatalogServiceSaveResult {
  success,
  notFound,
  invalidCategory,
  invalidDuration,
  failure,
}

abstract class BusinessCatalogServiceRepository {
  String get businessScopeId;

  List<BusinessCatalogService> listForCurrentScope();

  BusinessCatalogService? findById(String serviceId);

  int countReferencingCategory(String categoryId);

  BusinessCatalogServiceSaveResult createService(
    BusinessCatalogServiceInput input,
  );

  BusinessCatalogServiceSaveResult updateService(
    String serviceId,
    BusinessCatalogServiceInput input,
  );
}

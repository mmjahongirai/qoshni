import 'package:qoshni/features/business_platform/domain/business_catalog_resource.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_resource_capacity_event.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_resource_status.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_resource_type.dart';

enum BusinessCatalogResourceSaveResult {
  success,
  notFound,
  invalidBranch,
  invalidService,
  invalidInput,
  invalidCapacity,
  failure,
}

enum BusinessCatalogResourceCapacityChangeResult {
  success,
  notFound,
  invalidCapacity,
  invalidReason,
  noChange,
  failure,
}

abstract class BusinessCatalogResourceRepository {
  String get businessScopeId;

  List<BusinessCatalogResource> listForCurrentScope({
    String? branchId,
    BusinessCatalogResourceType? type,
    BusinessCatalogResourceStatus? status,
    bool includeArchived = false,
  });

  BusinessCatalogResource? findById(String resourceId);

  BusinessCatalogResourceSaveResult createResource(
    BusinessCatalogResourceInput input,
  );

  BusinessCatalogResourceSaveResult updateResource(
    String resourceId,
    BusinessCatalogResourceInput input,
  );

  BusinessCatalogResourceSaveResult setStatus({
    required String resourceId,
    required BusinessCatalogResourceStatus status,
  });

  BusinessCatalogResourceCapacityChangeResult changeTotalCapacity({
    required String resourceId,
    required BusinessCatalogResourceCapacityChangeInput input,
  });

  List<BusinessCatalogResourceCapacityEvent> capacityHistory(String resourceId);
}

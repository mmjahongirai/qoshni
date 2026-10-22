import 'package:qoshni/features/business_platform/domain/business_catalog_localized_fields.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_product.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_resource_status.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_resource_type.dart';

class BusinessCatalogResource {
  const BusinessCatalogResource({
    required this.resourceId,
    required this.businessScopeId,
    required this.branchId,
    required this.dataSource,
    required this.type,
    required this.capacityUnit,
    required this.localized,
    required this.totalCapacity,
    required this.allocatedCapacity,
    required this.status,
    this.serviceId,
    this.productId,
    required this.createdAt,
    required this.updatedAt,
  });

  final String resourceId;
  final String businessScopeId;
  final String branchId;
  final BusinessCatalogProductDataSource dataSource;
  final BusinessCatalogResourceType type;
  final String capacityUnit;
  final BusinessCatalogLocalizedFields localized;
  final int totalCapacity;
  final int allocatedCapacity;
  final BusinessCatalogResourceStatus status;
  final String? serviceId;
  final String? productId;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isDemoSeed => dataSource == BusinessCatalogProductDataSource.demoSeed;

  int get availableCapacity {
    if (status == BusinessCatalogResourceStatus.manuallyUnavailable ||
        status == BusinessCatalogResourceStatus.archived) {
      return 0;
    }
    final raw = totalCapacity - allocatedCapacity;
    return raw < 0 ? 0 : raw;
  }

  BusinessCatalogResource copyWith({
    BusinessCatalogLocalizedFields? localized,
    int? totalCapacity,
    BusinessCatalogResourceStatus? status,
    DateTime? updatedAt,
  }) {
    return BusinessCatalogResource(
      resourceId: resourceId,
      businessScopeId: businessScopeId,
      branchId: branchId,
      dataSource: dataSource,
      type: type,
      capacityUnit: capacityUnit,
      localized: localized ?? this.localized,
      totalCapacity: totalCapacity ?? this.totalCapacity,
      allocatedCapacity: allocatedCapacity,
      status: status ?? this.status,
      serviceId: serviceId,
      productId: productId,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class BusinessCatalogResourceInput {
  const BusinessCatalogResourceInput({
    required this.branchId,
    required this.type,
    required this.capacityUnit,
    required this.localized,
    required this.totalCapacity,
    required this.status,
    this.serviceId,
    this.productId,
  });

  final String branchId;
  final BusinessCatalogResourceType type;
  final String capacityUnit;
  final BusinessCatalogLocalizedFields localized;
  final int totalCapacity;
  final BusinessCatalogResourceStatus status;
  final String? serviceId;
  final String? productId;
}

class BusinessCatalogResourceCapacityChangeInput {
  const BusinessCatalogResourceCapacityChangeInput({
    required this.newTotalCapacity,
    required this.reason,
  });

  final int newTotalCapacity;
  final String reason;
}

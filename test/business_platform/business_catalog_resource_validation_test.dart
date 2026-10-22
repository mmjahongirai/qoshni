import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_localized_fields.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_product.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_resource.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_resource_status.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_resource_type.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_resource_validation.dart';

void main() {
  test('quantities validation rejects negative and allocated over total', () {
    expect(
      catalogResourceQuantitiesValid(totalCapacity: -1, allocatedCapacity: 0),
      isFalse,
    );
    expect(
      catalogResourceQuantitiesValid(totalCapacity: 2, allocatedCapacity: 3),
      isFalse,
    );
  });

  test('capacity change below allocated fails validation', () {
    final resource = BusinessCatalogResource(
      resourceId: 'r1',
      businessScopeId: 'scope',
      branchId: 'branch',
      dataSource: BusinessCatalogProductDataSource.demoSeed,
      type: BusinessCatalogResourceType.equipment,
      capacityUnit: 'units',
      localized: const BusinessCatalogLocalizedFields(nameEn: 'Oven'),
      totalCapacity: 5,
      allocatedCapacity: 4,
      status: BusinessCatalogResourceStatus.active,
      createdAt: _epoch,
      updatedAt: _epoch,
    );
    expect(
      catalogResourceCapacityChangeValidationError(
        resource,
        const BusinessCatalogResourceCapacityChangeInput(
          newTotalCapacity: 3,
          reason: 'shrink',
        ),
      ),
      'below_allocated',
    );
  });
}

final _epoch = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

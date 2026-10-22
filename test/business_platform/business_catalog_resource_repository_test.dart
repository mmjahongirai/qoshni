import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/features/business_platform/data/business_catalog_resource_demo_seed.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_branch_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_catalog_category_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_catalog_resource_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_catalog_product_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_catalog_service_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_owner_profile_repository.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_localized_fields.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_resource.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_resource_status.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_resource_type.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_catalog_resource_repository.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_resource_validation.dart';
import 'package:qoshni/features/business_platform/data/business_catalog_inventory_demo_seed.dart';

void main() {
  late InMemoryBusinessOwnerProfileRepository ownerRepo;
  late InMemoryBusinessCatalogCategoryRepository categoryRepo;
  late InMemoryBusinessCatalogProductRepository productRepo;
  late InMemoryBusinessCatalogServiceRepository serviceRepo;
  late InMemoryBusinessBranchRepository branchRepo;
  late InMemoryBusinessCatalogResourceRepository resourceRepo;

  setUp(() {
    ownerRepo = InMemoryBusinessOwnerProfileRepository();
    categoryRepo = InMemoryBusinessCatalogCategoryRepository(ownerRepo);
    productRepo = InMemoryBusinessCatalogProductRepository(
      ownerRepo,
      categoryRepo,
    );
    serviceRepo = InMemoryBusinessCatalogServiceRepository(
      ownerRepo,
      categoryRepo,
    );
    categoryRepo.attachListingRepositories(
      productRepository: productRepo,
      serviceRepository: serviceRepo,
    );
    branchRepo = InMemoryBusinessBranchRepository(ownerRepo);
    resourceRepo = InMemoryBusinessCatalogResourceRepository(
      ownerRepo,
      branchRepo,
      serviceRepo,
    );
    ownerRepo.ensureSessionProfile();
  });

  test('demo resources have stable ids and branch scope', () {
    final items = resourceRepo.listForCurrentScope(includeArchived: true);
    expect(items.length, 4);
    for (final r in items) {
      expect(r.resourceId, startsWith('demo-catalog-resource-'));
      expect(r.businessScopeId, 'session-owner-profile-demo');
    }
    final oven = resourceRepo.findById(kDemoCatalogResourceOvenTashkentId)!;
    expect(oven.branchId, kDemoBranchTashkentCenterId);
  });

  test('available capacity formula and manually unavailable', () {
    final oven = resourceRepo.findById(kDemoCatalogResourceOvenTashkentId)!;
    expect(oven.availableCapacity, oven.totalCapacity - oven.allocatedCapacity);
    final room = resourceRepo.findById(kDemoCatalogResourceUnavailableRoomId)!;
    expect(room.availableCapacity, 0);
    expect(
      catalogResourceAvailableCapacity(
        totalCapacity: room.totalCapacity,
        allocatedCapacity: room.allocatedCapacity,
        countsAsActive: false,
      ),
      0,
    );
  });

  test('invalid capacity update rejected without mutation', () {
    final stylist = resourceRepo.findById(kDemoCatalogResourceStylistSamarkandId)!;
    final result = resourceRepo.changeTotalCapacity(
      resourceId: stylist.resourceId,
      input: const BusinessCatalogResourceCapacityChangeInput(
        newTotalCapacity: 1,
        reason: 'too low',
      ),
    );
    expect(result, BusinessCatalogResourceCapacityChangeResult.invalidCapacity);
    expect(
      resourceRepo.findById(stylist.resourceId)!.totalCapacity,
      stylist.totalCapacity,
    );
    expect(resourceRepo.capacityHistory(stylist.resourceId), isEmpty);
  });

  test('capacity change records history', () {
    final oven = resourceRepo.findById(kDemoCatalogResourceOvenTashkentId)!;
    expect(
      resourceRepo.changeTotalCapacity(
        resourceId: oven.resourceId,
        input: const BusinessCatalogResourceCapacityChangeInput(
          newTotalCapacity: 6,
          reason: 'Added oven',
        ),
      ),
      BusinessCatalogResourceCapacityChangeResult.success,
    );
    final history = resourceRepo.capacityHistory(oven.resourceId);
    expect(history.single.totalBefore, oven.totalCapacity);
    expect(history.single.totalAfter, 6);
    expect(history.single.reason, 'Added oven');
  });

  test('archived resource hidden from default list', () {
    final id = kDemoCatalogResourceOvenTashkentId;
    expect(
      resourceRepo.setStatus(
        resourceId: id,
        status: BusinessCatalogResourceStatus.archived,
      ),
      BusinessCatalogResourceSaveResult.success,
    );
    expect(resourceRepo.listForCurrentScope(), hasLength(3));
    expect(resourceRepo.findById(id)!.status.isArchived, isTrue);
  });

  test('type and status filters', () {
    final staff = resourceRepo.listForCurrentScope(
      type: BusinessCatalogResourceType.staff,
    );
    expect(staff.single.resourceId, kDemoCatalogResourceStylistSamarkandId);
    final unavailable = resourceRepo.listForCurrentScope(
      status: BusinessCatalogResourceStatus.manuallyUnavailable,
    );
    expect(unavailable.single.resourceId, kDemoCatalogResourceUnavailableRoomId);
  });

  test('create rejects invalid branch', () {
    const input = BusinessCatalogResourceInput(
      branchId: 'missing-branch',
      type: BusinessCatalogResourceType.equipment,
      capacityUnit: 'units',
      localized: BusinessCatalogLocalizedFields(nameEn: 'Test'),
      totalCapacity: 2,
      status: BusinessCatalogResourceStatus.active,
    );
    expect(
      resourceRepo.createResource(input),
      BusinessCatalogResourceSaveResult.invalidBranch,
    );
  });
}

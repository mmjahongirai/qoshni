import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/features/business_platform/data/business_fulfillment_demo_seed.dart';
import 'package:qoshni/features/business_platform/data/business_catalog_inventory_demo_seed.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_branch_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_catalog_category_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_fulfillment_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_catalog_product_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_catalog_service_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_owner_profile_repository.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_price_status.dart';
import 'package:qoshni/features/business_platform/domain/business_fulfillment_configuration.dart';
import 'package:qoshni/features/business_platform/domain/business_fulfillment_target_scope.dart';
import 'package:qoshni/features/business_platform/domain/business_fulfillment_type.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_fulfillment_repository.dart';

void main() {
  late InMemoryBusinessOwnerProfileRepository ownerRepo;
  late InMemoryBusinessCatalogCategoryRepository categoryRepo;
  late InMemoryBusinessCatalogProductRepository productRepo;
  late InMemoryBusinessCatalogServiceRepository serviceRepo;
  late InMemoryBusinessBranchRepository branchRepo;
  late InMemoryBusinessFulfillmentRepository fulfillmentRepo;

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
    fulfillmentRepo = InMemoryBusinessFulfillmentRepository(
      ownerRepo,
      branchRepo,
      productRepo,
      serviceRepo,
    );
  });

  test('seed includes delivery+pickup and service at location', () {
    final list = fulfillmentRepo.listForCurrentScope();
    expect(
      list.any((c) => c.configurationId == kDemoFulfillmentStoreDeliveryPickupId),
      isTrue,
    );
    expect(
      list.any((c) => c.configurationId == kDemoFulfillmentServiceAtLocationId),
      isTrue,
    );
  });

  test('activate conflict for duplicate business-wide target', () {
    final result = fulfillmentRepo.createDraft(
      BusinessFulfillmentConfigurationInput(
        branchId: kDemoBranchTashkentCenterId,
        targetScope: BusinessFulfillmentTargetScope.businessWide,
        supportedFulfillmentTypes: [BusinessFulfillmentType.pickup],
      ),
    );
    expect(result, BusinessFulfillmentSaveResult.success);
    final draft = fulfillmentRepo
        .listForCurrentScope(branchId: kDemoBranchTashkentCenterId)
        .lastWhere(
          (c) =>
              c.status == BusinessCatalogPriceStatus.draft &&
              c.targetScope == BusinessFulfillmentTargetScope.businessWide &&
              c.supportedFulfillmentTypes.length == 1 &&
              c.configurationId.startsWith('session-'),
        );
    final activate = fulfillmentRepo.activateConfiguration(draft.configurationId);
    expect(activate, BusinessFulfillmentStatusChangeResult.activeTargetConflict);
  });

  test('failNextSave does not mutate list', () {
    fulfillmentRepo.failNextSave = true;
    final before = fulfillmentRepo.listForCurrentScope().length;
    final result = fulfillmentRepo.createDraft(
      BusinessFulfillmentConfigurationInput(
        branchId: kDemoBranchTashkentCenterId,
        targetScope: BusinessFulfillmentTargetScope.businessWide,
        supportedFulfillmentTypes: [BusinessFulfillmentType.delivery],
      ),
    );
    expect(result, BusinessFulfillmentSaveResult.failure);
    expect(fulfillmentRepo.listForCurrentScope().length, before);
  });
}

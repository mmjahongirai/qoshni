import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/features/business_platform/data/business_catalog_inventory_demo_seed.dart';
import 'package:qoshni/features/business_platform/data/business_catalog_product_demo_seed.dart';
import 'package:qoshni/features/business_platform/data/business_catalog_product_variant_demo_seed.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_branch_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_catalog_category_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_catalog_inventory_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_catalog_product_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_catalog_product_variant_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_catalog_service_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_owner_profile_repository.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_inventory_adjustment.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_inventory_availability.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_catalog_inventory_repository.dart';

void main() {
  late InMemoryBusinessOwnerProfileRepository ownerRepo;
  late InMemoryBusinessCatalogCategoryRepository categoryRepo;
  late InMemoryBusinessCatalogProductRepository productRepo;
  late InMemoryBusinessCatalogServiceRepository serviceRepo;
  late InMemoryBusinessCatalogProductVariantRepository variantRepo;
  late InMemoryBusinessBranchRepository branchRepo;
  late InMemoryBusinessCatalogInventoryRepository inventoryRepo;

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
    variantRepo = InMemoryBusinessCatalogProductVariantRepository(
      ownerRepo,
      productRepo,
    );
    branchRepo = InMemoryBusinessBranchRepository(ownerRepo);
    inventoryRepo = InMemoryBusinessCatalogInventoryRepository(
      ownerRepo,
      productRepo,
      variantRepo,
      branchRepo,
    );
    ownerRepo.ensureSessionProfile();
  });

  test('demo inventory uses stable ids linked to catalog products and branches', () {
    final items = inventoryRepo.listForCurrentScope();
    expect(items.length, 4);
    final bread = inventoryRepo.findById(kDemoCatalogInventoryBreadTashkentId)!;
    expect(bread.productId, kDemoCatalogProductBreadId);
    expect(bread.variantId, kDemoCatalogVariantBreadStandardId);
    expect(bread.branchId, kDemoBranchTashkentCenterId);
    expect(bread.businessScopeId, 'session-owner-profile-demo');
    for (final id in items.map((i) => i.inventoryItemId)) {
      expect(id, startsWith('demo-catalog-inventory-'));
    }
  });

  test('invalid adjustment does not change item or history', () {
    final before = inventoryRepo.findById(kDemoCatalogInventoryBreadTashkentId)!;
    final result = inventoryRepo.applyAdjustment(
      inventoryItemId: before.inventoryItemId,
      input: const BusinessCatalogInventoryAdjustmentInput(
        kind: BusinessCatalogInventoryAdjustmentKind.onHandDelta,
        delta: -100,
        reason: 'bad',
      ),
    );
    expect(result, BusinessCatalogInventoryAdjustmentResult.invalidQuantities);
    final after = inventoryRepo.findById(before.inventoryItemId)!;
    expect(after.onHandQuantity, before.onHandQuantity);
    expect(inventoryRepo.adjustmentHistory(before.inventoryItemId), isEmpty);
  });

  test('valid adjustment updates quantities and appends history', () {
    final item = inventoryRepo.findById(kDemoCatalogInventoryBreadTashkentId)!;
    final result = inventoryRepo.applyAdjustment(
      inventoryItemId: item.inventoryItemId,
      input: const BusinessCatalogInventoryAdjustmentInput(
        kind: BusinessCatalogInventoryAdjustmentKind.onHandDelta,
        delta: 2,
        reason: 'Received shipment',
      ),
    );
    expect(result, BusinessCatalogInventoryAdjustmentResult.success);
    final updated = inventoryRepo.findById(item.inventoryItemId)!;
    expect(updated.onHandQuantity, item.onHandQuantity + 2);
    final history = inventoryRepo.adjustmentHistory(item.inventoryItemId);
    expect(history, hasLength(1));
    expect(history.single.onHandBefore, item.onHandQuantity);
    expect(history.single.onHandAfter, updated.onHandQuantity);
    expect(history.single.delta, 2);
    expect(history.single.reason, 'Received shipment');
    expect(history.single.eventId, isNotEmpty);
  });

  test('branch and availability filters', () {
    final samarkand = inventoryRepo.listForCurrentScope(
      branchId: kDemoBranchSamarkandId,
    );
    expect(samarkand.length, 2);
    final low = inventoryRepo.listForCurrentScope(
      availability: BusinessCatalogInventoryAvailability.lowStock,
    );
    expect(
      low.any((i) => i.inventoryItemId == kDemoCatalogInventoryBreadSamarkandLowId),
      isTrue,
    );
    final unavailable = inventoryRepo.listForCurrentScope(
      availability: BusinessCatalogInventoryAvailability.unavailable,
    );
    expect(unavailable.single.inventoryItemId, kDemoCatalogInventoryBasketUnavailableId);
  });

  test('manual unavailable differs from out of stock in availability filter', () {
    final out = inventoryRepo.listForCurrentScope(
      availability: BusinessCatalogInventoryAvailability.outOfStock,
    );
    expect(out.single.inventoryItemId, kDemoCatalogInventoryPlovOutId);
    final basket = inventoryRepo.findById(kDemoCatalogInventoryBasketUnavailableId)!;
    expect(basket.onHandQuantity, greaterThan(0));
    expect(
      inventoryRepo.listForCurrentScope(
        availability: BusinessCatalogInventoryAvailability.unavailable,
      ),
      hasLength(1),
    );
  });

  test('not found adjustment leaves repository unchanged', () {
    final countBefore = inventoryRepo.listForCurrentScope().length;
    expect(
      inventoryRepo.applyAdjustment(
        inventoryItemId: 'missing',
        input: const BusinessCatalogInventoryAdjustmentInput(
          kind: BusinessCatalogInventoryAdjustmentKind.onHandDelta,
          delta: 1,
          reason: 'x',
        ),
      ),
      BusinessCatalogInventoryAdjustmentResult.notFound,
    );
    expect(inventoryRepo.listForCurrentScope().length, countBefore);
  });
}

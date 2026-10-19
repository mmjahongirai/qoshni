import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/features/business_platform/data/business_catalog_inventory_demo_seed.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_branch_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_catalog_category_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_catalog_inventory_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_catalog_inventory_reservation_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_catalog_product_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_catalog_product_variant_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_catalog_service_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_owner_profile_repository.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_inventory_reservation.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_inventory_reservation_lifecycle_event.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_inventory_reservation_status.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_catalog_inventory_reservation_repository.dart';

void main() {
  late InMemoryBusinessOwnerProfileRepository ownerRepo;
  late InMemoryBusinessCatalogCategoryRepository categoryRepo;
  late InMemoryBusinessCatalogProductRepository productRepo;
  late InMemoryBusinessCatalogServiceRepository serviceRepo;
  late InMemoryBusinessCatalogProductVariantRepository variantRepo;
  late InMemoryBusinessBranchRepository branchRepo;
  late InMemoryBusinessCatalogInventoryRepository inventoryRepo;
  late InMemoryBusinessCatalogInventoryReservationRepository reservationRepo;

  final fixedNow = DateTime.utc(2026, 6, 1, 12, 0, 0);

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
    reservationRepo = InMemoryBusinessCatalogInventoryReservationRepository(
      ownerRepo,
      inventoryRepo,
      clock: () => fixedNow,
    );
    ownerRepo.ensureSessionProfile();
  });

  BusinessCatalogInventoryReservationInput reserveInput({
    int quantity = 2,
    Duration untilExpiry = const Duration(hours: 1),
  }) {
    return BusinessCatalogInventoryReservationInput(
      inventoryItemId: kDemoCatalogInventoryBreadTashkentId,
      quantity: quantity,
      expiresAt: fixedNow.add(untilExpiry),
    );
  }

  String reserveOne({int quantity = 2}) {
    expect(
      reservationRepo.reserve(input: reserveInput(quantity: quantity), now: fixedNow),
      BusinessCatalogInventoryReservationReserveResult.success,
    );
    return reservationRepo
        .listForCurrentScope(
          status: BusinessCatalogInventoryReservationStatus.reserved,
        )
        .last
        .reservationId;
  }

  test('reserve increases reserved quantity when stock available', () {
    final before = inventoryRepo.findById(kDemoCatalogInventoryBreadTashkentId)!;
    reserveOne(quantity: 4);
    final after = inventoryRepo.findById(kDemoCatalogInventoryBreadTashkentId)!;
    expect(after.reservedQuantity, before.reservedQuantity + 4);
    expect(after.onHandQuantity, before.onHandQuantity);
    expect(after.availableQuantity, before.availableQuantity - 4);
  });

  test('reserve rejected when insufficient available and state unchanged', () {
    final before = inventoryRepo.findById(kDemoCatalogInventoryBreadTashkentId)!;
    expect(
      reservationRepo.reserve(
        input: reserveInput(quantity: before.availableQuantity + 1),
        now: fixedNow,
      ),
      BusinessCatalogInventoryReservationReserveResult.insufficientAvailable,
    );
    expect(
      inventoryRepo.findById(kDemoCatalogInventoryBreadTashkentId)!.reservedQuantity,
      before.reservedQuantity,
    );
    expect(reservationRepo.listForCurrentScope(), isEmpty);
  });

  test('release returns reserved quantity to available pool', () {
    final before = inventoryRepo.findById(kDemoCatalogInventoryBreadTashkentId)!;
    final id = reserveOne(quantity: 3);
    expect(
      reservationRepo.release(reservationId: id, now: fixedNow),
      BusinessCatalogInventoryReservationReleaseResult.success,
    );
    final after = inventoryRepo.findById(kDemoCatalogInventoryBreadTashkentId)!;
    expect(after.reservedQuantity, before.reservedQuantity);
    expect(
      reservationRepo.findById(id)!.status,
      BusinessCatalogInventoryReservationStatus.released,
    );
  });

  test('confirm reduces on-hand and reserved for demo sale', () {
    final before = inventoryRepo.findById(kDemoCatalogInventoryBreadTashkentId)!;
    final id = reserveOne(quantity: 5);
    expect(
      reservationRepo.confirm(reservationId: id, now: fixedNow),
      BusinessCatalogInventoryReservationConfirmResult.success,
    );
    final after = inventoryRepo.findById(kDemoCatalogInventoryBreadTashkentId)!;
    expect(after.onHandQuantity, before.onHandQuantity - 5);
    expect(after.reservedQuantity, before.reservedQuantity);
    expect(after.availableQuantity, after.onHandQuantity - after.reservedQuantity);
  });

  test('repeat release and confirm are idempotent for stock', () {
    final before = inventoryRepo.findById(kDemoCatalogInventoryBreadTashkentId)!;
    final id = reserveOne(quantity: 2);
    expect(
      reservationRepo.release(reservationId: id, now: fixedNow),
      BusinessCatalogInventoryReservationReleaseResult.success,
    );
    expect(
      reservationRepo.release(reservationId: id, now: fixedNow),
      BusinessCatalogInventoryReservationReleaseResult.idempotentReplay,
    );
    expect(
      inventoryRepo.findById(kDemoCatalogInventoryBreadTashkentId)!.reservedQuantity,
      before.reservedQuantity,
    );

    final id2 = reserveOne(quantity: 2);
    reservationRepo.confirm(reservationId: id2, now: fixedNow);
    final mid = inventoryRepo.findById(kDemoCatalogInventoryBreadTashkentId)!;
    expect(
      reservationRepo.confirm(reservationId: id2, now: fixedNow),
      BusinessCatalogInventoryReservationConfirmResult.idempotentReplay,
    );
    expect(inventoryRepo.findById(kDemoCatalogInventoryBreadTashkentId)!, mid);
  });

  test('expire at boundary when expiresAt equals now', () {
    final expiresAt = fixedNow.add(const Duration(minutes: 30));
    final baseline = inventoryRepo.findById(kDemoCatalogInventoryBreadTashkentId)!;
    expect(
      reservationRepo.reserve(
        input: BusinessCatalogInventoryReservationInput(
          inventoryItemId: kDemoCatalogInventoryBreadTashkentId,
          quantity: 1,
          expiresAt: expiresAt,
        ),
        now: fixedNow,
      ),
      BusinessCatalogInventoryReservationReserveResult.success,
    );
    final id = reservationRepo.listForCurrentScope().single.reservationId;
    expect(
      reservationRepo.expireReservation(reservationId: id, now: expiresAt),
      BusinessCatalogInventoryReservationExpireResult.success,
    );
    expect(
      inventoryRepo.findById(kDemoCatalogInventoryBreadTashkentId)!.reservedQuantity,
      baseline.reservedQuantity,
    );
    expect(
      reservationRepo.findById(id)!.status,
      BusinessCatalogInventoryReservationStatus.expired,
    );
  });

  test('expired reservation cannot be confirmed', () {
    final expiresAt = fixedNow.add(const Duration(minutes: 10));
    expect(
      reservationRepo.reserve(
        input: BusinessCatalogInventoryReservationInput(
          inventoryItemId: kDemoCatalogInventoryBreadTashkentId,
          quantity: 1,
          expiresAt: expiresAt,
        ),
        now: fixedNow,
      ),
      BusinessCatalogInventoryReservationReserveResult.success,
    );
    final id = reservationRepo.listForCurrentScope().single.reservationId;
    expect(
      reservationRepo.expireReservation(reservationId: id, now: expiresAt),
      BusinessCatalogInventoryReservationExpireResult.success,
    );
    expect(
      reservationRepo.confirm(reservationId: id, now: expiresAt),
      BusinessCatalogInventoryReservationConfirmResult.invalidTransition,
    );
  });

  test('confirm rejected when past expiry without manual expire', () {
    expect(
      reservationRepo.reserve(input: reserveInput(quantity: 1), now: fixedNow),
      BusinessCatalogInventoryReservationReserveResult.success,
    );
    final id = reservationRepo.listForCurrentScope().single.reservationId;
    expect(
      reservationRepo.confirm(
        reservationId: id,
        now: fixedNow.add(const Duration(hours: 2)),
      ),
      BusinessCatalogInventoryReservationConfirmResult.expired,
    );
  });

  test('lifecycle history records status and quantity', () {
    final id = reserveOne(quantity: 2);
    reservationRepo.release(reservationId: id, now: fixedNow);
    final history = reservationRepo.lifecycleHistory(id);
    expect(history, hasLength(2));
    expect(history.first.action, BusinessCatalogInventoryReservationLifecycleAction.reserve);
    expect(history.last.action, BusinessCatalogInventoryReservationLifecycleAction.release);
    expect(history.last.quantity, 2);
    expect(history.last.statusAfter, BusinessCatalogInventoryReservationStatus.released);
  });

  test('reconciliation detects mismatch without changing stock', () {
    reserveOne(quantity: 2);
    final before = inventoryRepo.findById(kDemoCatalogInventoryBreadTashkentId)!;
    inventoryRepo.setQuantitiesForLifecycle(
      inventoryItemId: before.inventoryItemId,
      onHandQuantity: before.onHandQuantity,
      reservedQuantity: before.reservedQuantity + 1,
    );
    final report = reservationRepo.reconcileReservedQuantities(now: fixedNow);
    expect(report.isDemoAuditOnly, isTrue);
    expect(report.hasDiscrepancies, isTrue);
    expect(
      inventoryRepo.findById(before.inventoryItemId)!.reservedQuantity,
      before.reservedQuantity + 1,
    );
  });

  test('unavailable inventory item cannot be reserved', () {
    expect(
      reservationRepo.reserve(
        input: BusinessCatalogInventoryReservationInput(
          inventoryItemId: kDemoCatalogInventoryBasketUnavailableId,
          quantity: 1,
          expiresAt: fixedNow.add(const Duration(hours: 1)),
        ),
        now: fixedNow,
      ),
      BusinessCatalogInventoryReservationReserveResult.itemUnavailable,
    );
  });

  test('invalid reserve leaves no reservation rows', () {
    expect(
      reservationRepo.reserve(
        input: BusinessCatalogInventoryReservationInput(
          inventoryItemId: 'missing-item',
          quantity: 1,
          expiresAt: fixedNow.add(const Duration(hours: 1)),
        ),
        now: fixedNow,
      ),
      BusinessCatalogInventoryReservationReserveResult.notFound,
    );
    expect(reservationRepo.listForCurrentScope(), isEmpty);
  });
}

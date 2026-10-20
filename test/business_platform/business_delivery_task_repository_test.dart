import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/features/business_platform/data/business_catalog_inventory_demo_seed.dart';
import 'package:qoshni/features/business_platform/data/business_delivery_task_demo_seed.dart';
import 'package:qoshni/features/business_platform/data/business_fulfillment_demo_seed.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_branch_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_catalog_category_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_delivery_task_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_fulfillment_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_catalog_product_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_catalog_service_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_owner_profile_repository.dart';
import 'package:qoshni/features/business_platform/domain/business_delivery_task.dart';
import 'package:qoshni/features/business_platform/domain/business_delivery_task_status.dart';
import 'package:qoshni/features/business_platform/domain/business_fulfillment_type.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_delivery_task_repository.dart';

void main() {
  late InMemoryBusinessOwnerProfileRepository ownerRepo;
  late InMemoryBusinessCatalogCategoryRepository categoryRepo;
  late InMemoryBusinessCatalogProductRepository productRepo;
  late InMemoryBusinessCatalogServiceRepository serviceRepo;
  late InMemoryBusinessBranchRepository branchRepo;
  late InMemoryBusinessFulfillmentRepository fulfillmentRepo;
  late InMemoryBusinessDeliveryTaskRepository taskRepo;

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
    taskRepo = InMemoryBusinessDeliveryTaskRepository(
      ownerRepo,
      branchRepo,
      fulfillmentRepo,
    );
  });

  test('seed tasks have stable ids and delivery fulfillment type', () {
    final list = taskRepo.listForCurrentScope();
    expect(list.any((t) => t.deliveryTaskId == kDemoDeliveryTaskCreatedId), isTrue);
    expect(list.every((t) => t.fulfillmentType == BusinessFulfillmentType.delivery), isTrue);
    expect(
      list.every((t) => t.businessScopeId == taskRepo.businessScopeId),
      isTrue,
    );
  });

  test('rejects non-delivery fulfillment type on create', () {
    final result = taskRepo.createDemoTask(
      BusinessDeliveryTaskCreateInput(
        branchId: kDemoBranchTashkentCenterId,
        fulfillmentType: BusinessFulfillmentType.pickup,
        demoPickupLabel: 'Demo pickup — Branch A',
        demoDropOffLabel: 'Demo drop-off — Task X',
      ),
    );
    expect(result, BusinessDeliveryTaskCreateResult.nonDeliveryFulfillmentType);
  });

  test('branch and status filters', () {
    final tashkent = taskRepo.listForCurrentScope(
      branchId: kDemoBranchTashkentCenterId,
    );
    expect(tashkent.every((t) => t.branchId == kDemoBranchTashkentCenterId), isTrue);
    final inTransit = taskRepo.listForCurrentScope(
      status: BusinessDeliveryTaskStatus.inTransit,
    );
    expect(inTransit.length, 1);
    expect(inTransit.single.deliveryTaskId, kDemoDeliveryTaskInTransitId);
  });

  test('full happy path transition updates timestamps and history', () {
    final id = kDemoDeliveryTaskCreatedId;
    final before = taskRepo.findById(id)!;
    final historyBefore = taskRepo.taskHistory(id).length;

    expect(
      taskRepo.applyTransition(
        deliveryTaskId: id,
        request: const BusinessDeliveryTaskTransitionRequest(
          targetStatus: BusinessDeliveryTaskStatus.readyForPickup,
        ),
      ),
      BusinessDeliveryTaskTransitionResult.success,
    );

    final after = taskRepo.findById(id)!;
    expect(after.status, BusinessDeliveryTaskStatus.readyForPickup);
    expect(after.updatedAt.isAfter(before.updatedAt), isTrue);
    expect(taskRepo.taskHistory(id).length, historyBefore + 1);
  });

  test('duplicate transition does not append history', () {
    final id = kDemoDeliveryTaskReadyId;
    final len = taskRepo.taskHistory(id).length;
    expect(
      taskRepo.applyTransition(
        deliveryTaskId: id,
        request: const BusinessDeliveryTaskTransitionRequest(
          targetStatus: BusinessDeliveryTaskStatus.readyForPickup,
        ),
      ),
      BusinessDeliveryTaskTransitionResult.duplicateStatus,
    );
    expect(taskRepo.taskHistory(id).length, len);
  });

  test('terminal delivered cannot transition', () {
    expect(
      taskRepo.applyTransition(
        deliveryTaskId: kDemoDeliveryTaskDeliveredId,
        request: const BusinessDeliveryTaskTransitionRequest(
          targetStatus: BusinessDeliveryTaskStatus.failed,
        ),
      ),
      BusinessDeliveryTaskTransitionResult.terminalTask,
    );
  });

  test('in transit cannot cancel', () {
    expect(
      taskRepo.applyTransition(
        deliveryTaskId: kDemoDeliveryTaskInTransitId,
        request: const BusinessDeliveryTaskTransitionRequest(
          targetStatus: BusinessDeliveryTaskStatus.cancelled,
        ),
      ),
      BusinessDeliveryTaskTransitionResult.invalidTransition,
    );
  });

  test('failed requires reason and supports retry', () {
    expect(
      taskRepo.applyTransition(
        deliveryTaskId: kDemoDeliveryTaskAssignedId,
        request: const BusinessDeliveryTaskTransitionRequest(
          targetStatus: BusinessDeliveryTaskStatus.failed,
        ),
      ),
      BusinessDeliveryTaskTransitionResult.failureReasonRequired,
    );

    expect(
      taskRepo.applyTransition(
        deliveryTaskId: kDemoDeliveryTaskAssignedId,
        request: const BusinessDeliveryTaskTransitionRequest(
          targetStatus: BusinessDeliveryTaskStatus.failed,
          failureReason: 'Demo delay',
        ),
      ),
      BusinessDeliveryTaskTransitionResult.success,
    );

    expect(
      taskRepo.applyTransition(
        deliveryTaskId: kDemoDeliveryTaskFailedId,
        request: const BusinessDeliveryTaskTransitionRequest(
          targetStatus: BusinessDeliveryTaskStatus.readyForPickup,
        ),
      ),
      BusinessDeliveryTaskTransitionResult.success,
    );
    final retried = taskRepo.findById(kDemoDeliveryTaskFailedId)!;
    expect(retried.status, BusinessDeliveryTaskStatus.readyForPickup);
    expect(retried.failureReason, isNull);
  });

  test('failNextSave leaves task and history unchanged', () {
    final id = kDemoDeliveryTaskCreatedId;
    final before = taskRepo.findById(id)!;
    final historyLen = taskRepo.taskHistory(id).length;
    taskRepo.failNextSave = true;
    expect(
      taskRepo.applyTransition(
        deliveryTaskId: id,
        request: const BusinessDeliveryTaskTransitionRequest(
          targetStatus: BusinessDeliveryTaskStatus.readyForPickup,
        ),
      ),
      BusinessDeliveryTaskTransitionResult.failure,
    );
    final after = taskRepo.findById(id)!;
    expect(after.status, before.status);
    expect(after.updatedAt, before.updatedAt);
    expect(taskRepo.taskHistory(id).length, historyLen);
  });

  test('create links fulfillment configuration when delivery supported', () {
    final result = taskRepo.createDemoTask(
      const BusinessDeliveryTaskCreateInput(
        branchId: kDemoBranchTashkentCenterId,
        fulfillmentConfigurationId: kDemoFulfillmentStoreDeliveryPickupId,
        demoPickupLabel: 'Demo pickup — Branch A',
        demoDropOffLabel: 'Demo drop-off — Task 999',
      ),
    );
    expect(result, BusinessDeliveryTaskCreateResult.success);
    final created = taskRepo
        .listForCurrentScope()
        .lastWhere((t) => t.demoDropOffLabel.contains('999'));
    expect(created.fulfillmentConfigurationId, kDemoFulfillmentStoreDeliveryPickupId);
  });
}

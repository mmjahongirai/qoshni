import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/features/business_platform/data/business_delivery_exception_demo_seed.dart';
import 'package:qoshni/features/business_platform/data/business_delivery_task_demo_seed.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_branch_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_catalog_category_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_delivery_exception_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_delivery_task_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_fulfillment_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_catalog_product_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_catalog_service_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_owner_profile_repository.dart';
import 'package:qoshni/features/business_platform/domain/business_delivery_exception.dart';
import 'package:qoshni/features/business_platform/domain/business_delivery_exception_category.dart';
import 'package:qoshni/features/business_platform/domain/business_delivery_exception_status.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_delivery_exception_repository.dart';

void main() {
  late InMemoryBusinessOwnerProfileRepository ownerRepo;
  late InMemoryBusinessCatalogCategoryRepository categoryRepo;
  late InMemoryBusinessCatalogProductRepository productRepo;
  late InMemoryBusinessCatalogServiceRepository serviceRepo;
  late InMemoryBusinessBranchRepository branchRepo;
  late InMemoryBusinessFulfillmentRepository fulfillmentRepo;
  late InMemoryBusinessDeliveryTaskRepository taskRepo;
  late InMemoryBusinessDeliveryExceptionRepository exceptionRepo;

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
    exceptionRepo = InMemoryBusinessDeliveryExceptionRepository(
      ownerRepo,
      taskRepo,
    );
  });

  test('seed exception linked to delivery task scope', () {
    final ex = exceptionRepo.findById(kDemoDeliveryExceptionOpenId)!;
    expect(ex.deliveryTaskId, kDemoDeliveryTaskInTransitId);
    expect(ex.businessScopeId, exceptionRepo.businessScopeId);
  });

  test('empty reason rejected', () {
    expect(
      exceptionRepo.createException(
        const BusinessDeliveryExceptionCreateInput(
          deliveryTaskId: kDemoDeliveryTaskCreatedId,
          category: BusinessDeliveryExceptionCategory.other,
          reason: '   ',
        ),
      ),
      BusinessDeliveryExceptionCreateResult.invalidReason,
    );
  });

  test('open to resolved requires resolution note', () {
    expect(
      exceptionRepo.applyTransition(
        exceptionId: kDemoDeliveryExceptionOpenId,
        request: const BusinessDeliveryExceptionTransitionRequest(
          targetStatus: BusinessDeliveryExceptionStatus.resolved,
        ),
      ),
      BusinessDeliveryExceptionTransitionResult.resolutionNoteRequired,
    );
  });

  test('open to resolved and dismissed', () {
    expect(
      exceptionRepo.applyTransition(
        exceptionId: kDemoDeliveryExceptionOpenId,
        request: const BusinessDeliveryExceptionTransitionRequest(
          targetStatus: BusinessDeliveryExceptionStatus.resolved,
          resolutionNote: 'Demo resolution note',
        ),
      ),
      BusinessDeliveryExceptionTransitionResult.success,
    );

    final created = exceptionRepo.createException(
      const BusinessDeliveryExceptionCreateInput(
        deliveryTaskId: kDemoDeliveryTaskReadyId,
        category: BusinessDeliveryExceptionCategory.accessBlocked,
        reason: 'Demo gate closed',
      ),
    );
    expect(created, BusinessDeliveryExceptionCreateResult.success);
    final open = exceptionRepo
        .listForCurrentScope(deliveryTaskId: kDemoDeliveryTaskReadyId)
        .lastWhere((e) => e.reason.contains('gate'));
    expect(
      exceptionRepo.applyTransition(
        exceptionId: open.exceptionId,
        request: const BusinessDeliveryExceptionTransitionRequest(
          targetStatus: BusinessDeliveryExceptionStatus.dismissed,
        ),
      ),
      BusinessDeliveryExceptionTransitionResult.success,
    );
  });

  test('terminal resolved cannot resolve again', () {
    expect(
      exceptionRepo.applyTransition(
        exceptionId: kDemoDeliveryExceptionResolvedId,
        request: const BusinessDeliveryExceptionTransitionRequest(
          targetStatus: BusinessDeliveryExceptionStatus.resolved,
          resolutionNote: 'Again',
        ),
      ),
      BusinessDeliveryExceptionTransitionResult.duplicateStatus,
    );
  });

  test('reopen resolved exception', () {
    expect(
      exceptionRepo.applyTransition(
        exceptionId: kDemoDeliveryExceptionResolvedId,
        request: const BusinessDeliveryExceptionTransitionRequest(
          targetStatus: BusinessDeliveryExceptionStatus.open,
          reopenNote: 'Demo reopen',
        ),
      ),
      BusinessDeliveryExceptionTransitionResult.success,
    );
  });

  test('failNextSave on create', () {
    exceptionRepo.failNextSave = true;
    final before = exceptionRepo.listForCurrentScope().length;
    expect(
      exceptionRepo.createException(
        const BusinessDeliveryExceptionCreateInput(
          deliveryTaskId: kDemoDeliveryTaskCreatedId,
          category: BusinessDeliveryExceptionCategory.other,
          reason: 'Demo note',
        ),
      ),
      BusinessDeliveryExceptionCreateResult.failure,
    );
    expect(exceptionRepo.listForCurrentScope().length, before);
  });

  test('unknown task rejected', () {
    expect(
      exceptionRepo.createException(
        const BusinessDeliveryExceptionCreateInput(
          deliveryTaskId: 'missing-task',
          category: BusinessDeliveryExceptionCategory.other,
          reason: 'Demo',
        ),
      ),
      BusinessDeliveryExceptionCreateResult.taskNotFound,
    );
  });
}

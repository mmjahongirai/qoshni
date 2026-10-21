import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/features/business_platform/data/business_delivery_proof_demo_seed.dart';
import 'package:qoshni/features/business_platform/data/business_delivery_task_demo_seed.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_branch_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_catalog_category_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_delivery_proof_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_delivery_task_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_fulfillment_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_catalog_product_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_catalog_service_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_owner_profile_repository.dart';
import 'package:qoshni/features/business_platform/domain/business_delivery_proof_method.dart';
import 'package:qoshni/features/business_platform/domain/business_delivery_proof_of_delivery.dart';
import 'package:qoshni/features/business_platform/domain/business_delivery_proof_status.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_delivery_proof_repository.dart';
import 'package:qoshni/features/business_platform/presentation/business_delivery_proof_validation.dart';

void main() {
  late InMemoryBusinessOwnerProfileRepository ownerRepo;
  late InMemoryBusinessCatalogCategoryRepository categoryRepo;
  late InMemoryBusinessCatalogProductRepository productRepo;
  late InMemoryBusinessCatalogServiceRepository serviceRepo;
  late InMemoryBusinessBranchRepository branchRepo;
  late InMemoryBusinessFulfillmentRepository fulfillmentRepo;
  late InMemoryBusinessDeliveryTaskRepository taskRepo;
  late InMemoryBusinessDeliveryProofRepository proofRepo;

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
    proofRepo = InMemoryBusinessDeliveryProofRepository(
      ownerRepo,
      taskRepo,
    );
  });

  test('seed includes all proof methods and delivered link', () {
    final all = proofRepo.listForCurrentScope();
    expect(all.any((p) => p.proofId == kDemoDeliveryProofDeliveredVerifiedId), isTrue);
    for (final method in BusinessDeliveryProofMethod.values) {
      expect(all.any((p) => p.method == method), isTrue);
    }
  });

  test('rejects otp-like evidence reference', () {
    expect(
      catalogDeliveryProofEvidenceValidationError('123456'),
      isNotNull,
    );
    expect(
      proofRepo.createProof(
        const BusinessDeliveryProofCreateInput(
          deliveryTaskId: kDemoDeliveryTaskInTransitId,
          method: BusinessDeliveryProofMethod.recipientOtp,
          demoEvidenceReference: '123456',
          description: 'Demo',
        ),
      ),
      BusinessDeliveryProofCreateResult.invalidEvidence,
    );
  });

  test('rejects url-like evidence', () {
    expect(
      proofRepo.createProof(
        BusinessDeliveryProofCreateInput(
          deliveryTaskId: kDemoDeliveryTaskInTransitId,
          method: BusinessDeliveryProofMethod.photo,
          demoEvidenceReference: 'https://cdn.example/photo.jpg',
          description: 'Demo',
        ),
      ),
      BusinessDeliveryProofCreateResult.invalidEvidence,
    );
  });

  test('failNextSave leaves proof unchanged', () {
    final before = proofRepo.findById(kDemoDeliveryProofPhotoPendingId)!;
    final historyLen = proofRepo.proofHistory(before.proofId).length;
    proofRepo.failNextSave = true;
    expect(
      proofRepo.applyTransition(
        proofId: before.proofId,
        request: const BusinessDeliveryProofTransitionRequest(
          targetStatus: BusinessDeliveryProofStatus.rejected,
        ),
      ),
      BusinessDeliveryProofTransitionResult.failure,
    );
    final after = proofRepo.findById(before.proofId)!;
    expect(after.status, before.status);
    expect(proofRepo.proofHistory(before.proofId).length, historyLen);
  });

  test('pending to verified and rejected', () {
    expect(
      proofRepo.applyTransition(
        proofId: kDemoDeliveryProofPhotoPendingId,
        request: const BusinessDeliveryProofTransitionRequest(
          targetStatus: BusinessDeliveryProofStatus.verified,
          demoVerificationReason: 'Demo OK',
        ),
      ),
      BusinessDeliveryProofTransitionResult.success,
    );

    final pending = proofRepo.createProof(
      const BusinessDeliveryProofCreateInput(
        deliveryTaskId: kDemoDeliveryTaskInTransitId,
        method: BusinessDeliveryProofMethod.signature,
        demoEvidenceReference: 'demo-evidence-signature-slot',
        description: 'Demo signature metadata',
      ),
    );
    expect(pending, BusinessDeliveryProofCreateResult.success);
    final created = proofRepo
        .listForCurrentScope(deliveryTaskId: kDemoDeliveryTaskInTransitId)
        .lastWhere((p) => p.demoEvidenceReference.contains('signature-slot'));
    expect(
      proofRepo.applyTransition(
        proofId: created.proofId,
        request: const BusinessDeliveryProofTransitionRequest(
          targetStatus: BusinessDeliveryProofStatus.rejected,
          demoVerificationReason: 'Demo incomplete',
        ),
      ),
      BusinessDeliveryProofTransitionResult.success,
    );
  });

  test('duplicate verify does not append history', () {
    final len = proofRepo.proofHistory(kDemoDeliveryProofOtpVerifiedId).length;
    expect(
      proofRepo.applyTransition(
        proofId: kDemoDeliveryProofOtpVerifiedId,
        request: const BusinessDeliveryProofTransitionRequest(
          targetStatus: BusinessDeliveryProofStatus.verified,
        ),
      ),
      BusinessDeliveryProofTransitionResult.duplicateStatus,
    );
    expect(proofRepo.proofHistory(kDemoDeliveryProofOtpVerifiedId).length, len);
  });

  test('verified cannot transition to pending', () {
    expect(
      proofRepo.applyTransition(
        proofId: kDemoDeliveryProofDeliveredVerifiedId,
        request: const BusinessDeliveryProofTransitionRequest(
          targetStatus: BusinessDeliveryProofStatus.pending,
        ),
      ),
      BusinessDeliveryProofTransitionResult.invalidTransition,
    );
  });

}

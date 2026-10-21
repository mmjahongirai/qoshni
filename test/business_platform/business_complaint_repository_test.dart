import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/features/business_platform/data/business_catalog_product_demo_seed.dart';
import 'package:qoshni/features/business_platform/data/business_complaint_demo_evidence.dart';
import 'package:qoshni/features/business_platform/data/business_complaint_dispute_demo_seed.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_complaint_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_owner_profile_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_review_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_demo_review_transaction_eligibility_provider.dart';
import 'package:qoshni/features/business_platform/domain/business_complaint.dart';
import 'package:qoshni/features/business_platform/domain/business_complaint_category.dart';
import 'package:qoshni/features/business_platform/domain/business_complaint_status.dart';
import 'package:qoshni/features/business_platform/domain/business_review_target_type.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_complaint_repository.dart';
import 'package:qoshni/features/business_platform/presentation/business_complaint_validation.dart';

void main() {
  late InMemoryBusinessOwnerProfileRepository ownerRepo;
  late InMemoryBusinessComplaintRepository complaintRepo;

  setUp(() {
    ownerRepo = InMemoryBusinessOwnerProfileRepository();
    final reviewRepo = InMemoryBusinessReviewRepository(
      ownerRepo,
      InMemoryDemoReviewTransactionEligibilityProvider(ownerRepo),
    );
    complaintRepo = InMemoryBusinessComplaintRepository(ownerRepo, reviewRepo);
  });

  test('demo seed includes representative complaint statuses', () {
    final list = complaintRepo.listForCurrentScope();
    expect(
      list.map((c) => c.status).toSet(),
      containsAll([
        BusinessComplaintStatus.submitted,
        BusinessComplaintStatus.underReview,
        BusinessComplaintStatus.resolved,
        BusinessComplaintStatus.dismissed,
      ]),
    );
  });

  test('creates complaint with synthetic evidence only', () {
    final result = complaintRepo.createComplaint(
      const BusinessComplaintCreateInput(
        targetType: BusinessReviewTargetType.product,
        targetId: kDemoCatalogProductBreadId,
        demoReporterReference: kDemoComplaintReporterA,
        category: BusinessComplaintCategory.productQuality,
        description: 'Demo complaint body',
        syntheticEvidenceReferences: [kDemoComplaintEvidenceSessionCreate],
      ),
    );
    expect(result, BusinessComplaintCreateResult.success);
    final created = complaintRepo.listForCurrentScope().lastWhere(
          (c) => c.description == 'Demo complaint body',
        );
    expect(created.isSyntheticDemo, isTrue);
    expect(
      catalogBusinessComplaintSyntheticEvidenceAllowed(
        created.syntheticEvidenceReferences.first,
      ),
      isTrue,
    );
  });

  test('rejects non-synthetic evidence prefix', () {
    expect(
      complaintRepo.createComplaint(
        const BusinessComplaintCreateInput(
          targetType: BusinessReviewTargetType.product,
          targetId: kDemoCatalogProductBreadId,
          demoReporterReference: kDemoComplaintReporterA,
          category: BusinessComplaintCategory.other,
          description: 'Bad evidence',
          syntheticEvidenceReferences: ['real-order-12345'],
        ),
      ),
      BusinessComplaintCreateResult.invalidEvidence,
    );
  });

  test('valid complaint status transitions', () {
    final id = kDemoComplaintSubmittedId;
    final before = complaintRepo.findById(id)!;
    expect(
      complaintRepo.applyTransition(
        complaintId: id,
        request: const BusinessComplaintTransitionRequest(
          targetStatus: BusinessComplaintStatus.underReview,
        ),
      ),
      BusinessComplaintTransitionResult.success,
    );
    expect(
      complaintRepo.findById(id)!.status,
      BusinessComplaintStatus.underReview,
    );
    expect(complaintRepo.complaintHistory(id).length, greaterThan(1));
    expect(before.status, isNot(complaintRepo.findById(id)!.status));
  });

  test('invalid transition does not mutate complaint or history', () {
    final id = kDemoComplaintResolvedId;
    final before = complaintRepo.findById(id)!;
    final historyLen = complaintRepo.complaintHistory(id).length;
    expect(
      complaintRepo.applyTransition(
        complaintId: id,
        request: const BusinessComplaintTransitionRequest(
          targetStatus: BusinessComplaintStatus.submitted,
        ),
      ),
      BusinessComplaintTransitionResult.invalidTransition,
    );
    expect(complaintRepo.findById(id), before);
    expect(complaintRepo.complaintHistory(id).length, historyLen);
  });

  test('failNextSave leaves state unchanged', () {
    complaintRepo.failNextSave = true;
    final id = kDemoComplaintSubmittedId;
    final before = complaintRepo.findById(id)!;
    final historyLen = complaintRepo.complaintHistory(id).length;
    expect(
      complaintRepo.applyTransition(
        complaintId: id,
        request: const BusinessComplaintTransitionRequest(
          targetStatus: BusinessComplaintStatus.underReview,
        ),
      ),
      BusinessComplaintTransitionResult.failure,
    );
    expect(complaintRepo.findById(id), before);
    expect(complaintRepo.complaintHistory(id).length, historyLen);
  });
}

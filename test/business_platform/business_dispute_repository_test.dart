import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/features/business_platform/data/business_complaint_demo_evidence.dart';
import 'package:qoshni/features/business_platform/data/business_complaint_dispute_demo_seed.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_complaint_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_dispute_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_owner_profile_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_review_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_demo_review_transaction_eligibility_provider.dart';
import 'package:qoshni/features/business_platform/domain/business_dispute.dart';
import 'package:qoshni/features/business_platform/domain/business_dispute_status.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_dispute_repository.dart';

void main() {
  late InMemoryBusinessOwnerProfileRepository ownerRepo;
  late InMemoryBusinessComplaintRepository complaintRepo;
  late InMemoryBusinessDisputeRepository disputeRepo;

  setUp(() {
    ownerRepo = InMemoryBusinessOwnerProfileRepository();
    final reviewRepo = InMemoryBusinessReviewRepository(
      ownerRepo,
      InMemoryDemoReviewTransactionEligibilityProvider(ownerRepo),
    );
    complaintRepo = InMemoryBusinessComplaintRepository(ownerRepo, reviewRepo);
    disputeRepo = InMemoryBusinessDisputeRepository(ownerRepo, complaintRepo);
  });

  test('finds dispute linked to demo complaint', () {
    final linked = disputeRepo.findByComplaintId(kDemoComplaintWithDisputeId);
    expect(linked, isNotNull);
    expect(linked!.complaintId, kDemoComplaintWithDisputeId);
    expect(linked.isSyntheticDemo, isTrue);
  });

  test('rejects duplicate dispute for same complaint', () {
    expect(
      disputeRepo.createDispute(
        const BusinessDisputeCreateInput(
          complaintId: kDemoComplaintWithDisputeId,
          demoBusinessInitiatorReference: kDemoDisputeBusinessInitiator,
          summary: 'Duplicate attempt',
          syntheticEvidenceReferences: [kDemoDisputeEvidenceSessionCreate],
        ),
      ),
      BusinessDisputeCreateResult.duplicateForComplaint,
    );
  });

  test('creates dispute for eligible complaint without existing dispute', () {
    expect(
      disputeRepo.createDispute(
        const BusinessDisputeCreateInput(
          complaintId: kDemoComplaintSubmittedId,
          demoBusinessInitiatorReference: kDemoDisputeBusinessInitiator,
          summary: 'New demo dispute',
          syntheticEvidenceReferences: [kDemoDisputeEvidenceSessionCreate],
        ),
      ),
      BusinessDisputeCreateResult.success,
    );
    expect(disputeRepo.findByComplaintId(kDemoComplaintSubmittedId), isNotNull);
  });

  test('rejects dispute for dismissed complaint', () {
    expect(
      disputeRepo.createDispute(
        const BusinessDisputeCreateInput(
          complaintId: kDemoComplaintDismissedId,
          demoBusinessInitiatorReference: kDemoDisputeBusinessInitiator,
          summary: 'Too late',
          syntheticEvidenceReferences: [kDemoDisputeEvidenceSessionCreate],
        ),
      ),
      BusinessDisputeCreateResult.complaintNotEligible,
    );
  });

  test('invalid dispute transition does not mutate state', () {
    final id = kDemoDisputeResolvedBusinessId;
    final before = disputeRepo.findById(id)!;
    final historyLen = disputeRepo.disputeHistory(id).length;
    expect(
      disputeRepo.applyTransition(
        disputeId: id,
        request: const BusinessDisputeTransitionRequest(
          targetStatus: BusinessDisputeStatus.filed,
        ),
      ),
      BusinessDisputeTransitionResult.invalidTransition,
    );
    expect(disputeRepo.findById(id), before);
    expect(disputeRepo.disputeHistory(id).length, historyLen);
  });

  test('resolved dispute requires resolution note', () {
    expect(
      disputeRepo.applyTransition(
        disputeId: kDemoDisputeUnderReviewId,
        request: const BusinessDisputeTransitionRequest(
          targetStatus: BusinessDisputeStatus.resolvedForBusiness,
        ),
      ),
      BusinessDisputeTransitionResult.resolutionNoteRequired,
    );
  });
}

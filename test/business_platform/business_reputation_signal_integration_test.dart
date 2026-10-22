import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/features/business_platform/data/business_review_demo_seed.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_complaint_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_dispute_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_owner_profile_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_reputation_event_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_review_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_demo_review_transaction_eligibility_provider.dart';
import 'package:qoshni/features/business_platform/domain/business_reputation_event_source_domain.dart';
import 'package:qoshni/features/business_platform/domain/business_reputation_event_type.dart';
import 'package:qoshni/features/business_platform/domain/business_review_status.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_review_repository.dart';
import 'package:qoshni/features/business_platform/presentation/business_reputation_signal_collector.dart';

void main() {
  late InMemoryBusinessOwnerProfileRepository ownerRepo;
  late InMemoryBusinessReputationEventRepository reputationRepo;
  late BusinessReputationSignalCollector collector;
  late InMemoryBusinessReviewRepository reviewRepo;

  setUp(() {
    ownerRepo = InMemoryBusinessOwnerProfileRepository();
    reputationRepo = InMemoryBusinessReputationEventRepository(ownerRepo);
    collector = BusinessReputationSignalCollector(reputationRepo);
    reviewRepo = InMemoryBusinessReviewRepository(
      ownerRepo,
      InMemoryDemoReviewTransactionEligibilityProvider(ownerRepo),
      signalCollector: collector,
    );
  });

  test('successful review publish emits reputation event', () {
    final before = reputationRepo
        .listForCurrentScope(
          sourceDomain: BusinessReputationEventSourceDomain.review,
          eventType: BusinessReputationEventType.reviewPublished,
        )
        .length;
    final summaryBefore = reviewRepo.ratingSummary();

    expect(
      reviewRepo.applyTransition(
        reviewId: kDemoReviewPendingId,
        request: const BusinessReviewTransitionRequest(
          targetStatus: BusinessReviewStatus.published,
        ),
      ),
      BusinessReviewTransitionResult.success,
    );

    final after = reputationRepo
        .listForCurrentScope(
          sourceDomain: BusinessReputationEventSourceDomain.review,
          eventType: BusinessReputationEventType.reviewPublished,
        )
        .length;
    expect(after, before + 1);
    expect(reviewRepo.ratingSummary().publishedReviewCount,
        summaryBefore.publishedReviewCount + 1);
  });

  test('failed review transition does not emit reputation event', () {
    final before = reputationRepo.listForCurrentScope().length;
    reviewRepo.failNextSave = true;
    expect(
      reviewRepo.applyTransition(
        reviewId: kDemoReviewPendingId,
        request: const BusinessReviewTransitionRequest(
          targetStatus: BusinessReviewStatus.published,
        ),
      ),
      BusinessReviewTransitionResult.failure,
    );
    expect(reputationRepo.listForCurrentScope().length, before);
  });

  test('domain histories remain separate from reputation stream', () {
    final owner = InMemoryBusinessOwnerProfileRepository();
    final rep = InMemoryBusinessReputationEventRepository(owner);
    final col = BusinessReputationSignalCollector(rep);
    final review = InMemoryBusinessReviewRepository(
      owner,
      InMemoryDemoReviewTransactionEligibilityProvider(owner),
      signalCollector: col,
    );
    final complaint = InMemoryBusinessComplaintRepository(
      owner,
      review,
      signalCollector: col,
    );
    final dispute = InMemoryBusinessDisputeRepository(
      owner,
      complaint,
      signalCollector: col,
    );

    expect(review.reviewHistory(kDemoReviewPublishedBreadId), isNotEmpty);
    expect(rep.listForCurrentScope().length, greaterThan(0));
    expect(dispute.listForCurrentScope(), isNotEmpty);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/features/business_platform/data/business_catalog_product_demo_seed.dart';
import 'package:qoshni/features/business_platform/data/business_review_demo_seed.dart';
import 'package:qoshni/features/business_platform/data/business_review_demo_transaction_evidence.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_review_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_demo_review_transaction_eligibility_provider.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_owner_profile_repository.dart';
import 'package:qoshni/features/business_platform/domain/business_review.dart';
import 'package:qoshni/features/business_platform/domain/business_review_status.dart';
import 'package:qoshni/features/business_platform/domain/business_review_target_type.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_review_repository.dart';
import 'package:qoshni/features/business_platform/domain/review_eligibility_result.dart';

void main() {
  late InMemoryBusinessOwnerProfileRepository ownerRepo;
  late InMemoryBusinessReviewRepository reviewRepo;

  setUp(() {
    ownerRepo = InMemoryBusinessOwnerProfileRepository();
    reviewRepo = InMemoryBusinessReviewRepository(
      ownerRepo,
      InMemoryDemoReviewTransactionEligibilityProvider(ownerRepo),
    );
  });

  test('seed published reviews contribute to rating summary', () {
    final summary = reviewRepo.ratingSummary();
    expect(summary.publishedReviewCount, greaterThanOrEqualTo(3));
    expect(summary.ratingSum, greaterThan(0));
  });

  test('creates review with eligible synthetic evidence', () {
    final result = reviewRepo.createReview(
      const BusinessReviewCreateInput(
        targetType: BusinessReviewTargetType.product,
        targetId: kDemoCatalogProductBreadId,
        demoReviewerReference: kDemoReviewReviewerA,
        transactionEvidenceReference: kDemoReviewTxEvidenceSessionCreate,
        rating: 5,
        reviewText: 'Demo',
      ),
    );
    expect(result, BusinessReviewCreateResult.success);
    final created = reviewRepo
        .listForCurrentScope(status: BusinessReviewStatus.draft)
        .lastWhere((r) => r.reviewText == 'Demo');
    expect(created.isSyntheticDemo, isTrue);
  });

  test('rejects duplicate evidence and reviewer', () {
    final eligibility = reviewRepo.previewEligibility(
      const BusinessReviewCreateInput(
        targetType: BusinessReviewTargetType.product,
        targetId: kDemoCatalogProductPlovId,
        demoReviewerReference: kDemoReviewReviewerB,
        transactionEvidenceReference: kDemoReviewTxEvidenceDuplicateTaken,
        rating: 4,
      ),
    );
    expect(eligibility.status, ReviewEligibilityStatus.duplicateReview);
  });

  test('rejects incomplete transaction evidence', () {
    expect(
      reviewRepo.createReview(
        const BusinessReviewCreateInput(
          targetType: BusinessReviewTargetType.product,
          targetId: kDemoCatalogProductBreadId,
          demoReviewerReference: kDemoReviewReviewerA,
          transactionEvidenceReference: kDemoReviewTxEvidenceIncomplete,
          rating: 3,
        ),
      ),
      BusinessReviewCreateResult.ineligible,
    );
  });

  test('invalid rating rejected', () {
    expect(
      reviewRepo.createReview(
        const BusinessReviewCreateInput(
          targetType: BusinessReviewTargetType.product,
          targetId: kDemoCatalogProductBreadId,
          demoReviewerReference: kDemoReviewReviewerA,
          transactionEvidenceReference: kDemoReviewTxEvidenceBreadCompleted,
          rating: 0,
        ),
      ),
      BusinessReviewCreateResult.invalidInput,
    );
  });

  test('moderation transitions and failNextSave', () {
    expect(
      reviewRepo.applyTransition(
        reviewId: kDemoReviewPendingId,
        request: const BusinessReviewTransitionRequest(
          targetStatus: BusinessReviewStatus.published,
        ),
      ),
      BusinessReviewTransitionResult.success,
    );

    reviewRepo.failNextSave = true;
    final before = reviewRepo.findById(kDemoReviewPublishedBreadId)!;
    final historyLen = reviewRepo.reviewHistory(before.reviewId).length;
    expect(
      reviewRepo.applyTransition(
        reviewId: before.reviewId,
        request: const BusinessReviewTransitionRequest(
          targetStatus: BusinessReviewStatus.hidden,
        ),
      ),
      BusinessReviewTransitionResult.failure,
    );
    expect(reviewRepo.findById(before.reviewId)!.status, before.status);
    expect(reviewRepo.reviewHistory(before.reviewId).length, historyLen);
  });

  test('evidence is synthetic in eligibility result', () {
    final result = reviewRepo.previewEligibility(
      const BusinessReviewCreateInput(
        targetType: BusinessReviewTargetType.product,
        targetId: kDemoCatalogProductBreadId,
        demoReviewerReference: kDemoReviewReviewerA,
        transactionEvidenceReference: kDemoReviewTxEvidenceSessionCreate,
        rating: 5,
      ),
    );
    expect(result.isEligible, isTrue);
    expect(result.evidence!.isSynthetic, isTrue);
  });
}

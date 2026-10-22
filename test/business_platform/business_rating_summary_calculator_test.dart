import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/features/business_platform/domain/business_review.dart';
import 'package:qoshni/features/business_platform/domain/business_review_provenance.dart';
import 'package:qoshni/features/business_platform/domain/business_review_status.dart';
import 'package:qoshni/features/business_platform/domain/business_review_target_type.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_product.dart';
import 'package:qoshni/features/business_platform/presentation/business_rating_summary_calculator.dart';

BusinessReview _review(int rating, BusinessReviewStatus status) {
  return BusinessReview(
    reviewId: 'r-$rating-$status',
    businessScopeId: 'scope',
    branchId: 'branch',
    targetType: BusinessReviewTargetType.product,
    targetId: 'p',
    demoReviewerReference: 'rev',
    transactionEvidenceReference: 'ev-$rating-$status',
    rating: rating,
    status: status,
    provenance: BusinessReviewProvenance.syntheticDemo,
    createdAt: DateTime.utc(2025, 1, 1),
    updatedAt: DateTime.utc(2025, 1, 1),
    dataSource: BusinessCatalogProductDataSource.demoSeed,
  );
}

void main() {
  test('only published reviews count toward summary', () {
    final summary = computeBusinessRatingSummary([
      _review(5, BusinessReviewStatus.published),
      _review(1, BusinessReviewStatus.rejected),
      _review(3, BusinessReviewStatus.hidden),
      _review(4, BusinessReviewStatus.pendingModeration),
    ]);
    expect(summary.publishedReviewCount, 1);
    expect(summary.ratingSum, 5);
    expect(summary.distribution[5], 1);
    expect(summary.distribution[1], 0);
  });

  test('average is deterministic from sum and count', () {
    final summary = computeBusinessRatingSummary([
      _review(4, BusinessReviewStatus.published),
      _review(2, BusinessReviewStatus.published),
    ]);
    expect(summary.averageRating, 3);
    expect(formatBusinessRatingAverageForDisplay(summary.averageRating), '3.0');
  });
}

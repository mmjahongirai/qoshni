import 'package:qoshni/features/business_platform/domain/business_rating_summary.dart';
import 'package:qoshni/features/business_platform/domain/business_review.dart';
import 'package:qoshni/features/business_platform/domain/business_review_status.dart';

BusinessRatingSummary computeBusinessRatingSummary(
  Iterable<BusinessReview> reviews,
) {
  final distribution = <int, int>{
    1: 0,
    2: 0,
    3: 0,
    4: 0,
    5: 0,
  };
  var sum = 0;
  var count = 0;
  for (final review in reviews) {
    if (review.status != BusinessReviewStatus.published) {
      continue;
    }
    count++;
    sum += review.rating;
    distribution[review.rating] = (distribution[review.rating] ?? 0) + 1;
  }
  return BusinessRatingSummary(
    publishedReviewCount: count,
    ratingSum: sum,
    distribution: distribution,
  );
}

/// UI-only formatting — repository keeps raw sum/count.
String formatBusinessRatingAverageForDisplay(double average) {
  if (average == 0) {
    return '0';
  }
  return average.toStringAsFixed(1);
}

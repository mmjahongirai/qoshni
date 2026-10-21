class BusinessRatingSummary {
  const BusinessRatingSummary({
    required this.publishedReviewCount,
    required this.ratingSum,
    required this.distribution,
  });

  final int publishedReviewCount;
  final int ratingSum;
  final Map<int, int> distribution;

  double get averageRating {
    if (publishedReviewCount == 0) {
      return 0;
    }
    return ratingSum / publishedReviewCount;
  }
}

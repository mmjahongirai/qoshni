import 'package:qoshni/features/business_platform/domain/business_review_status.dart';

bool catalogBusinessReviewTransitionAllowed({
  required BusinessReviewStatus from,
  required BusinessReviewStatus to,
}) {
  if (from == to) {
    return false;
  }
  switch (from) {
    case BusinessReviewStatus.draft:
      return to == BusinessReviewStatus.pendingModeration;
    case BusinessReviewStatus.pendingModeration:
      return to == BusinessReviewStatus.published ||
          to == BusinessReviewStatus.rejected ||
          to == BusinessReviewStatus.hidden;
    case BusinessReviewStatus.published:
      return to == BusinessReviewStatus.hidden;
    case BusinessReviewStatus.rejected:
    case BusinessReviewStatus.hidden:
      return false;
  }
}

import 'package:qoshni/features/business_platform/domain/business_rating_summary.dart';
import 'package:qoshni/features/business_platform/domain/business_review.dart';
import 'package:qoshni/features/business_platform/domain/business_review_history_event.dart';
import 'package:qoshni/features/business_platform/domain/business_review_status.dart';
import 'package:qoshni/features/business_platform/domain/business_review_target_type.dart';
import 'package:qoshni/features/business_platform/domain/review_eligibility_result.dart';

enum BusinessReviewCreateResult {
  success,
  invalidInput,
  ineligible,
  failure,
}

enum BusinessReviewTransitionResult {
  success,
  notFound,
  invalidTransition,
  duplicateStatus,
  failure,
}

class BusinessReviewTransitionRequest {
  const BusinessReviewTransitionRequest({
    required this.targetStatus,
    this.moderationReason,
  });

  final BusinessReviewStatus targetStatus;
  final String? moderationReason;
}

abstract class BusinessReviewRepository {
  String get businessScopeId;

  List<BusinessReview> listForCurrentScope({
    String? branchId,
    BusinessReviewTargetType? targetType,
    BusinessReviewStatus? status,
  });

  BusinessReview? findById(String reviewId);

  ReviewEligibilityResult previewEligibility(BusinessReviewCreateInput input);

  BusinessReviewCreateResult createReview(BusinessReviewCreateInput input);

  BusinessReviewTransitionResult applyTransition({
    required String reviewId,
    required BusinessReviewTransitionRequest request,
  });

  List<BusinessReviewHistoryEvent> reviewHistory(String reviewId);

  BusinessRatingSummary ratingSummary({
    String? branchId,
    BusinessReviewTargetType? targetType,
    String? targetId,
  });
}

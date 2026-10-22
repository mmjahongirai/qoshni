import 'package:qoshni/features/business_platform/domain/business_review_target_type.dart';
import 'package:qoshni/features/business_platform/domain/review_eligibility_result.dart';

abstract class ReviewTransactionEligibilityProvider {
  ReviewEligibilityResult evaluate({
    required String transactionEvidenceReference,
    required String demoReviewerReference,
    required String businessScopeId,
    String? branchId,
    required BusinessReviewTargetType targetType,
    required String targetId,
    required bool hasExistingReviewForEvidenceAndReviewer,
  });
}

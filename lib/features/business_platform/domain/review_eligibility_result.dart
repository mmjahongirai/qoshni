import 'package:qoshni/features/business_platform/domain/review_transaction_evidence.dart';

enum ReviewEligibilityStatus {
  eligible,
  evidenceNotFound,
  incompleteTransaction,
  scopeMismatch,
  targetMismatch,
  duplicateReview,
}

class ReviewEligibilityResult {
  const ReviewEligibilityResult._({
    required this.status,
    this.evidence,
  });

  const ReviewEligibilityResult.ineligible(ReviewEligibilityStatus status)
      : this._(status: status);

  const ReviewEligibilityResult.eligible(ReviewTransactionEvidence evidence)
      : this._(
          status: ReviewEligibilityStatus.eligible,
          evidence: evidence,
        );

  final ReviewEligibilityStatus status;
  final ReviewTransactionEvidence? evidence;

  bool get isEligible => status == ReviewEligibilityStatus.eligible;
}

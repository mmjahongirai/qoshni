import 'package:qoshni/features/business_platform/domain/business_review_target_type.dart';

/// Demo or future authoritative slot for a completed transaction — not a real order ID.
class ReviewTransactionEvidence {
  const ReviewTransactionEvidence({
    required this.transactionEvidenceReference,
    required this.isSynthetic,
    required this.isCompleted,
    required this.businessScopeId,
    required this.branchId,
    required this.targetType,
    required this.targetId,
    required this.demoReviewerReference,
  });

  final String transactionEvidenceReference;
  final bool isSynthetic;
  final bool isCompleted;
  final String businessScopeId;
  final String branchId;
  final BusinessReviewTargetType targetType;
  final String targetId;
  final String demoReviewerReference;
}

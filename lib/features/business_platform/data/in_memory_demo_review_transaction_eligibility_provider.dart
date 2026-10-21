import 'package:qoshni/features/business_platform/data/business_review_demo_transaction_evidence.dart';
import 'package:qoshni/features/business_platform/domain/business_review_target_type.dart';
import 'package:qoshni/features/business_platform/domain/review_eligibility_result.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_owner_profile_repository.dart';
import 'package:qoshni/features/business_platform/domain/review_transaction_eligibility_provider.dart';
import 'package:qoshni/features/business_platform/domain/review_transaction_evidence.dart';

class InMemoryDemoReviewTransactionEligibilityProvider
    implements ReviewTransactionEligibilityProvider {
  InMemoryDemoReviewTransactionEligibilityProvider(this._ownerProfileRepository);

  final BusinessOwnerProfileRepository _ownerProfileRepository;

  List<ReviewTransactionEvidence> get _catalog =>
      buildDemoReviewTransactionEvidenceCatalog(
        businessScopeId: _ownerProfileRepository
            .ensureSessionProfile()
            .sessionProfileId,
      );

  @override
  ReviewEligibilityResult evaluate({
    required String transactionEvidenceReference,
    required String demoReviewerReference,
    required String businessScopeId,
    String? branchId,
    required BusinessReviewTargetType targetType,
    required String targetId,
    required bool hasExistingReviewForEvidenceAndReviewer,
  }) {
    if (hasExistingReviewForEvidenceAndReviewer) {
      return const ReviewEligibilityResult.ineligible(
        ReviewEligibilityStatus.duplicateReview,
      );
    }

    final ref = transactionEvidenceReference.trim();
    ReviewTransactionEvidence? evidence;
    for (final item in _catalog) {
      if (item.transactionEvidenceReference == ref) {
        evidence = item;
        break;
      }
    }
    if (evidence == null) {
      return const ReviewEligibilityResult.ineligible(
        ReviewEligibilityStatus.evidenceNotFound,
      );
    }
    if (!evidence.isCompleted) {
      return const ReviewEligibilityResult.ineligible(
        ReviewEligibilityStatus.incompleteTransaction,
      );
    }
    if (evidence.businessScopeId != businessScopeId) {
      return const ReviewEligibilityResult.ineligible(
        ReviewEligibilityStatus.scopeMismatch,
      );
    }
    if (branchId != null &&
        branchId.trim().isNotEmpty &&
        evidence.branchId != branchId.trim()) {
      return const ReviewEligibilityResult.ineligible(
        ReviewEligibilityStatus.scopeMismatch,
      );
    }
    if (evidence.targetType != targetType || evidence.targetId != targetId) {
      return const ReviewEligibilityResult.ineligible(
        ReviewEligibilityStatus.targetMismatch,
      );
    }
    if (evidence.demoReviewerReference != demoReviewerReference.trim()) {
      return const ReviewEligibilityResult.ineligible(
        ReviewEligibilityStatus.targetMismatch,
      );
    }
    return ReviewEligibilityResult.eligible(evidence);
  }
}

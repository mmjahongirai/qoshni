import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/features/business_platform/domain/business_review_status.dart';
import 'package:qoshni/features/business_platform/domain/business_review_target_type.dart';
import 'package:qoshni/features/business_platform/domain/review_eligibility_result.dart';

extension BusinessReviewLabels on AppLocalizations {
  String businessReviewTargetTypeLabel(BusinessReviewTargetType type) {
    switch (type) {
      case BusinessReviewTargetType.business:
        return businessReviewTargetBusiness;
      case BusinessReviewTargetType.product:
        return businessReviewTargetProduct;
      case BusinessReviewTargetType.service:
        return businessReviewTargetService;
    }
  }

  String businessReviewStatusLabel(BusinessReviewStatus status) {
    switch (status) {
      case BusinessReviewStatus.draft:
        return businessReviewStatusDraft;
      case BusinessReviewStatus.pendingModeration:
        return businessReviewStatusPendingModeration;
      case BusinessReviewStatus.published:
        return businessReviewStatusPublished;
      case BusinessReviewStatus.rejected:
        return businessReviewStatusRejected;
      case BusinessReviewStatus.hidden:
        return businessReviewStatusHidden;
    }
  }

  String businessReviewEligibilityMessage(ReviewEligibilityStatus status) {
    switch (status) {
      case ReviewEligibilityStatus.eligible:
        return businessReviewEligibilityEligible;
      case ReviewEligibilityStatus.evidenceNotFound:
        return businessReviewEligibilityEvidenceNotFound;
      case ReviewEligibilityStatus.incompleteTransaction:
        return businessReviewEligibilityIncomplete;
      case ReviewEligibilityStatus.scopeMismatch:
        return businessReviewEligibilityScopeMismatch;
      case ReviewEligibilityStatus.targetMismatch:
        return businessReviewEligibilityTargetMismatch;
      case ReviewEligibilityStatus.duplicateReview:
        return businessReviewEligibilityDuplicate;
    }
  }

  String businessReviewModerationActionLabel(BusinessReviewStatus target) {
    switch (target) {
      case BusinessReviewStatus.pendingModeration:
        return businessReviewActionSubmitModeration;
      case BusinessReviewStatus.published:
        return businessReviewActionPublish;
      case BusinessReviewStatus.rejected:
        return businessReviewActionReject;
      case BusinessReviewStatus.hidden:
        return businessReviewActionHide;
      case BusinessReviewStatus.draft:
        return businessReviewStatusDraft;
    }
  }
}

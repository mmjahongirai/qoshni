import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/features/business_platform/domain/business_complaint_category.dart';
import 'package:qoshni/features/business_platform/domain/business_complaint_status.dart';
import 'package:qoshni/features/business_platform/domain/business_dispute_status.dart';
import 'package:qoshni/features/business_platform/domain/business_review_target_type.dart';

extension BusinessComplaintDisputeLabels on AppLocalizations {
  String businessComplaintCategoryLabel(BusinessComplaintCategory category) {
    switch (category) {
      case BusinessComplaintCategory.productQuality:
        return businessComplaintCategoryProductQuality;
      case BusinessComplaintCategory.serviceIssue:
        return businessComplaintCategoryServiceIssue;
      case BusinessComplaintCategory.billing:
        return businessComplaintCategoryBilling;
      case BusinessComplaintCategory.delivery:
        return businessComplaintCategoryDelivery;
      case BusinessComplaintCategory.other:
        return businessComplaintCategoryOther;
    }
  }

  String businessComplaintStatusLabel(BusinessComplaintStatus status) {
    switch (status) {
      case BusinessComplaintStatus.submitted:
        return businessComplaintStatusSubmitted;
      case BusinessComplaintStatus.underReview:
        return businessComplaintStatusUnderReview;
      case BusinessComplaintStatus.resolved:
        return businessComplaintStatusResolved;
      case BusinessComplaintStatus.dismissed:
        return businessComplaintStatusDismissed;
    }
  }

  String businessDisputeStatusLabel(BusinessDisputeStatus status) {
    switch (status) {
      case BusinessDisputeStatus.filed:
        return businessDisputeStatusFiled;
      case BusinessDisputeStatus.underReview:
        return businessDisputeStatusUnderReview;
      case BusinessDisputeStatus.resolvedForBusiness:
        return businessDisputeStatusResolvedBusiness;
      case BusinessDisputeStatus.resolvedForReporter:
        return businessDisputeStatusResolvedReporter;
      case BusinessDisputeStatus.dismissed:
        return businessDisputeStatusDismissed;
    }
  }

  String businessComplaintTargetTypeLabel(BusinessReviewTargetType type) {
    switch (type) {
      case BusinessReviewTargetType.business:
        return businessReviewTargetBusiness;
      case BusinessReviewTargetType.product:
        return businessReviewTargetProduct;
      case BusinessReviewTargetType.service:
        return businessReviewTargetService;
    }
  }
}

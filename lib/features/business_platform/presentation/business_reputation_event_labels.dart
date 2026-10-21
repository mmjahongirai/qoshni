import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/features/business_platform/domain/business_reputation_event_source_domain.dart';
import 'package:qoshni/features/business_platform/domain/business_reputation_event_type.dart';

extension BusinessReputationEventLabels on AppLocalizations {
  String businessReputationEventTypeLabel(BusinessReputationEventType type) {
    switch (type) {
      case BusinessReputationEventType.reviewPublished:
        return businessReputationEventTypeReviewPublished;
      case BusinessReputationEventType.reviewRejected:
        return businessReputationEventTypeReviewRejected;
      case BusinessReputationEventType.reviewHidden:
        return businessReputationEventTypeReviewHidden;
      case BusinessReputationEventType.complaintCreated:
        return businessReputationEventTypeComplaintCreated;
      case BusinessReputationEventType.complaintStatusChanged:
        return businessReputationEventTypeComplaintStatusChanged;
      case BusinessReputationEventType.disputeOpened:
        return businessReputationEventTypeDisputeOpened;
      case BusinessReputationEventType.disputeStatusChanged:
        return businessReputationEventTypeDisputeStatusChanged;
    }
  }

  String businessReputationEventSourceLabel(
    BusinessReputationEventSourceDomain source,
  ) {
    switch (source) {
      case BusinessReputationEventSourceDomain.review:
        return businessReputationEventSourceReview;
      case BusinessReputationEventSourceDomain.complaint:
        return businessReputationEventSourceComplaint;
      case BusinessReputationEventSourceDomain.dispute:
        return businessReputationEventSourceDispute;
    }
  }
}

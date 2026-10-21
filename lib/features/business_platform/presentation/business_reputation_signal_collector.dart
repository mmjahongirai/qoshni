import 'package:qoshni/features/business_platform/domain/business_reputation_event.dart';
import 'package:qoshni/features/business_platform/domain/business_complaint.dart';
import 'package:qoshni/features/business_platform/domain/business_complaint_status.dart';
import 'package:qoshni/features/business_platform/domain/business_dispute.dart';
import 'package:qoshni/features/business_platform/domain/business_dispute_status.dart';
import 'package:qoshni/features/business_platform/domain/business_reputation_event_source_domain.dart';
import 'package:qoshni/features/business_platform/domain/business_reputation_event_type.dart';
import 'package:qoshni/features/business_platform/domain/business_review.dart';
import 'package:qoshni/features/business_platform/domain/business_review_status.dart';
import 'package:qoshni/features/business_platform/domain/business_review_target_type.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_reputation_event_repository.dart';

/// Records append-only reputation signals after successful domain writes.
class BusinessReputationSignalCollector {
  BusinessReputationSignalCollector(this._repository);

  final BusinessReputationEventRepository _repository;

  BusinessReputationEventRecordResult recordReviewModerationOutcome({
    required BusinessReview review,
    required BusinessReviewStatus previousStatus,
    required BusinessReviewStatus newStatus,
    required DateTime occurredAt,
    required String sourceHistoryEventId,
  }) {
    final eventType = _reviewEventType(newStatus);
    if (eventType == null) {
      return BusinessReputationEventRecordResult.invalidInput;
    }
    return _repository.appendEvent(
      BusinessReputationEventRecordInput(
        businessScopeId: review.businessScopeId,
        branchId: review.branchId,
        targetType: review.targetType,
        targetId: review.targetId,
        eventType: eventType,
        sourceDomain: BusinessReputationEventSourceDomain.review,
        sourceRecordId: review.reviewId,
        previousStatusLabel: previousStatus.name,
        newStatusLabel: newStatus.name,
        correlationReferenceId:
            'corr-review-${review.reviewId}-hist-$sourceHistoryEventId',
        provenance: review.provenance,
        occurredAt: occurredAt,
        metadataSummary: 'Demo review moderation signal',
      ),
    );
  }

  BusinessReputationEventRecordResult recordComplaintCreated({
    required BusinessComplaint complaint,
    required DateTime occurredAt,
    required String sourceHistoryEventId,
  }) {
    return _repository.appendEvent(
      BusinessReputationEventRecordInput(
        businessScopeId: complaint.businessScopeId,
        branchId: complaint.branchId,
        targetType: complaint.targetType,
        targetId: complaint.targetId,
        eventType: BusinessReputationEventType.complaintCreated,
        sourceDomain: BusinessReputationEventSourceDomain.complaint,
        sourceRecordId: complaint.complaintId,
        newStatusLabel: BusinessComplaintStatus.submitted.name,
        correlationReferenceId:
            'corr-complaint-${complaint.complaintId}-hist-$sourceHistoryEventId',
        provenance: complaint.provenance,
        occurredAt: occurredAt,
        metadataSummary: 'Demo complaint filed',
      ),
    );
  }

  BusinessReputationEventRecordResult recordComplaintStatusChanged({
    required BusinessComplaint complaint,
    required BusinessComplaintStatus previousStatus,
    required BusinessComplaintStatus newStatus,
    required DateTime occurredAt,
    required String sourceHistoryEventId,
  }) {
    return _repository.appendEvent(
      BusinessReputationEventRecordInput(
        businessScopeId: complaint.businessScopeId,
        branchId: complaint.branchId,
        targetType: complaint.targetType,
        targetId: complaint.targetId,
        eventType: BusinessReputationEventType.complaintStatusChanged,
        sourceDomain: BusinessReputationEventSourceDomain.complaint,
        sourceRecordId: complaint.complaintId,
        previousStatusLabel: previousStatus.name,
        newStatusLabel: newStatus.name,
        correlationReferenceId:
            'corr-complaint-${complaint.complaintId}-hist-$sourceHistoryEventId',
        provenance: complaint.provenance,
        occurredAt: occurredAt,
      ),
    );
  }

  BusinessReputationEventRecordResult recordDisputeOpened({
    required BusinessDispute dispute,
    required DateTime occurredAt,
    required String sourceHistoryEventId,
  }) {
    return _repository.appendEvent(
      BusinessReputationEventRecordInput(
        businessScopeId: dispute.businessScopeId,
        branchId: dispute.branchId,
        targetType: BusinessReviewTargetType.business,
        targetId: dispute.businessScopeId,
        eventType: BusinessReputationEventType.disputeOpened,
        sourceDomain: BusinessReputationEventSourceDomain.dispute,
        sourceRecordId: dispute.disputeId,
        newStatusLabel: BusinessDisputeStatus.filed.name,
        correlationReferenceId:
            'corr-dispute-${dispute.disputeId}-hist-$sourceHistoryEventId',
        provenance: dispute.provenance,
        occurredAt: occurredAt,
        metadataSummary: 'Linked complaint ${dispute.complaintId}',
      ),
    );
  }

  BusinessReputationEventRecordResult recordDisputeStatusChanged({
    required BusinessDispute dispute,
    required BusinessDisputeStatus previousStatus,
    required BusinessDisputeStatus newStatus,
    required DateTime occurredAt,
    required String sourceHistoryEventId,
  }) {
    return _repository.appendEvent(
      BusinessReputationEventRecordInput(
        businessScopeId: dispute.businessScopeId,
        branchId: dispute.branchId,
        targetType: BusinessReviewTargetType.business,
        targetId: dispute.businessScopeId,
        eventType: BusinessReputationEventType.disputeStatusChanged,
        sourceDomain: BusinessReputationEventSourceDomain.dispute,
        sourceRecordId: dispute.disputeId,
        previousStatusLabel: previousStatus.name,
        newStatusLabel: newStatus.name,
        correlationReferenceId:
            'corr-dispute-${dispute.disputeId}-hist-$sourceHistoryEventId',
        provenance: dispute.provenance,
        occurredAt: occurredAt,
      ),
    );
  }

  BusinessReputationEventType? _reviewEventType(BusinessReviewStatus status) {
    switch (status) {
      case BusinessReviewStatus.published:
        return BusinessReputationEventType.reviewPublished;
      case BusinessReviewStatus.rejected:
        return BusinessReputationEventType.reviewRejected;
      case BusinessReviewStatus.hidden:
        return BusinessReputationEventType.reviewHidden;
      case BusinessReviewStatus.draft:
      case BusinessReviewStatus.pendingModeration:
        return null;
    }
  }
}

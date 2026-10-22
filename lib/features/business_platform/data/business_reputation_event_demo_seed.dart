import 'package:qoshni/features/business_platform/data/business_complaint_dispute_demo_seed.dart';
import 'package:qoshni/features/business_platform/data/business_review_demo_seed.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_product.dart';
import 'package:qoshni/features/business_platform/domain/business_complaint_status.dart';
import 'package:qoshni/features/business_platform/domain/business_dispute_status.dart';
import 'package:qoshni/features/business_platform/domain/business_reputation_event.dart';
import 'package:qoshni/features/business_platform/domain/business_reputation_event_source_domain.dart';
import 'package:qoshni/features/business_platform/domain/business_reputation_event_type.dart';
import 'package:qoshni/features/business_platform/domain/business_review_provenance.dart';
import 'package:qoshni/features/business_platform/domain/business_review_status.dart';
import 'package:qoshni/features/business_platform/domain/business_review_target_type.dart';

final DateTime kDemoReputationEventEpoch = DateTime.utc(2025, 2, 6, 8, 0, 0);

List<BusinessReputationEvent> buildDemoBusinessReputationEvents({
  required String businessScopeId,
}) {
  final complaints = buildDemoBusinessComplaints(businessScopeId: businessScopeId);
  final disputes = buildDemoBusinessDisputes(businessScopeId: businessScopeId);
  final reviews = buildDemoBusinessReviews(businessScopeId: businessScopeId);

  final events = <BusinessReputationEvent>[];
  var seq = 0;

  BusinessReputationEvent add({
    required BusinessReputationEventType eventType,
    required BusinessReputationEventSourceDomain sourceDomain,
    required String sourceRecordId,
    required BusinessReviewTargetType targetType,
    required String targetId,
    String? branchId,
    String? previousStatusLabel,
    String? newStatusLabel,
    required String correlationReferenceId,
    required DateTime occurredAt,
    String? metadataSummary,
  }) {
    seq++;
    return BusinessReputationEvent(
      reputationEventId: 'demo-reputation-event-${seq.toString().padLeft(3, '0')}',
      businessScopeId: businessScopeId,
      branchId: branchId,
      targetType: targetType,
      targetId: targetId,
      eventType: eventType,
      sourceDomain: sourceDomain,
      sourceRecordId: sourceRecordId,
      previousStatusLabel: previousStatusLabel,
      newStatusLabel: newStatusLabel,
      correlationReferenceId: correlationReferenceId,
      provenance: BusinessReviewProvenance.syntheticDemo,
      occurredAt: occurredAt,
      recordedAt: occurredAt.add(const Duration(minutes: 1)),
      dataSource: BusinessCatalogProductDataSource.demoSeed,
      metadataSummary: metadataSummary,
    );
  }

  for (final r in reviews) {
    if (r.status == BusinessReviewStatus.published) {
      events.add(
        add(
          eventType: BusinessReputationEventType.reviewPublished,
          sourceDomain: BusinessReputationEventSourceDomain.review,
          sourceRecordId: r.reviewId,
          targetType: r.targetType,
          targetId: r.targetId,
          branchId: r.branchId,
          previousStatusLabel: BusinessReviewStatus.pendingModeration.name,
          newStatusLabel: r.status.name,
          correlationReferenceId:
              'demo-corr-review-${r.reviewId}-published',
          occurredAt: r.moderatedAt ?? r.updatedAt,
          metadataSummary: 'Demo review moderation signal',
        ),
      );
    } else if (r.status == BusinessReviewStatus.rejected) {
      events.add(
        add(
          eventType: BusinessReputationEventType.reviewRejected,
          sourceDomain: BusinessReputationEventSourceDomain.review,
          sourceRecordId: r.reviewId,
          targetType: r.targetType,
          targetId: r.targetId,
          branchId: r.branchId,
          previousStatusLabel: BusinessReviewStatus.pendingModeration.name,
          newStatusLabel: r.status.name,
          correlationReferenceId: 'demo-corr-review-${r.reviewId}-rejected',
          occurredAt: r.moderatedAt ?? r.updatedAt,
        ),
      );
    } else if (r.status == BusinessReviewStatus.hidden) {
      events.add(
        add(
          eventType: BusinessReputationEventType.reviewHidden,
          sourceDomain: BusinessReputationEventSourceDomain.review,
          sourceRecordId: r.reviewId,
          targetType: r.targetType,
          targetId: r.targetId,
          branchId: r.branchId,
          previousStatusLabel: BusinessReviewStatus.published.name,
          newStatusLabel: r.status.name,
          correlationReferenceId: 'demo-corr-review-${r.reviewId}-hidden',
          occurredAt: r.moderatedAt ?? r.updatedAt,
        ),
      );
    }
  }

  for (final c in complaints) {
    events.add(
      add(
        eventType: BusinessReputationEventType.complaintCreated,
        sourceDomain: BusinessReputationEventSourceDomain.complaint,
        sourceRecordId: c.complaintId,
        targetType: c.targetType,
        targetId: c.targetId,
        branchId: c.branchId,
        newStatusLabel: BusinessComplaintStatus.submitted.name,
        correlationReferenceId: 'demo-corr-complaint-${c.complaintId}-created',
        occurredAt: c.createdAt,
        metadataSummary: 'Demo complaint filed',
      ),
    );
    if (c.status != BusinessComplaintStatus.submitted) {
      events.add(
        add(
          eventType: BusinessReputationEventType.complaintStatusChanged,
          sourceDomain: BusinessReputationEventSourceDomain.complaint,
          sourceRecordId: c.complaintId,
          targetType: c.targetType,
          targetId: c.targetId,
          branchId: c.branchId,
          previousStatusLabel: BusinessComplaintStatus.submitted.name,
          newStatusLabel: c.status.name,
          correlationReferenceId:
              'demo-corr-complaint-${c.complaintId}-status-${c.status.name}',
          occurredAt: c.updatedAt,
        ),
      );
    }
  }

  for (final d in disputes) {
    events.add(
      add(
        eventType: BusinessReputationEventType.disputeOpened,
        sourceDomain: BusinessReputationEventSourceDomain.dispute,
        sourceRecordId: d.disputeId,
        targetType: BusinessReviewTargetType.business,
        targetId: businessScopeId,
        branchId: d.branchId,
        newStatusLabel: BusinessDisputeStatus.filed.name,
        correlationReferenceId: 'demo-corr-dispute-${d.disputeId}-opened',
        occurredAt: d.createdAt,
        metadataSummary: 'Linked complaint ${d.complaintId}',
      ),
    );
    if (d.status != BusinessDisputeStatus.filed) {
      events.add(
        add(
          eventType: BusinessReputationEventType.disputeStatusChanged,
          sourceDomain: BusinessReputationEventSourceDomain.dispute,
          sourceRecordId: d.disputeId,
          targetType: BusinessReviewTargetType.business,
          targetId: businessScopeId,
          branchId: d.branchId,
          previousStatusLabel: BusinessDisputeStatus.filed.name,
          newStatusLabel: d.status.name,
          correlationReferenceId:
              'demo-corr-dispute-${d.disputeId}-status-${d.status.name}',
          occurredAt: d.updatedAt,
        ),
      );
    }
  }

  events.sort((a, b) {
    final byTime = a.occurredAt.compareTo(b.occurredAt);
    if (byTime != 0) {
      return byTime;
    }
    return a.reputationEventId.compareTo(b.reputationEventId);
  });
  return events;
}

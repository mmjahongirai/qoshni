import 'package:qoshni/features/business_platform/data/business_catalog_inventory_demo_seed.dart';
import 'package:qoshni/features/business_platform/data/business_catalog_product_demo_seed.dart';
import 'package:qoshni/features/business_platform/data/business_catalog_service_demo_seed.dart';
import 'package:qoshni/features/business_platform/data/business_complaint_demo_evidence.dart';
import 'package:qoshni/features/business_platform/data/business_review_demo_seed.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_product.dart';
import 'package:qoshni/features/business_platform/domain/business_complaint.dart';
import 'package:qoshni/features/business_platform/domain/business_complaint_category.dart';
import 'package:qoshni/features/business_platform/domain/business_complaint_history_event.dart';
import 'package:qoshni/features/business_platform/domain/business_complaint_status.dart';
import 'package:qoshni/features/business_platform/domain/business_dispute.dart';
import 'package:qoshni/features/business_platform/domain/business_dispute_history_event.dart';
import 'package:qoshni/features/business_platform/domain/business_dispute_status.dart';
import 'package:qoshni/features/business_platform/domain/business_review_provenance.dart';
import 'package:qoshni/features/business_platform/domain/business_review_target_type.dart';

const String kDemoComplaintSubmittedId = 'demo-complaint-submitted-001';
const String kDemoComplaintUnderReviewId = 'demo-complaint-under-review-002';
const String kDemoComplaintResolvedId = 'demo-complaint-resolved-003';
const String kDemoComplaintDismissedId = 'demo-complaint-dismissed-004';
const String kDemoComplaintWithDisputeId = 'demo-complaint-with-dispute-005';

const String kDemoDisputeFiledId = 'demo-dispute-filed-001';
const String kDemoDisputeUnderReviewId = 'demo-dispute-under-review-002';
const String kDemoDisputeResolvedBusinessId = 'demo-dispute-resolved-business-003';

final DateTime kDemoComplaintEpoch = DateTime.utc(2025, 2, 5, 9, 0, 0);

List<BusinessComplaint> buildDemoBusinessComplaints({
  required String businessScopeId,
}) {
  return [
    BusinessComplaint(
      complaintId: kDemoComplaintSubmittedId,
      businessScopeId: businessScopeId,
      branchId: kDemoBranchTashkentCenterId,
      targetType: BusinessReviewTargetType.product,
      targetId: kDemoCatalogProductBreadId,
      demoReporterReference: kDemoComplaintReporterA,
      category: BusinessComplaintCategory.productQuality,
      description: 'Demo: synthetic report about product quality (not a real case).',
      syntheticEvidenceReferences: const [kDemoComplaintEvidenceBreadQuality],
      relatedReviewId: kDemoReviewPublishedBreadId,
      status: BusinessComplaintStatus.submitted,
      provenance: BusinessReviewProvenance.syntheticDemo,
      createdAt: kDemoComplaintEpoch,
      updatedAt: kDemoComplaintEpoch,
      dataSource: BusinessCatalogProductDataSource.demoSeed,
    ),
    BusinessComplaint(
      complaintId: kDemoComplaintUnderReviewId,
      businessScopeId: businessScopeId,
      branchId: kDemoBranchTashkentCenterId,
      targetType: BusinessReviewTargetType.service,
      targetId: kDemoCatalogServicePackingId,
      demoReporterReference: kDemoComplaintReporterB,
      category: BusinessComplaintCategory.serviceIssue,
      description: 'Demo: service timing concern with synthetic evidence only.',
      syntheticEvidenceReferences: const [kDemoComplaintEvidenceServiceDelay],
      status: BusinessComplaintStatus.underReview,
      provenance: BusinessReviewProvenance.syntheticDemo,
      createdAt: kDemoComplaintEpoch.add(const Duration(hours: 2)),
      updatedAt: kDemoComplaintEpoch.add(const Duration(hours: 3)),
      dataSource: BusinessCatalogProductDataSource.demoSeed,
    ),
    BusinessComplaint(
      complaintId: kDemoComplaintResolvedId,
      businessScopeId: businessScopeId,
      branchId: kDemoBranchSamarkandId,
      targetType: BusinessReviewTargetType.product,
      targetId: kDemoCatalogProductPlovId,
      demoReporterReference: kDemoComplaintReporterC,
      category: BusinessComplaintCategory.billing,
      description: 'Demo: resolved billing question (demo operator note).',
      syntheticEvidenceReferences: const [kDemoComplaintEvidenceBilling],
      status: BusinessComplaintStatus.resolved,
      provenance: BusinessReviewProvenance.syntheticDemo,
      createdAt: kDemoComplaintEpoch.add(const Duration(days: 1)),
      updatedAt: kDemoComplaintEpoch.add(const Duration(days: 1, hours: 4)),
      resolvedAt: kDemoComplaintEpoch.add(const Duration(days: 1, hours: 4)),
      resolutionNote: 'Demo: closed with synthetic refund note — not real money.',
      dataSource: BusinessCatalogProductDataSource.demoSeed,
    ),
    BusinessComplaint(
      complaintId: kDemoComplaintDismissedId,
      businessScopeId: businessScopeId,
      branchId: kDemoBranchTashkentCenterId,
      targetType: BusinessReviewTargetType.business,
      targetId: businessScopeId,
      demoReporterReference: kDemoComplaintReporterA,
      category: BusinessComplaintCategory.other,
      description: 'Demo: dismissed as out of scope for this preview.',
      syntheticEvidenceReferences: const [kDemoComplaintEvidenceBreadQuality],
      status: BusinessComplaintStatus.dismissed,
      provenance: BusinessReviewProvenance.syntheticDemo,
      createdAt: kDemoComplaintEpoch.add(const Duration(days: 2)),
      updatedAt: kDemoComplaintEpoch.add(const Duration(days: 2, hours: 1)),
      resolutionNote: 'Demo dismiss — not an authoritative decision.',
      dataSource: BusinessCatalogProductDataSource.demoSeed,
    ),
    BusinessComplaint(
      complaintId: kDemoComplaintWithDisputeId,
      businessScopeId: businessScopeId,
      branchId: kDemoBranchTashkentCenterId,
      targetType: BusinessReviewTargetType.product,
      targetId: kDemoCatalogProductBreadId,
      demoReporterReference: kDemoComplaintReporterB,
      category: BusinessComplaintCategory.productQuality,
      description: 'Demo: complaint linked to an open demo dispute.',
      syntheticEvidenceReferences: const [kDemoComplaintEvidenceBreadQuality],
      status: BusinessComplaintStatus.underReview,
      provenance: BusinessReviewProvenance.syntheticDemo,
      createdAt: kDemoComplaintEpoch.add(const Duration(hours: 6)),
      updatedAt: kDemoComplaintEpoch.add(const Duration(hours: 7)),
      dataSource: BusinessCatalogProductDataSource.demoSeed,
    ),
  ];
}

List<BusinessDispute> buildDemoBusinessDisputes({
  required String businessScopeId,
}) {
  return [
    BusinessDispute(
      disputeId: kDemoDisputeFiledId,
      businessScopeId: businessScopeId,
      branchId: kDemoBranchTashkentCenterId,
      complaintId: kDemoComplaintWithDisputeId,
      demoBusinessInitiatorReference: kDemoDisputeBusinessInitiator,
      summary: 'Demo: business disputes synthetic complaint outcome.',
      syntheticEvidenceReferences: const [kDemoDisputeEvidenceCounterClaim],
      status: BusinessDisputeStatus.filed,
      provenance: BusinessReviewProvenance.syntheticDemo,
      createdAt: kDemoComplaintEpoch.add(const Duration(hours: 8)),
      updatedAt: kDemoComplaintEpoch.add(const Duration(hours: 8)),
      dataSource: BusinessCatalogProductDataSource.demoSeed,
    ),
    BusinessDispute(
      disputeId: kDemoDisputeUnderReviewId,
      businessScopeId: businessScopeId,
      branchId: kDemoBranchTashkentCenterId,
      complaintId: kDemoComplaintUnderReviewId,
      demoBusinessInitiatorReference: kDemoDisputeBusinessInitiator,
      summary: 'Demo: under review — operator preview only.',
      syntheticEvidenceReferences: const [kDemoDisputeEvidenceCounterClaim],
      status: BusinessDisputeStatus.underReview,
      provenance: BusinessReviewProvenance.syntheticDemo,
      createdAt: kDemoComplaintEpoch.add(const Duration(hours: 4)),
      updatedAt: kDemoComplaintEpoch.add(const Duration(hours: 5)),
      dataSource: BusinessCatalogProductDataSource.demoSeed,
    ),
    BusinessDispute(
      disputeId: kDemoDisputeResolvedBusinessId,
      businessScopeId: businessScopeId,
      branchId: kDemoBranchSamarkandId,
      complaintId: kDemoComplaintResolvedId,
      demoBusinessInitiatorReference: kDemoDisputeBusinessInitiator,
      summary: 'Demo: resolved in favor of business (preview).',
      syntheticEvidenceReferences: const [kDemoDisputeEvidenceCounterClaim],
      status: BusinessDisputeStatus.resolvedForBusiness,
      provenance: BusinessReviewProvenance.syntheticDemo,
      createdAt: kDemoComplaintEpoch.add(const Duration(days: 1, hours: 2)),
      updatedAt: kDemoComplaintEpoch.add(const Duration(days: 1, hours: 5)),
      resolvedAt: kDemoComplaintEpoch.add(const Duration(days: 1, hours: 5)),
      resolutionNote: 'Demo resolution — not a legal or payment outcome.',
      dataSource: BusinessCatalogProductDataSource.demoSeed,
    ),
  ];
}

Map<String, List<BusinessComplaintHistoryEvent>> buildDemoBusinessComplaintHistory({
  required List<BusinessComplaint> complaints,
}) {
  final map = <String, List<BusinessComplaintHistoryEvent>>{};
  for (final c in complaints) {
    map[c.complaintId] = [
      BusinessComplaintHistoryEvent(
        eventId: '${c.complaintId}-created',
        complaintId: c.complaintId,
        action: BusinessComplaintHistoryAction.created,
        newStatus: BusinessComplaintStatus.submitted,
        recordedAt: c.createdAt,
      ),
      if (c.status != BusinessComplaintStatus.submitted)
        BusinessComplaintHistoryEvent(
          eventId: '${c.complaintId}-status',
          complaintId: c.complaintId,
          action: BusinessComplaintHistoryAction.statusChanged,
          previousStatus: BusinessComplaintStatus.submitted,
          newStatus: c.status == BusinessComplaintStatus.underReview
              ? BusinessComplaintStatus.underReview
              : c.status,
          recordedAt: c.updatedAt,
        ),
    ];
  }
  return map;
}

Map<String, List<BusinessDisputeHistoryEvent>> buildDemoBusinessDisputeHistory({
  required List<BusinessDispute> disputes,
}) {
  final map = <String, List<BusinessDisputeHistoryEvent>>{};
  for (final d in disputes) {
    map[d.disputeId] = [
      BusinessDisputeHistoryEvent(
        eventId: '${d.disputeId}-created',
        disputeId: d.disputeId,
        complaintId: d.complaintId,
        action: BusinessDisputeHistoryAction.created,
        newStatus: BusinessDisputeStatus.filed,
        recordedAt: d.createdAt,
      ),
      if (d.status != BusinessDisputeStatus.filed)
        BusinessDisputeHistoryEvent(
          eventId: '${d.disputeId}-status',
          disputeId: d.disputeId,
          complaintId: d.complaintId,
          action: BusinessDisputeHistoryAction.statusChanged,
          previousStatus: BusinessDisputeStatus.filed,
          newStatus: d.status,
          recordedAt: d.updatedAt,
          reason: d.resolutionNote,
        ),
    ];
  }
  return map;
}

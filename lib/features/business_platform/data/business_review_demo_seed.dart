import 'package:qoshni/features/business_platform/data/business_catalog_inventory_demo_seed.dart';
import 'package:qoshni/features/business_platform/data/business_catalog_product_demo_seed.dart';
import 'package:qoshni/features/business_platform/data/business_catalog_service_demo_seed.dart';
import 'package:qoshni/features/business_platform/data/business_review_demo_transaction_evidence.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_product.dart';
import 'package:qoshni/features/business_platform/domain/business_review.dart';
import 'package:qoshni/features/business_platform/domain/business_review_history_event.dart';
import 'package:qoshni/features/business_platform/domain/business_review_provenance.dart';
import 'package:qoshni/features/business_platform/domain/business_review_status.dart';
import 'package:qoshni/features/business_platform/domain/business_review_target_type.dart';

const String kDemoReviewPublishedBreadId = 'demo-review-published-bread-001';
const String kDemoReviewPublishedPlovId = 'demo-review-published-plov-002';
const String kDemoReviewPublishedServiceId = 'demo-review-published-service-003';
const String kDemoReviewPendingId = 'demo-review-pending-004';
const String kDemoReviewRejectedId = 'demo-review-rejected-005';
const String kDemoReviewHiddenId = 'demo-review-hidden-006';
const String kDemoReviewDuplicateSeedId = 'demo-review-duplicate-evidence-007';

final DateTime kDemoReviewEpoch = DateTime.utc(2025, 2, 1, 10, 0, 0);

List<BusinessReview> buildDemoBusinessReviews({
  required String businessScopeId,
}) {
  return [
    _seed(
      reviewId: kDemoReviewPublishedBreadId,
      businessScopeId: businessScopeId,
      branchId: kDemoBranchTashkentCenterId,
      targetType: BusinessReviewTargetType.product,
      targetId: kDemoCatalogProductBreadId,
      reviewer: kDemoReviewReviewerA,
      evidence: kDemoReviewTxEvidenceBreadCompleted,
      rating: 5,
      title: 'Demo — great bread',
      text: 'Synthetic completed purchase; demo review only.',
      status: BusinessReviewStatus.published,
      moderatedAt: kDemoReviewEpoch.add(const Duration(hours: 2)),
    ),
    _seed(
      reviewId: kDemoReviewPublishedPlovId,
      businessScopeId: businessScopeId,
      branchId: kDemoBranchTashkentCenterId,
      targetType: BusinessReviewTargetType.product,
      targetId: kDemoCatalogProductPlovId,
      reviewer: kDemoReviewReviewerB,
      evidence: 'demo-tx-evidence-plov-completed',
      rating: 4,
      title: 'Demo — tasty plov',
      text: 'Another synthetic transaction review.',
      status: BusinessReviewStatus.published,
      moderatedAt: kDemoReviewEpoch.add(const Duration(hours: 3)),
    ),
    _seed(
      reviewId: kDemoReviewPublishedServiceId,
      businessScopeId: businessScopeId,
      branchId: kDemoBranchTashkentCenterId,
      targetType: BusinessReviewTargetType.service,
      targetId: kDemoCatalogServicePackingId,
      reviewer: kDemoReviewReviewerB,
      evidence: kDemoReviewTxEvidencePackingCompleted,
      rating: 3,
      status: BusinessReviewStatus.published,
      moderatedAt: kDemoReviewEpoch.add(const Duration(hours: 4)),
    ),
    _seed(
      reviewId: kDemoReviewPendingId,
      businessScopeId: businessScopeId,
      branchId: kDemoBranchSamarkandId,
      targetType: BusinessReviewTargetType.business,
      targetId: businessScopeId,
      reviewer: kDemoReviewReviewerC,
      evidence: kDemoReviewTxEvidenceBusinessCompleted,
      rating: 5,
      title: 'Demo — pending moderation',
      text: 'Awaiting demo moderation action.',
      status: BusinessReviewStatus.pendingModeration,
    ),
    _seed(
      reviewId: kDemoReviewRejectedId,
      businessScopeId: businessScopeId,
      branchId: kDemoBranchTashkentCenterId,
      targetType: BusinessReviewTargetType.product,
      targetId: kDemoCatalogProductDailyBasketId,
      reviewer: kDemoReviewReviewerC,
      evidence: 'demo-tx-evidence-basket-rejected',
      rating: 1,
      text: 'Demo rejected review — not in summary.',
      status: BusinessReviewStatus.rejected,
      moderationReason: 'Demo moderation rejection',
      moderatedAt: kDemoReviewEpoch.add(const Duration(hours: 6)),
    ),
    _seed(
      reviewId: kDemoReviewHiddenId,
      businessScopeId: businessScopeId,
      branchId: kDemoBranchTashkentCenterId,
      targetType: BusinessReviewTargetType.product,
      targetId: kDemoCatalogProductBreadId,
      reviewer: 'demo-reviewer-ref-hidden',
      evidence: 'demo-tx-evidence-bread-hidden',
      rating: 2,
      status: BusinessReviewStatus.hidden,
      moderationReason: 'Demo hidden',
      moderatedAt: kDemoReviewEpoch.add(const Duration(hours: 7)),
    ),
    _seed(
      reviewId: kDemoReviewDuplicateSeedId,
      businessScopeId: businessScopeId,
      branchId: kDemoBranchTashkentCenterId,
      targetType: BusinessReviewTargetType.product,
      targetId: kDemoCatalogProductPlovId,
      reviewer: kDemoReviewReviewerB,
      evidence: kDemoReviewTxEvidenceDuplicateTaken,
      rating: 5,
      status: BusinessReviewStatus.published,
      moderatedAt: kDemoReviewEpoch.add(const Duration(hours: 5)),
    ),
  ];
}

BusinessReview _seed({
  required String reviewId,
  required String businessScopeId,
  required String branchId,
  required BusinessReviewTargetType targetType,
  required String targetId,
  required String reviewer,
  required String evidence,
  required int rating,
  String? title,
  String? text,
  required BusinessReviewStatus status,
  String? moderationReason,
  DateTime? moderatedAt,
}) {
  return BusinessReview(
    reviewId: reviewId,
    businessScopeId: businessScopeId,
    branchId: branchId,
    targetType: targetType,
    targetId: targetId,
    demoReviewerReference: reviewer,
    transactionEvidenceReference: evidence,
    rating: rating,
    title: title,
    reviewText: text,
    status: status,
    provenance: BusinessReviewProvenance.syntheticDemo,
    createdAt: kDemoReviewEpoch,
    updatedAt: moderatedAt ?? kDemoReviewEpoch,
    moderatedAt: moderatedAt,
    moderationReason: moderationReason,
    dataSource: BusinessCatalogProductDataSource.demoSeed,
  );
}

Map<String, List<BusinessReviewHistoryEvent>> buildDemoBusinessReviewHistory({
  required List<BusinessReview> reviews,
}) {
  final map = <String, List<BusinessReviewHistoryEvent>>{};
  for (final review in reviews) {
    map[review.reviewId] = [
      BusinessReviewHistoryEvent(
        eventId: '${review.reviewId}-created',
        reviewId: review.reviewId,
        action: BusinessReviewHistoryAction.created,
        newStatus: BusinessReviewStatus.draft,
        recordedAt: review.createdAt,
      ),
      if (review.status != BusinessReviewStatus.draft)
        BusinessReviewHistoryEvent(
          eventId: '${review.reviewId}-status',
          reviewId: review.reviewId,
          action: BusinessReviewHistoryAction.statusChanged,
          previousStatus: BusinessReviewStatus.draft,
          newStatus: review.status,
          recordedAt: review.moderatedAt ?? review.updatedAt,
          reason: review.moderationReason,
        ),
    ];
  }
  return map;
}

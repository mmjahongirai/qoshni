import 'package:qoshni/features/business_platform/domain/business_catalog_product.dart';
import 'package:qoshni/features/business_platform/domain/business_review_provenance.dart';
import 'package:qoshni/features/business_platform/domain/business_review_status.dart';
import 'package:qoshni/features/business_platform/domain/business_review_target_type.dart';

class BusinessReview {
  const BusinessReview({
    required this.reviewId,
    required this.businessScopeId,
    this.branchId,
    required this.targetType,
    required this.targetId,
    required this.demoReviewerReference,
    required this.transactionEvidenceReference,
    required this.rating,
    this.title,
    this.reviewText,
    required this.status,
    required this.provenance,
    required this.createdAt,
    required this.updatedAt,
    this.moderatedAt,
    this.moderationReason,
    required this.dataSource,
  });

  final String reviewId;
  final String businessScopeId;
  final String? branchId;
  final BusinessReviewTargetType targetType;
  final String targetId;
  final String demoReviewerReference;
  final String transactionEvidenceReference;
  final int rating;
  final String? title;
  final String? reviewText;
  final BusinessReviewStatus status;
  final BusinessReviewProvenance provenance;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? moderatedAt;
  final String? moderationReason;
  final BusinessCatalogProductDataSource dataSource;

  bool get isSyntheticDemo =>
      provenance == BusinessReviewProvenance.syntheticDemo;

  BusinessReview copyWith({
    BusinessReviewStatus? status,
    DateTime? updatedAt,
    DateTime? moderatedAt,
    String? moderationReason,
    bool clearModerationReason = false,
  }) {
    return BusinessReview(
      reviewId: reviewId,
      businessScopeId: businessScopeId,
      branchId: branchId,
      targetType: targetType,
      targetId: targetId,
      demoReviewerReference: demoReviewerReference,
      transactionEvidenceReference: transactionEvidenceReference,
      rating: rating,
      title: title,
      reviewText: reviewText,
      status: status ?? this.status,
      provenance: provenance,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      moderatedAt: moderatedAt ?? this.moderatedAt,
      moderationReason: clearModerationReason
          ? null
          : (moderationReason ?? this.moderationReason),
      dataSource: dataSource,
    );
  }
}

class BusinessReviewCreateInput {
  const BusinessReviewCreateInput({
    this.branchId,
    required this.targetType,
    required this.targetId,
    required this.demoReviewerReference,
    required this.transactionEvidenceReference,
    required this.rating,
    this.title,
    this.reviewText,
  });

  final String? branchId;
  final BusinessReviewTargetType targetType;
  final String targetId;
  final String demoReviewerReference;
  final String transactionEvidenceReference;
  final int rating;
  final String? title;
  final String? reviewText;
}

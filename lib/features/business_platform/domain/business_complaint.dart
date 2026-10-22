import 'package:qoshni/features/business_platform/domain/business_catalog_product.dart';
import 'package:qoshni/features/business_platform/domain/business_complaint_category.dart';
import 'package:qoshni/features/business_platform/domain/business_complaint_status.dart';
import 'package:qoshni/features/business_platform/domain/business_review_provenance.dart';
import 'package:qoshni/features/business_platform/domain/business_review_target_type.dart';

class BusinessComplaint {
  const BusinessComplaint({
    required this.complaintId,
    required this.businessScopeId,
    this.branchId,
    required this.targetType,
    required this.targetId,
    required this.demoReporterReference,
    required this.category,
    required this.description,
    required this.syntheticEvidenceReferences,
    this.relatedReviewId,
    required this.status,
    required this.provenance,
    required this.createdAt,
    required this.updatedAt,
    this.resolvedAt,
    this.resolutionNote,
    required this.dataSource,
  });

  final String complaintId;
  final String businessScopeId;
  final String? branchId;
  final BusinessReviewTargetType targetType;
  final String targetId;
  final String demoReporterReference;
  final BusinessComplaintCategory category;
  final String description;
  final List<String> syntheticEvidenceReferences;
  final String? relatedReviewId;
  final BusinessComplaintStatus status;
  final BusinessReviewProvenance provenance;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? resolvedAt;
  final String? resolutionNote;
  final BusinessCatalogProductDataSource dataSource;

  bool get isSyntheticDemo =>
      provenance == BusinessReviewProvenance.syntheticDemo;

  BusinessComplaint copyWith({
    BusinessComplaintStatus? status,
    DateTime? updatedAt,
    DateTime? resolvedAt,
    bool clearResolvedAt = false,
    String? resolutionNote,
    bool clearResolutionNote = false,
  }) {
    return BusinessComplaint(
      complaintId: complaintId,
      businessScopeId: businessScopeId,
      branchId: branchId,
      targetType: targetType,
      targetId: targetId,
      demoReporterReference: demoReporterReference,
      category: category,
      description: description,
      syntheticEvidenceReferences: syntheticEvidenceReferences,
      relatedReviewId: relatedReviewId,
      status: status ?? this.status,
      provenance: provenance,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      resolvedAt: clearResolvedAt ? null : (resolvedAt ?? this.resolvedAt),
      resolutionNote: clearResolutionNote
          ? null
          : (resolutionNote ?? this.resolutionNote),
      dataSource: dataSource,
    );
  }
}

class BusinessComplaintCreateInput {
  const BusinessComplaintCreateInput({
    this.branchId,
    required this.targetType,
    required this.targetId,
    required this.demoReporterReference,
    required this.category,
    required this.description,
    required this.syntheticEvidenceReferences,
    this.relatedReviewId,
  });

  final String? branchId;
  final BusinessReviewTargetType targetType;
  final String targetId;
  final String demoReporterReference;
  final BusinessComplaintCategory category;
  final String description;
  final List<String> syntheticEvidenceReferences;
  final String? relatedReviewId;
}

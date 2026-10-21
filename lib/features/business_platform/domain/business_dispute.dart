import 'package:qoshni/features/business_platform/domain/business_catalog_product.dart';
import 'package:qoshni/features/business_platform/domain/business_dispute_status.dart';
import 'package:qoshni/features/business_platform/domain/business_review_provenance.dart';

class BusinessDispute {
  const BusinessDispute({
    required this.disputeId,
    required this.businessScopeId,
    this.branchId,
    required this.complaintId,
    required this.demoBusinessInitiatorReference,
    required this.summary,
    required this.syntheticEvidenceReferences,
    required this.status,
    required this.provenance,
    required this.createdAt,
    required this.updatedAt,
    this.resolvedAt,
    this.resolutionNote,
    required this.dataSource,
  });

  final String disputeId;
  final String businessScopeId;
  final String? branchId;
  final String complaintId;
  final String demoBusinessInitiatorReference;
  final String summary;
  final List<String> syntheticEvidenceReferences;
  final BusinessDisputeStatus status;
  final BusinessReviewProvenance provenance;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? resolvedAt;
  final String? resolutionNote;
  final BusinessCatalogProductDataSource dataSource;

  bool get isSyntheticDemo =>
      provenance == BusinessReviewProvenance.syntheticDemo;

  BusinessDispute copyWith({
    BusinessDisputeStatus? status,
    DateTime? updatedAt,
    DateTime? resolvedAt,
    bool clearResolvedAt = false,
    String? resolutionNote,
    bool clearResolutionNote = false,
  }) {
    return BusinessDispute(
      disputeId: disputeId,
      businessScopeId: businessScopeId,
      branchId: branchId,
      complaintId: complaintId,
      demoBusinessInitiatorReference: demoBusinessInitiatorReference,
      summary: summary,
      syntheticEvidenceReferences: syntheticEvidenceReferences,
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

class BusinessDisputeCreateInput {
  const BusinessDisputeCreateInput({
    required this.complaintId,
    required this.demoBusinessInitiatorReference,
    required this.summary,
    required this.syntheticEvidenceReferences,
  });

  final String complaintId;
  final String demoBusinessInitiatorReference;
  final String summary;
  final List<String> syntheticEvidenceReferences;
}

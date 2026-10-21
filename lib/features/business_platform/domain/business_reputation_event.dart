import 'package:qoshni/features/business_platform/domain/business_catalog_product.dart';
import 'package:qoshni/features/business_platform/domain/business_reputation_event_source_domain.dart';
import 'package:qoshni/features/business_platform/domain/business_reputation_event_type.dart';
import 'package:qoshni/features/business_platform/domain/business_review_provenance.dart';
import 'package:qoshni/features/business_platform/domain/business_review_target_type.dart';

class BusinessReputationEvent {
  const BusinessReputationEvent({
    required this.reputationEventId,
    required this.businessScopeId,
    this.branchId,
    required this.targetType,
    required this.targetId,
    required this.eventType,
    required this.sourceDomain,
    required this.sourceRecordId,
    this.previousStatusLabel,
    this.newStatusLabel,
    required this.correlationReferenceId,
    required this.provenance,
    required this.occurredAt,
    required this.recordedAt,
    required this.dataSource,
    this.metadataSummary,
  });

  final String reputationEventId;
  final String businessScopeId;
  final String? branchId;
  final BusinessReviewTargetType targetType;
  final String targetId;
  final BusinessReputationEventType eventType;
  final BusinessReputationEventSourceDomain sourceDomain;
  final String sourceRecordId;
  final String? previousStatusLabel;
  final String? newStatusLabel;
  final String correlationReferenceId;
  final BusinessReviewProvenance provenance;
  final DateTime occurredAt;
  final DateTime recordedAt;
  final BusinessCatalogProductDataSource dataSource;
  final String? metadataSummary;

  bool get isSyntheticDemo =>
      provenance == BusinessReviewProvenance.syntheticDemo;
}

class BusinessReputationEventRecordInput {
  const BusinessReputationEventRecordInput({
    required this.businessScopeId,
    this.branchId,
    required this.targetType,
    required this.targetId,
    required this.eventType,
    required this.sourceDomain,
    required this.sourceRecordId,
    this.previousStatusLabel,
    this.newStatusLabel,
    required this.correlationReferenceId,
    required this.provenance,
    required this.occurredAt,
    this.metadataSummary,
  });

  final String businessScopeId;
  final String? branchId;
  final BusinessReviewTargetType targetType;
  final String targetId;
  final BusinessReputationEventType eventType;
  final BusinessReputationEventSourceDomain sourceDomain;
  final String sourceRecordId;
  final String? previousStatusLabel;
  final String? newStatusLabel;
  final String correlationReferenceId;
  final BusinessReviewProvenance provenance;
  final DateTime occurredAt;
  final String? metadataSummary;
}

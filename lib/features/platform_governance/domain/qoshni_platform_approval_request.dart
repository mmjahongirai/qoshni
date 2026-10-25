import 'package:qoshni/features/notifications/domain/qoshni_notification_provenance.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_approval_proposal_type.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_approval_request_status.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_permission.dart';

class QoshniPlatformApprovalRequest {
  const QoshniPlatformApprovalRequest({
    required this.requestId,
    required this.proposalType,
    required this.status,
    required this.requesterAdminReference,
    required this.targetReference,
    required this.requiredPermission,
    required this.reasonCode,
    required this.createdAt,
    required this.updatedAt,
    this.deciderAdminReference,
    this.decisionReasonCode,
    this.decidedAt,
    this.businessReference,
    this.isSeedRecord = false,
  });

  final String requestId;
  final QoshniPlatformApprovalProposalType proposalType;
  final QoshniPlatformApprovalRequestStatus status;
  final String requesterAdminReference;
  final String targetReference;
  final QoshniPlatformPermission requiredPermission;
  final String reasonCode;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? deciderAdminReference;
  final String? decisionReasonCode;
  final DateTime? decidedAt;
  final String? businessReference;
  final bool isSeedRecord;

  QoshniNotificationProvenance get provenance =>
      QoshniNotificationProvenance.syntheticDemo;
}

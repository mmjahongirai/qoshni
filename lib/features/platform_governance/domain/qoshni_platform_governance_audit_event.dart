import 'package:qoshni/features/notifications/domain/qoshni_notification_provenance.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_authorization_reason.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_governance_audit_entity_type.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_governance_audit_operation_type.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_governance_audit_outcome.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_permission.dart';

class QoshniPlatformGovernanceAuditEvent {
  const QoshniPlatformGovernanceAuditEvent({
    required this.auditEventId,
    required this.recordedAt,
    required this.actorAdminReference,
    required this.operationType,
    required this.entityType,
    required this.targetReference,
    required this.permission,
    required this.authorizationAllowed,
    required this.authorizationReason,
    required this.outcome,
    required this.correlationReference,
    required this.safeSummary,
    this.businessReference,
    this.branchReference,
    this.isSeedRecord = false,
  });

  final String auditEventId;
  final DateTime recordedAt;
  final String actorAdminReference;
  final QoshniPlatformGovernanceAuditOperationType operationType;
  final QoshniPlatformGovernanceAuditEntityType entityType;
  final String targetReference;
  final QoshniPlatformPermission permission;
  final bool authorizationAllowed;
  final QoshniPlatformAuthorizationReason authorizationReason;
  final QoshniPlatformGovernanceAuditOutcome outcome;
  final String correlationReference;
  final String safeSummary;
  final String? businessReference;
  final String? branchReference;
  final bool isSeedRecord;

  QoshniNotificationProvenance get provenance =>
      QoshniNotificationProvenance.syntheticDemo;
}

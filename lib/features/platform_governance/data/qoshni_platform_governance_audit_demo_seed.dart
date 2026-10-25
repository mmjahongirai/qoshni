import 'package:qoshni/features/platform_governance/data/qoshni_platform_governance_demo_seed.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_authorization_reason.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_governance_audit_entity_type.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_governance_audit_event.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_governance_audit_operation_type.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_governance_audit_outcome.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_permission.dart';

/// Clearly labelled synthetic demo audit history — not production records.
List<QoshniPlatformGovernanceAuditEvent>
    buildQoshniPlatformGovernanceAuditDemoSeed() {
  final epoch = kDemoPlatformGovernanceEpoch.add(const Duration(hours: 1));
  return [
    QoshniPlatformGovernanceAuditEvent(
      auditEventId: 'gov-audit-seed-001',
      recordedAt: epoch,
      actorAdminReference: 'demo-platform-admin-verifier',
      operationType: QoshniPlatformGovernanceAuditOperationType.statusTransition,
      entityType:
          QoshniPlatformGovernanceAuditEntityType.businessVerificationSubmission,
      targetReference: 'bver-demo-001',
      permission: QoshniPlatformPermission.reviewBusinessVerificationSubmissions,
      authorizationAllowed: true,
      authorizationReason:
          QoshniPlatformAuthorizationReason.allowedExplicitGrant,
      outcome: QoshniPlatformGovernanceAuditOutcome.mutationSucceeded,
      correlationReference: 'seed-bver-001-transition',
      safeSummary: 'Seed demo: verification submission moved to under review.',
      businessReference: kDemoPlatformGovernanceBusinessA,
      isSeedRecord: true,
    ),
    QoshniPlatformGovernanceAuditEvent(
      auditEventId: 'gov-audit-seed-002',
      recordedAt: epoch.add(const Duration(minutes: 5)),
      actorAdminReference: 'demo-platform-admin-moderator',
      operationType: QoshniPlatformGovernanceAuditOperationType.statusTransition,
      entityType: QoshniPlatformGovernanceAuditEntityType.moderationCase,
      targetReference: 'mod-demo-001',
      permission: QoshniPlatformPermission.performPermittedModerationActions,
      authorizationAllowed: true,
      authorizationReason:
          QoshniPlatformAuthorizationReason.allowedExplicitGrant,
      outcome: QoshniPlatformGovernanceAuditOutcome.mutationSucceeded,
      correlationReference: 'seed-mod-001-transition',
      safeSummary: 'Seed demo: moderation case triaged.',
      isSeedRecord: true,
    ),
  ];
}

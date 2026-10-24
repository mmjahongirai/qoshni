import 'package:qoshni/features/platform_governance/application/qoshni_platform_governance_audit_service.dart';
import 'package:qoshni/features/platform_governance/application/qoshni_platform_governance_write_result.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_authorization_decision.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_governance_audit_entity_type.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_governance_audit_operation_type.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_permission.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_resource_scope.dart';

class QoshniPlatformGovernanceWorkflowAudit {
  const QoshniPlatformGovernanceWorkflowAudit(this._auditService);

  final QoshniPlatformGovernanceAuditService? _auditService;

  bool recordAuthorizationDenied({
    required String adminId,
    required QoshniPlatformGovernanceAuditOperationType operationType,
    required QoshniPlatformGovernanceAuditEntityType entityType,
    required String targetReference,
    required QoshniPlatformPermission permission,
    required QoshniPlatformAuthorizationDecision decision,
    required String correlationReference,
    required String safeSummary,
    required DateTime recordedAtUtc,
    QoshniPlatformResourceScope? scope,
  }) {
    final audit = _auditService;
    if (audit == null) {
      return true;
    }
    return audit.recordAuthorizationDenied(
      adminId: adminId,
      operationType: operationType,
      entityType: entityType,
      targetReference: targetReference,
      permission: permission,
      decision: decision,
      correlationReference: correlationReference,
      safeSummary: safeSummary,
      recordedAtUtc: recordedAtUtc,
      scope: scope,
    );
  }

  QoshniPlatformGovernanceWriteResult finalizeMutation({
    required String adminId,
    required QoshniPlatformGovernanceAuditOperationType operationType,
    required QoshniPlatformGovernanceAuditEntityType entityType,
    required String targetReference,
    required QoshniPlatformPermission permission,
    required QoshniPlatformAuthorizationDecision decision,
    required bool mutationSucceeded,
    required QoshniPlatformGovernanceWriteOutcome baseOutcome,
    required String correlationReference,
    required String safeSummary,
    required DateTime recordedAtUtc,
    QoshniPlatformResourceScope? scope,
  }) {
    final audit = _auditService;
    if (audit == null) {
      return QoshniPlatformGovernanceWriteResult(
        outcome: baseOutcome,
        authorizationDecision: decision,
      );
    }
    if (baseOutcome == QoshniPlatformGovernanceWriteOutcome.success ||
        baseOutcome == QoshniPlatformGovernanceWriteOutcome.failure ||
        baseOutcome == QoshniPlatformGovernanceWriteOutcome.invalidTransition) {
      final recorded = audit.recordMutationOutcome(
        adminId: adminId,
        operationType: operationType,
        entityType: entityType,
        targetReference: targetReference,
        permission: permission,
        decision: decision,
        mutationSucceeded: mutationSucceeded,
        correlationReference: correlationReference,
        safeSummary: safeSummary,
        recordedAtUtc: recordedAtUtc,
        scope: scope,
      );
      if (!recorded &&
          mutationSucceeded &&
          baseOutcome == QoshniPlatformGovernanceWriteOutcome.success) {
        return QoshniPlatformGovernanceWriteResult(
          outcome: QoshniPlatformGovernanceWriteOutcome.auditPersistFailure,
          authorizationDecision: decision,
          auditRecorded: false,
        );
      }
      return QoshniPlatformGovernanceWriteResult(
        outcome: baseOutcome,
        authorizationDecision: decision,
        auditRecorded: recorded,
      );
    }
    return QoshniPlatformGovernanceWriteResult(
      outcome: baseOutcome,
      authorizationDecision: decision,
    );
  }
}

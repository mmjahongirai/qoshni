import 'package:qoshni/features/platform_governance/domain/qoshni_platform_authorization_decision.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_authorization_reason.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_governance_audit_entity_type.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_governance_audit_event.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_governance_audit_operation_type.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_governance_audit_outcome.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_permission.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_resource_scope.dart';
import 'package:qoshni/features/platform_governance/domain/repositories/qoshni_platform_governance_audit_repository.dart';
import 'package:qoshni/features/platform_governance/domain/repositories/qoshni_platform_governance_repository.dart';

/// Append-only platform governance audit (in-memory demo — not durable).
///
/// Ordering for privileged mutations: validate → authorize → mutate → append audit.
/// If append fails after a successful mutation, outcome is [auditPersistFailed] and
/// a separate failure event may be recorded when possible.
class QoshniPlatformGovernanceAuditService {
  QoshniPlatformGovernanceAuditService({
    required QoshniPlatformGovernanceAuditRepository auditRepository,
    required QoshniPlatformGovernanceRepository governanceRepository,
  })  : _auditRepository = auditRepository,
        _governanceRepository = governanceRepository;

  final QoshniPlatformGovernanceAuditRepository _auditRepository;
  final QoshniPlatformGovernanceRepository _governanceRepository;

  int _counter = 0;

  String nextAuditEventId() {
    _counter++;
    return 'gov-audit-${_counter.toString().padLeft(5, '0')}';
  }

  bool appendEvent(QoshniPlatformGovernanceAuditEvent event) {
    return _auditRepository.append(event) ==
        QoshniPlatformGovernanceAuditAppendResult.success;
  }

  QoshniPlatformGovernanceAuditEvent buildEvent({
    required String adminId,
    required QoshniPlatformGovernanceAuditOperationType operationType,
    required QoshniPlatformGovernanceAuditEntityType entityType,
    required String targetReference,
    required QoshniPlatformPermission permission,
    required QoshniPlatformAuthorizationDecision decision,
    required QoshniPlatformGovernanceAuditOutcome outcome,
    required String correlationReference,
    required String safeSummary,
    required DateTime recordedAtUtc,
    QoshniPlatformResourceScope? scope,
    bool isSeedRecord = false,
  }) {
    final actor = _governanceRepository.findAdmin(adminId)?.syntheticReference ??
        'demo-platform-admin-unknown';
    return QoshniPlatformGovernanceAuditEvent(
      auditEventId: nextAuditEventId(),
      recordedAt: recordedAtUtc.toUtc(),
      actorAdminReference: actor,
      operationType: operationType,
      entityType: entityType,
      targetReference: targetReference,
      permission: permission,
      authorizationAllowed: decision.isAllowed,
      authorizationReason: decision.reason,
      outcome: outcome,
      correlationReference: correlationReference.trim(),
      safeSummary: safeSummary,
      businessReference: scope?.businessReference,
      branchReference: scope?.branchReference,
      isSeedRecord: isSeedRecord,
    );
  }

  /// Records authorization denial without domain mutation.
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
    final event = buildEvent(
      adminId: adminId,
      operationType: operationType,
      entityType: entityType,
      targetReference: targetReference,
      permission: permission,
      decision: decision,
      outcome: QoshniPlatformGovernanceAuditOutcome.deniedAuthorization,
      correlationReference: correlationReference,
      safeSummary: safeSummary,
      recordedAtUtc: recordedAtUtc,
      scope: scope,
    );
    return appendEvent(event);
  }

  bool recordMutationOutcome({
    required String adminId,
    required QoshniPlatformGovernanceAuditOperationType operationType,
    required QoshniPlatformGovernanceAuditEntityType entityType,
    required String targetReference,
    required QoshniPlatformPermission permission,
    required QoshniPlatformAuthorizationDecision decision,
    required bool mutationSucceeded,
    required String correlationReference,
    required String safeSummary,
    required DateTime recordedAtUtc,
    QoshniPlatformResourceScope? scope,
  }) {
    final outcome = mutationSucceeded
        ? QoshniPlatformGovernanceAuditOutcome.mutationSucceeded
        : QoshniPlatformGovernanceAuditOutcome.mutationFailed;
    final event = buildEvent(
      adminId: adminId,
      operationType: operationType,
      entityType: entityType,
      targetReference: targetReference,
      permission: permission,
      decision: decision,
      outcome: outcome,
      correlationReference: correlationReference,
      safeSummary: safeSummary,
      recordedAtUtc: recordedAtUtc,
      scope: scope,
    );
    final appended = appendEvent(event);
    if (!appended) {
      recordAuditAppendFailure(
        adminId: adminId,
        correlationReference: '$correlationReference-audit-fail',
        recordedAtUtc: recordedAtUtc,
        relatedTarget: targetReference,
      );
    }
    return appended;
  }

  void recordAuditAppendFailure({
    required String adminId,
    required String correlationReference,
    required DateTime recordedAtUtc,
    required String relatedTarget,
  }) {
    if (_auditRepository.hasCorrelationReference(correlationReference)) {
      return;
    }
    final decision = const QoshniPlatformAuthorizationDecision(
      isAllowed: false,
      reason: QoshniPlatformAuthorizationReason.deniedInvalidInput,
      permission: QoshniPlatformPermission.viewAuditRecords,
    );
    appendEvent(
      buildEvent(
        adminId: adminId,
        operationType:
            QoshniPlatformGovernanceAuditOperationType.auditAppendFailure,
        entityType: QoshniPlatformGovernanceAuditEntityType.governanceSession,
        targetReference: relatedTarget,
        permission: QoshniPlatformPermission.viewAuditRecords,
        decision: decision,
        outcome: QoshniPlatformGovernanceAuditOutcome.auditPersistFailed,
        correlationReference: correlationReference,
        safeSummary: 'Demo audit append failed — event not durable.',
        recordedAtUtc: recordedAtUtc,
      ),
    );
  }
}

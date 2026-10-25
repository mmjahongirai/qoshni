import 'package:flutter/foundation.dart';
import 'package:qoshni/features/platform_governance/application/qoshni_platform_governance_audit_service.dart';
import 'package:qoshni/features/platform_governance/application/qoshni_platform_governance_authorizer.dart';
import 'package:qoshni/features/platform_governance/application/qoshni_platform_governance_workflow_audit.dart';
import 'package:qoshni/features/platform_governance/application/qoshni_platform_governance_write_result.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_governance_audit_entity_type.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_governance_audit_operation_type.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_governance_history_entry.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_authorization_decision.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_permission.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_resource_scope.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_support_case.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_support_case_status.dart';
import 'package:qoshni/features/platform_governance/domain/repositories/qoshni_platform_governance_repository.dart';
import 'package:qoshni/features/platform_governance/domain/repositories/qoshni_platform_support_case_repository.dart';
import 'package:qoshni/features/platform_governance/presentation/qoshni_platform_governance_scope_helpers.dart';
import 'package:qoshni/features/platform_governance/presentation/qoshni_platform_workflow_validation.dart';

class QoshniPlatformSupportCaseController extends ChangeNotifier {
  QoshniPlatformSupportCaseController({
    required QoshniPlatformSupportCaseRepository repository,
    required QoshniPlatformGovernanceRepository governanceRepository,
    required QoshniPlatformGovernanceAuthorizer authorizer,
    QoshniPlatformGovernanceAuditService? auditService,
  })  : _repository = repository,
        _governanceRepository = governanceRepository,
        _authorizer = authorizer,
        _workflowAudit = QoshniPlatformGovernanceWorkflowAudit(auditService);

  final QoshniPlatformSupportCaseRepository _repository;
  final QoshniPlatformGovernanceRepository _governanceRepository;
  final QoshniPlatformGovernanceAuthorizer _authorizer;
  final QoshniPlatformGovernanceWorkflowAudit _workflowAudit;

  QoshniPlatformSupportCaseStatus? statusFilter;
  String? selectedCaseId;
  String? lastOutcomeKey;
  QoshniPlatformGovernanceWriteResult? lastWriteResult;

  List<QoshniPlatformSupportCase> get cases =>
      _repository.list(status: statusFilter);

  QoshniPlatformSupportCase? get selectedCase {
    final id = selectedCaseId;
    if (id == null) {
      return null;
    }
    return _repository.find(id);
  }

  void setStatusFilter(QoshniPlatformSupportCaseStatus? value) {
    statusFilter = value;
    notifyListeners();
  }

  void selectCase(String? caseId) {
    selectedCaseId = caseId;
    notifyListeners();
  }

  QoshniPlatformResourceScope _scopeFor(QoshniPlatformSupportCase supportCase) {
    final business = supportCase.businessReference?.trim();
    if (business == null || business.isEmpty) {
      return const QoshniPlatformResourceScope.platform();
    }
    return qoshniPlatformBusinessScope(
      businessReference: business,
      branchReference: supportCase.branchReference,
    );
  }

  QoshniPlatformAuthorizationDecision? _requireRespondAuthorization({
    required String adminId,
    required QoshniPlatformSupportCase supportCase,
    required String actionLabel,
    required QoshniPlatformGovernanceAuditOperationType operationType,
    required DateTime atUtc,
  }) {
    final scope = _scopeFor(supportCase);
    final decision = _authorizer.authorize(
      adminId: adminId,
      permission: QoshniPlatformPermission.respondToSupportCases,
      resourceScope: scope,
      actionLabel: actionLabel,
    );
    if (!decision.isAllowed) {
      lastOutcomeKey = 'authorizationDenied';
      final auditRecorded = _workflowAudit.recordAuthorizationDenied(
        adminId: adminId,
        operationType: operationType,
        entityType: QoshniPlatformGovernanceAuditEntityType.supportCase,
        targetReference: supportCase.caseId,
        permission: QoshniPlatformPermission.respondToSupportCases,
        decision: decision,
        correlationReference:
            'support-deny-${supportCase.caseId}-${atUtc.toIso8601String()}',
        safeSummary: 'Denied support action $actionLabel (demo).',
        recordedAtUtc: atUtc,
        scope: scope,
      );
      lastWriteResult = QoshniPlatformGovernanceWriteResult(
        outcome: QoshniPlatformGovernanceWriteOutcome.authorizationDenied,
        authorizationDecision: decision,
        auditRecorded: auditRecorded,
      );
      notifyListeners();
      return null;
    }
    return decision;
  }

  QoshniPlatformGovernanceWriteResult assignSelected({
    required String adminId,
    required String roleKey,
    required DateTime atUtc,
  }) {
    final supportCase = selectedCase;
    if (supportCase == null) {
      return const QoshniPlatformGovernanceWriteResult(
        outcome: QoshniPlatformGovernanceWriteOutcome.notFound,
      );
    }
    final decision = _requireRespondAuthorization(
      adminId: adminId,
      supportCase: supportCase,
      actionLabel: 'support_assign',
      operationType: QoshniPlatformGovernanceAuditOperationType.supportAssign,
      atUtc: atUtc,
    );
    if (decision == null) {
      return lastWriteResult!;
    }

    final actor = _governanceRepository.findAdmin(adminId)?.syntheticReference;
    if (actor == null) {
      return const QoshniPlatformGovernanceWriteResult(
        outcome: QoshniPlatformGovernanceWriteOutcome.invalidInput,
      );
    }

    final historyEntry = QoshniPlatformGovernanceHistoryEntry(
      recordedAt: atUtc.toUtc(),
      actorAdminReference: actor,
      operation: 'assign_role',
      fromStatus: supportCase.status.name,
      toStatus: QoshniPlatformSupportCaseStatus.assigned.name,
      reasonCode: 'demo_assign',
      note: 'Demo assignment only.',
    );

    final mutation = _repository.assignRole(
      caseId: supportCase.caseId,
      roleKey: roleKey,
      historyEntry: historyEntry,
      updatedAtUtc: atUtc,
    );
    return _mapMutation(
      mutation,
      decision,
      adminId: adminId,
      supportCase: supportCase,
      operationType: QoshniPlatformGovernanceAuditOperationType.supportAssign,
      atUtc: atUtc,
      safeSummary: 'Support case assigned (demo).',
      correlationSuffix: 'assign',
    );
  }

  QoshniPlatformGovernanceWriteResult addNoteSelected({
    required String adminId,
    required String noteBody,
    required DateTime atUtc,
    required String noteId,
  }) {
    final supportCase = selectedCase;
    if (supportCase == null) {
      return const QoshniPlatformGovernanceWriteResult(
        outcome: QoshniPlatformGovernanceWriteOutcome.notFound,
      );
    }
    if (qoshniPlatformSupportNoteValidationError(noteBody) != null) {
      return const QoshniPlatformGovernanceWriteResult(
        outcome: QoshniPlatformGovernanceWriteOutcome.invalidInput,
      );
    }

    final decision = _requireRespondAuthorization(
      adminId: adminId,
      supportCase: supportCase,
      actionLabel: 'support_add_note',
      operationType:
          QoshniPlatformGovernanceAuditOperationType.supportInternalNote,
      atUtc: atUtc,
    );
    if (decision == null) {
      return lastWriteResult!;
    }

    final actor = _governanceRepository.findAdmin(adminId)?.syntheticReference;
    if (actor == null) {
      return const QoshniPlatformGovernanceWriteResult(
        outcome: QoshniPlatformGovernanceWriteOutcome.invalidInput,
      );
    }

    final note = QoshniPlatformSupportInternalNote(
      noteId: noteId,
      authorAdminReference: actor,
      body: noteBody.trim(),
      recordedAt: atUtc.toUtc(),
    );
    final historyEntry = QoshniPlatformGovernanceHistoryEntry(
      recordedAt: atUtc.toUtc(),
      actorAdminReference: actor,
      operation: 'internal_note',
      fromStatus: supportCase.status.name,
      toStatus: supportCase.status.name,
      reasonCode: 'demo_note',
      note: 'Internal demo note added.',
    );

    final mutation = _repository.addInternalNote(
      caseId: supportCase.caseId,
      note: note,
      historyEntry: historyEntry,
      updatedAtUtc: atUtc,
    );
    return _mapMutation(
      mutation,
      decision,
      adminId: adminId,
      supportCase: supportCase,
      operationType:
          QoshniPlatformGovernanceAuditOperationType.supportInternalNote,
      atUtc: atUtc,
      safeSummary: 'Support internal note added (demo).',
      correlationSuffix: 'note-$noteId',
    );
  }

  QoshniPlatformGovernanceWriteResult transitionSelected({
    required String adminId,
    required QoshniPlatformSupportCaseStatus toStatus,
    required String reasonCode,
    required DateTime atUtc,
  }) {
    final supportCase = selectedCase;
    if (supportCase == null) {
      return const QoshniPlatformGovernanceWriteResult(
        outcome: QoshniPlatformGovernanceWriteOutcome.notFound,
      );
    }
    if (qoshniPlatformWorkflowReasonValidationError(reasonCode) != null) {
      return const QoshniPlatformGovernanceWriteResult(
        outcome: QoshniPlatformGovernanceWriteOutcome.invalidInput,
      );
    }

    final decision = _requireRespondAuthorization(
      adminId: adminId,
      supportCase: supportCase,
      actionLabel: 'support_status_transition',
      operationType:
          QoshniPlatformGovernanceAuditOperationType.statusTransition,
      atUtc: atUtc,
    );
    if (decision == null) {
      return lastWriteResult!;
    }

    final actor = _governanceRepository.findAdmin(adminId)?.syntheticReference;
    if (actor == null) {
      return const QoshniPlatformGovernanceWriteResult(
        outcome: QoshniPlatformGovernanceWriteOutcome.invalidInput,
      );
    }

    final historyEntry = QoshniPlatformGovernanceHistoryEntry(
      recordedAt: atUtc.toUtc(),
      actorAdminReference: actor,
      operation: 'status_transition',
      fromStatus: supportCase.status.name,
      toStatus: toStatus.name,
      reasonCode: reasonCode.trim(),
      note: 'Demo support status change — no customer message sent.',
    );

    final mutation = _repository.transitionStatus(
      caseId: supportCase.caseId,
      toStatus: toStatus,
      historyEntry: historyEntry,
      updatedAtUtc: atUtc,
    );
    return _mapMutation(
      mutation,
      decision,
      adminId: adminId,
      supportCase: supportCase,
      operationType:
          QoshniPlatformGovernanceAuditOperationType.statusTransition,
      atUtc: atUtc,
      safeSummary: 'Support status transition to ${toStatus.name} (demo).',
      correlationSuffix: 'status-${toStatus.name}',
    );
  }

  QoshniPlatformGovernanceWriteResult _mapMutation(
    QoshniPlatformSupportMutationResult mutation,
    QoshniPlatformAuthorizationDecision? decision, {
    required String adminId,
    required QoshniPlatformSupportCase supportCase,
    required QoshniPlatformGovernanceAuditOperationType operationType,
    required DateTime atUtc,
    required String safeSummary,
    required String correlationSuffix,
  }) {
    final writeOutcome = switch (mutation) {
      QoshniPlatformSupportMutationResult.success =>
        QoshniPlatformGovernanceWriteOutcome.success,
      QoshniPlatformSupportMutationResult.invalidTransition =>
        QoshniPlatformGovernanceWriteOutcome.invalidTransition,
      QoshniPlatformSupportMutationResult.notFound =>
        QoshniPlatformGovernanceWriteOutcome.notFound,
      QoshniPlatformSupportMutationResult.invalidInput =>
        QoshniPlatformGovernanceWriteOutcome.invalidInput,
      QoshniPlatformSupportMutationResult.failure =>
        QoshniPlatformGovernanceWriteOutcome.failure,
    };
    lastOutcomeKey = writeOutcome.name;
    lastWriteResult = _workflowAudit.finalizeMutation(
      adminId: adminId,
      operationType: operationType,
      entityType: QoshniPlatformGovernanceAuditEntityType.supportCase,
      targetReference: supportCase.caseId,
      permission: QoshniPlatformPermission.respondToSupportCases,
      decision: decision!,
      mutationSucceeded:
          writeOutcome == QoshniPlatformGovernanceWriteOutcome.success,
      baseOutcome: writeOutcome,
      correlationReference:
          'support-${supportCase.caseId}-$correlationSuffix-${atUtc.toIso8601String()}',
      safeSummary: safeSummary,
      recordedAtUtc: atUtc,
      scope: _scopeFor(supportCase),
    );
    notifyListeners();
    return lastWriteResult!;
  }
}

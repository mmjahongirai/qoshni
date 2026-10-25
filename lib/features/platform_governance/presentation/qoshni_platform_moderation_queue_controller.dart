import 'package:flutter/foundation.dart';
import 'package:qoshni/features/platform_governance/application/qoshni_platform_governance_audit_service.dart';
import 'package:qoshni/features/platform_governance/application/qoshni_platform_governance_authorizer.dart';
import 'package:qoshni/features/platform_governance/application/qoshni_platform_governance_workflow_audit.dart';
import 'package:qoshni/features/platform_governance/application/qoshni_platform_governance_write_result.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_governance_audit_entity_type.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_governance_audit_operation_type.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_governance_history_entry.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_moderation_case.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_moderation_case_status.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_permission.dart';
import 'package:qoshni/features/platform_governance/domain/repositories/qoshni_platform_governance_repository.dart';
import 'package:qoshni/features/platform_governance/domain/repositories/qoshni_platform_moderation_queue_repository.dart';
import 'package:qoshni/features/platform_governance/presentation/qoshni_platform_governance_scope_helpers.dart';
import 'package:qoshni/features/platform_governance/presentation/qoshni_platform_workflow_validation.dart';

class QoshniPlatformModerationQueueController extends ChangeNotifier {
  QoshniPlatformModerationQueueController({
    required QoshniPlatformModerationQueueRepository repository,
    required QoshniPlatformGovernanceRepository governanceRepository,
    required QoshniPlatformGovernanceAuthorizer authorizer,
    QoshniPlatformGovernanceAuditService? auditService,
  })  : _repository = repository,
        _governanceRepository = governanceRepository,
        _authorizer = authorizer,
        _workflowAudit = QoshniPlatformGovernanceWorkflowAudit(auditService);

  final QoshniPlatformModerationQueueRepository _repository;
  final QoshniPlatformGovernanceRepository _governanceRepository;
  final QoshniPlatformGovernanceAuthorizer _authorizer;
  final QoshniPlatformGovernanceWorkflowAudit _workflowAudit;

  QoshniPlatformModerationCaseStatus? statusFilter;
  String? selectedCaseId;
  String? lastOutcomeKey;
  QoshniPlatformGovernanceWriteResult? lastWriteResult;

  List<QoshniPlatformModerationCase> get cases =>
      _repository.list(status: statusFilter);

  QoshniPlatformModerationCase? get selectedCase {
    final id = selectedCaseId;
    if (id == null) {
      return null;
    }
    return _repository.find(id);
  }

  void setStatusFilter(QoshniPlatformModerationCaseStatus? value) {
    statusFilter = value;
    notifyListeners();
  }

  void selectCase(String? caseId) {
    selectedCaseId = caseId;
    notifyListeners();
  }

  QoshniPlatformGovernanceWriteResult transitionSelected({
    required String adminId,
    required QoshniPlatformModerationCaseStatus toStatus,
    required String reasonCode,
    required DateTime atUtc,
  }) {
    lastWriteResult = null;
    lastOutcomeKey = null;
    final moderationCase = selectedCase;
    if (moderationCase == null) {
      lastOutcomeKey = 'notFound';
      return const QoshniPlatformGovernanceWriteResult(
        outcome: QoshniPlatformGovernanceWriteOutcome.notFound,
      );
    }
    if (qoshniPlatformWorkflowReasonValidationError(reasonCode) != null) {
      lastOutcomeKey = 'invalidInput';
      return const QoshniPlatformGovernanceWriteResult(
        outcome: QoshniPlatformGovernanceWriteOutcome.invalidInput,
      );
    }

    final scope = qoshniPlatformBusinessScope(
      businessReference: moderationCase.businessReference,
      branchReference: moderationCase.branchReference,
    );
    final decision = _authorizer.authorize(
      adminId: adminId,
      permission: QoshniPlatformPermission.performPermittedModerationActions,
      resourceScope: scope,
      actionLabel: 'moderation_transition',
    );
    if (!decision.isAllowed) {
      lastOutcomeKey = 'authorizationDenied';
      final auditRecorded = _workflowAudit.recordAuthorizationDenied(
        adminId: adminId,
        operationType:
            QoshniPlatformGovernanceAuditOperationType.statusTransition,
        entityType: QoshniPlatformGovernanceAuditEntityType.moderationCase,
        targetReference: moderationCase.caseId,
        permission: QoshniPlatformPermission.performPermittedModerationActions,
        decision: decision,
        correlationReference:
            'mod-deny-${moderationCase.caseId}-${atUtc.toIso8601String()}',
        safeSummary: 'Denied moderation transition (demo).',
        recordedAtUtc: atUtc,
        scope: scope,
      );
      lastWriteResult = QoshniPlatformGovernanceWriteResult(
        outcome: QoshniPlatformGovernanceWriteOutcome.authorizationDenied,
        authorizationDecision: decision,
        auditRecorded: auditRecorded,
      );
      notifyListeners();
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
      fromStatus: moderationCase.status.wireValue,
      toStatus: toStatus.wireValue,
      reasonCode: reasonCode.trim(),
      note: 'Demo moderation queue transition (does not enforce platform policy).',
    );

    final mutation = _repository.transitionStatus(
      caseId: moderationCase.caseId,
      toStatus: toStatus,
      historyEntry: historyEntry,
      updatedAtUtc: atUtc,
    );

    final writeOutcome = switch (mutation) {
      QoshniPlatformModerationMutationResult.success =>
        QoshniPlatformGovernanceWriteOutcome.success,
      QoshniPlatformModerationMutationResult.invalidTransition =>
        QoshniPlatformGovernanceWriteOutcome.invalidTransition,
      QoshniPlatformModerationMutationResult.notFound =>
        QoshniPlatformGovernanceWriteOutcome.notFound,
      QoshniPlatformModerationMutationResult.invalidInput =>
        QoshniPlatformGovernanceWriteOutcome.invalidInput,
      QoshniPlatformModerationMutationResult.failure =>
        QoshniPlatformGovernanceWriteOutcome.failure,
    };

    lastOutcomeKey = writeOutcome.name;
    lastWriteResult = _workflowAudit.finalizeMutation(
      adminId: adminId,
      operationType:
          QoshniPlatformGovernanceAuditOperationType.statusTransition,
      entityType: QoshniPlatformGovernanceAuditEntityType.moderationCase,
      targetReference: moderationCase.caseId,
      permission: QoshniPlatformPermission.performPermittedModerationActions,
      decision: decision,
      mutationSucceeded:
          writeOutcome == QoshniPlatformGovernanceWriteOutcome.success,
      baseOutcome: writeOutcome,
      correlationReference:
          'mod-${moderationCase.caseId}-${toStatus.wireValue}-${atUtc.toIso8601String()}',
      safeSummary: 'Moderation transition to ${toStatus.wireValue} (demo).',
      recordedAtUtc: atUtc,
      scope: scope,
    );
    notifyListeners();
    return lastWriteResult!;
  }
}

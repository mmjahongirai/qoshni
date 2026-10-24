import 'package:flutter/foundation.dart';
import 'package:qoshni/features/platform_governance/application/qoshni_platform_governance_audit_service.dart';
import 'package:qoshni/features/platform_governance/application/qoshni_platform_governance_authorizer.dart';
import 'package:qoshni/features/platform_governance/application/qoshni_platform_governance_workflow_audit.dart';
import 'package:qoshni/features/platform_governance/application/qoshni_platform_governance_write_result.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_governance_audit_entity_type.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_governance_audit_operation_type.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_business_verification_submission.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_business_verification_submission_status.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_governance_history_entry.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_permission.dart';
import 'package:qoshni/features/platform_governance/domain/repositories/qoshni_platform_business_verification_queue_repository.dart';
import 'package:qoshni/features/platform_governance/domain/repositories/qoshni_platform_governance_repository.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_resource_scope.dart';
import 'package:qoshni/features/platform_governance/presentation/qoshni_platform_workflow_validation.dart';

class QoshniPlatformBusinessVerificationQueueController extends ChangeNotifier {
  QoshniPlatformBusinessVerificationQueueController({
    required QoshniPlatformBusinessVerificationQueueRepository repository,
    required QoshniPlatformGovernanceRepository governanceRepository,
    required QoshniPlatformGovernanceAuthorizer authorizer,
    QoshniPlatformGovernanceAuditService? auditService,
  })  : _repository = repository,
        _governanceRepository = governanceRepository,
        _authorizer = authorizer,
        _workflowAudit = QoshniPlatformGovernanceWorkflowAudit(auditService);

  final QoshniPlatformBusinessVerificationQueueRepository _repository;
  final QoshniPlatformGovernanceRepository _governanceRepository;
  final QoshniPlatformGovernanceAuthorizer _authorizer;
  final QoshniPlatformGovernanceWorkflowAudit _workflowAudit;

  QoshniPlatformBusinessVerificationSubmissionStatus? statusFilter;
  String? selectedSubmissionId;
  String? lastOutcomeKey;
  QoshniPlatformGovernanceWriteResult? lastWriteResult;

  List<QoshniPlatformBusinessVerificationSubmission> get submissions =>
      _repository.list(status: statusFilter);

  QoshniPlatformBusinessVerificationSubmission? get selectedSubmission {
    final id = selectedSubmissionId;
    if (id == null) {
      return null;
    }
    return _repository.find(id);
  }

  void setStatusFilter(QoshniPlatformBusinessVerificationSubmissionStatus? value) {
    statusFilter = value;
    notifyListeners();
  }

  void selectSubmission(String? submissionId) {
    selectedSubmissionId = submissionId;
    notifyListeners();
  }

  QoshniPlatformGovernanceWriteResult transitionSelected({
    required String adminId,
    required QoshniPlatformBusinessVerificationSubmissionStatus toStatus,
    required String reasonCode,
    required DateTime atUtc,
  }) {
    lastWriteResult = null;
    lastOutcomeKey = null;
    final submission = selectedSubmission;
    if (submission == null) {
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

    final scope = QoshniPlatformResourceScope(
      kind: QoshniPlatformResourceScopeKind.business,
      businessReference: submission.businessReference,
    );
    final decision = _authorizer.authorize(
      adminId: adminId,
      permission:
          QoshniPlatformPermission.reviewBusinessVerificationSubmissions,
      resourceScope: scope,
      actionLabel: 'business_verification_transition',
    );
    if (!decision.isAllowed) {
      lastOutcomeKey = 'authorizationDenied';
      final auditRecorded = _workflowAudit.recordAuthorizationDenied(
        adminId: adminId,
        operationType:
            QoshniPlatformGovernanceAuditOperationType.statusTransition,
        entityType: QoshniPlatformGovernanceAuditEntityType
            .businessVerificationSubmission,
        targetReference: submission.submissionId,
        permission:
            QoshniPlatformPermission.reviewBusinessVerificationSubmissions,
        decision: decision,
        correlationReference:
            'bver-deny-${submission.submissionId}-${atUtc.toIso8601String()}',
        safeSummary: 'Denied business verification transition (demo).',
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
      lastOutcomeKey = 'invalidInput';
      return const QoshniPlatformGovernanceWriteResult(
        outcome: QoshniPlatformGovernanceWriteOutcome.invalidInput,
      );
    }

    final historyEntry = QoshniPlatformGovernanceHistoryEntry(
      recordedAt: atUtc.toUtc(),
      actorAdminReference: actor,
      operation: 'status_transition',
      fromStatus: submission.status.wireValue,
      toStatus: toStatus.wireValue,
      reasonCode: reasonCode.trim(),
      note: 'Demo verification queue transition.',
    );

    final mutation = _repository.transitionStatus(
      submissionId: submission.submissionId,
      toStatus: toStatus,
      historyEntry: historyEntry,
      updatedAtUtc: atUtc,
    );

    final writeOutcome = switch (mutation) {
      QoshniPlatformBusinessVerificationMutationResult.success =>
        QoshniPlatformGovernanceWriteOutcome.success,
      QoshniPlatformBusinessVerificationMutationResult.invalidTransition =>
        QoshniPlatformGovernanceWriteOutcome.invalidTransition,
      QoshniPlatformBusinessVerificationMutationResult.notFound =>
        QoshniPlatformGovernanceWriteOutcome.notFound,
      QoshniPlatformBusinessVerificationMutationResult.invalidInput =>
        QoshniPlatformGovernanceWriteOutcome.invalidInput,
      QoshniPlatformBusinessVerificationMutationResult.failure =>
        QoshniPlatformGovernanceWriteOutcome.failure,
    };

    lastOutcomeKey = writeOutcome.name;
    lastWriteResult = _workflowAudit.finalizeMutation(
      adminId: adminId,
      operationType:
          QoshniPlatformGovernanceAuditOperationType.statusTransition,
      entityType: QoshniPlatformGovernanceAuditEntityType
          .businessVerificationSubmission,
      targetReference: submission.submissionId,
      permission:
          QoshniPlatformPermission.reviewBusinessVerificationSubmissions,
      decision: decision,
      mutationSucceeded:
          writeOutcome == QoshniPlatformGovernanceWriteOutcome.success,
      baseOutcome: writeOutcome,
      correlationReference:
          'bver-${submission.submissionId}-${toStatus.wireValue}-${atUtc.toIso8601String()}',
      safeSummary:
          'Business verification transition to ${toStatus.wireValue} (demo).',
      recordedAtUtc: atUtc,
      scope: scope,
    );
    notifyListeners();
    return lastWriteResult!;
  }
}

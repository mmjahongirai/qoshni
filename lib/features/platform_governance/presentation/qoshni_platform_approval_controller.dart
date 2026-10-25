import 'package:flutter/foundation.dart';
import 'package:qoshni/features/platform_governance/application/qoshni_platform_governance_audit_service.dart';
import 'package:qoshni/features/platform_governance/application/qoshni_platform_governance_authorizer.dart';
import 'package:qoshni/features/platform_governance/application/qoshni_platform_governance_workflow_audit.dart';
import 'package:qoshni/features/platform_governance/application/qoshni_platform_governance_write_result.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_approval_mutation_result.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_approval_proposal_type.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_approval_request.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_approval_request_status.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_governance_audit_entity_type.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_governance_audit_operation_type.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_permission.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_resource_scope.dart';
import 'package:qoshni/features/platform_governance/domain/repositories/qoshni_platform_approval_repository.dart';
import 'package:qoshni/features/platform_governance/domain/repositories/qoshni_platform_governance_repository.dart';

class QoshniPlatformApprovalController extends ChangeNotifier {
  QoshniPlatformApprovalController({
    required QoshniPlatformApprovalRepository repository,
    required QoshniPlatformGovernanceRepository governanceRepository,
    required QoshniPlatformGovernanceAuthorizer authorizer,
    QoshniPlatformGovernanceAuditService? auditService,
  })  : _repository = repository,
        _governanceRepository = governanceRepository,
        _authorizer = authorizer,
        _workflowAudit = QoshniPlatformGovernanceWorkflowAudit(auditService);

  final QoshniPlatformApprovalRepository _repository;
  final QoshniPlatformGovernanceRepository _governanceRepository;
  final QoshniPlatformGovernanceAuthorizer _authorizer;
  final QoshniPlatformGovernanceWorkflowAudit _workflowAudit;

  int _requestCounter = 100;
  String? selectedRequestId;
  QoshniPlatformGovernanceWriteResult? lastWriteResult;

  List<QoshniPlatformApprovalRequest> get requests => _repository.list();

  QoshniPlatformApprovalRequest? get selectedRequest {
    final id = selectedRequestId;
    if (id == null) {
      return null;
    }
    return _repository.find(id);
  }

  void selectRequest(String? requestId) {
    selectedRequestId = requestId;
    notifyListeners();
  }

  QoshniPlatformGovernanceWriteResult createProposal({
    required String adminId,
    required QoshniPlatformApprovalProposalType proposalType,
    required String targetReference,
    required String reasonCode,
    required DateTime atUtc,
  }) {
    lastWriteResult = null;
    const platformScope = QoshniPlatformResourceScope.platform();
    final decision = _authorizer.authorize(
      adminId: adminId,
      permission: QoshniPlatformPermission.submitHighRiskAdministrativeProposal,
      resourceScope: platformScope,
      actionLabel: 'approval_create',
    );
    if (!decision.isAllowed) {
      _workflowAudit.recordAuthorizationDenied(
        adminId: adminId,
        operationType:
            QoshniPlatformGovernanceAuditOperationType.approvalRequestCreate,
        entityType: QoshniPlatformGovernanceAuditEntityType.approvalRequest,
        targetReference: targetReference,
        permission:
            QoshniPlatformPermission.submitHighRiskAdministrativeProposal,
        decision: decision,
        correlationReference: 'approval-create-deny-${atUtc.toIso8601String()}',
        safeSummary: 'Denied approval proposal create (demo).',
        recordedAtUtc: atUtc,
        scope: platformScope,
      );
      lastWriteResult = QoshniPlatformGovernanceWriteResult(
        outcome: QoshniPlatformGovernanceWriteOutcome.authorizationDenied,
        authorizationDecision: decision,
      );
      notifyListeners();
      return lastWriteResult!;
    }

    final actor = _governanceRepository.findAdmin(adminId)?.syntheticReference;
    if (actor == null || reasonCode.trim().isEmpty) {
      return const QoshniPlatformGovernanceWriteResult(
        outcome: QoshniPlatformGovernanceWriteOutcome.invalidInput,
      );
    }

    _requestCounter++;
    final requestId = 'approval-demo-${_requestCounter.toString().padLeft(3, '0')}';
    final mutation = _repository.createRequest(
      requestId: requestId,
      proposalType: proposalType,
      requesterAdminReference: actor,
      targetReference: targetReference.trim(),
      reasonCode: reasonCode.trim(),
      createdAtUtc: atUtc,
    );

    final writeOutcome = switch (mutation) {
      QoshniPlatformApprovalMutationResult.success =>
        QoshniPlatformGovernanceWriteOutcome.success,
      QoshniPlatformApprovalMutationResult.invalidInput =>
        QoshniPlatformGovernanceWriteOutcome.invalidInput,
      _ => QoshniPlatformGovernanceWriteOutcome.failure,
    };

    lastWriteResult = _workflowAudit.finalizeMutation(
      adminId: adminId,
      operationType:
          QoshniPlatformGovernanceAuditOperationType.approvalRequestCreate,
      entityType: QoshniPlatformGovernanceAuditEntityType.approvalRequest,
      targetReference: requestId,
      permission: QoshniPlatformPermission.submitHighRiskAdministrativeProposal,
      decision: decision,
      mutationSucceeded:
          writeOutcome == QoshniPlatformGovernanceWriteOutcome.success,
      baseOutcome: writeOutcome,
      correlationReference: 'approval-create-$requestId',
      safeSummary:
          'High-risk proposal recorded — no underlying operation executed (demo).',
      recordedAtUtc: atUtc,
      scope: platformScope,
    );
    notifyListeners();
    return lastWriteResult!;
  }

  QoshniPlatformGovernanceWriteResult decideSelected({
    required String adminId,
    required QoshniPlatformApprovalRequestStatus toStatus,
    required String decisionReasonCode,
    required DateTime atUtc,
  }) {
    lastWriteResult = null;
    final request = selectedRequest;
    if (request == null) {
      return const QoshniPlatformGovernanceWriteResult(
        outcome: QoshniPlatformGovernanceWriteOutcome.notFound,
      );
    }
    const platformScope = QoshniPlatformResourceScope.platform();
    final decision = _authorizer.authorize(
      adminId: adminId,
      permission: QoshniPlatformPermission.decideHighRiskAdministrativeProposal,
      resourceScope: platformScope,
      actionLabel: 'approval_decide',
    );
    if (!decision.isAllowed) {
      _workflowAudit.recordAuthorizationDenied(
        adminId: adminId,
        operationType: QoshniPlatformGovernanceAuditOperationType.approvalDecision,
        entityType: QoshniPlatformGovernanceAuditEntityType.approvalRequest,
        targetReference: request.requestId,
        permission:
            QoshniPlatformPermission.decideHighRiskAdministrativeProposal,
        decision: decision,
        correlationReference:
            'approval-decide-deny-${request.requestId}-${atUtc.toIso8601String()}',
        safeSummary: 'Denied approval decision (demo).',
        recordedAtUtc: atUtc,
        scope: platformScope,
      );
      lastWriteResult = QoshniPlatformGovernanceWriteResult(
        outcome: QoshniPlatformGovernanceWriteOutcome.authorizationDenied,
        authorizationDecision: decision,
      );
      notifyListeners();
      return lastWriteResult!;
    }

    final decider =
        _governanceRepository.findAdmin(adminId)?.syntheticReference;
    if (decider == null || decisionReasonCode.trim().isEmpty) {
      return const QoshniPlatformGovernanceWriteResult(
        outcome: QoshniPlatformGovernanceWriteOutcome.invalidInput,
      );
    }

    final mutation = _repository.decide(
      requestId: request.requestId,
      toStatus: toStatus,
      deciderAdminReference: decider,
      decisionReasonCode: decisionReasonCode,
      decidedAtUtc: atUtc,
    );

    final writeOutcome = switch (mutation) {
      QoshniPlatformApprovalMutationResult.success =>
        QoshniPlatformGovernanceWriteOutcome.success,
      QoshniPlatformApprovalMutationResult.selfApprovalDenied =>
        QoshniPlatformGovernanceWriteOutcome.invalidInput,
      QoshniPlatformApprovalMutationResult.invalidTransition =>
        QoshniPlatformGovernanceWriteOutcome.invalidTransition,
      QoshniPlatformApprovalMutationResult.notFound =>
        QoshniPlatformGovernanceWriteOutcome.notFound,
      QoshniPlatformApprovalMutationResult.invalidInput =>
        QoshniPlatformGovernanceWriteOutcome.invalidInput,
      QoshniPlatformApprovalMutationResult.failure =>
        QoshniPlatformGovernanceWriteOutcome.failure,
    };

    lastWriteResult = _workflowAudit.finalizeMutation(
      adminId: adminId,
      operationType: QoshniPlatformGovernanceAuditOperationType.approvalDecision,
      entityType: QoshniPlatformGovernanceAuditEntityType.approvalRequest,
      targetReference: request.requestId,
      permission: QoshniPlatformPermission.decideHighRiskAdministrativeProposal,
      decision: decision,
      mutationSucceeded:
          writeOutcome == QoshniPlatformGovernanceWriteOutcome.success,
      baseOutcome: writeOutcome,
      correlationReference:
          'approval-decide-${request.requestId}-${toStatus.name}',
      safeSummary:
          'Approval lifecycle ${toStatus.name} only — no high-risk execution (demo).',
      recordedAtUtc: atUtc,
      scope: platformScope,
    );
    notifyListeners();
    return lastWriteResult!;
  }
}

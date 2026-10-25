import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/features/platform_governance/application/qoshni_platform_governance_audit_service.dart';
import 'package:qoshni/features/platform_governance/application/qoshni_platform_governance_authorizer.dart';
import 'package:qoshni/features/platform_governance/application/qoshni_platform_governance_operations_summary_service.dart';
import 'package:qoshni/features/platform_governance/application/qoshni_platform_governance_write_result.dart';
import 'package:qoshni/features/platform_governance/data/in_memory_qoshni_platform_approval_repository.dart';
import 'package:qoshni/features/platform_governance/data/in_memory_qoshni_platform_business_verification_queue_repository.dart';
import 'package:qoshni/features/platform_governance/data/in_memory_qoshni_platform_configuration_repository.dart';
import 'package:qoshni/features/platform_governance/data/in_memory_qoshni_platform_governance_audit_repository.dart';
import 'package:qoshni/features/platform_governance/data/in_memory_qoshni_platform_governance_repository.dart';
import 'package:qoshni/features/platform_governance/data/in_memory_qoshni_platform_moderation_queue_repository.dart';
import 'package:qoshni/features/platform_governance/data/in_memory_qoshni_platform_support_case_repository.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_approval_mutation_result.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_approval_proposal_type.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_approval_request_status.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_authorization_decision.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_authorization_reason.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_business_verification_submission_status.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_configuration_mutation_result.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_governance_audit_entity_type.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_governance_audit_operation_type.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_governance_audit_outcome.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_permission.dart';
import 'package:qoshni/features/platform_governance/domain/repositories/qoshni_platform_governance_audit_repository.dart';
import 'package:qoshni/features/platform_governance/presentation/qoshni_platform_approval_controller.dart';
import 'package:qoshni/features/platform_governance/presentation/qoshni_platform_business_verification_queue_controller.dart';
import 'package:qoshni/features/platform_governance/presentation/qoshni_platform_configuration_controller.dart';

void main() {
  group('audit repository', () {
    test('append-only ordering and duplicate correlation', () {
      final repo = InMemoryQoshniPlatformGovernanceAuditRepository(seed: []);
      final service = QoshniPlatformGovernanceAuditService(
        auditRepository: repo,
        governanceRepository: InMemoryQoshniPlatformGovernanceRepository(),
      );
      final decision = const QoshniPlatformAuthorizationDecision(
        isAllowed: true,
        reason: QoshniPlatformAuthorizationReason.allowedExplicitGrant,
        permission: QoshniPlatformPermission.viewAuditRecords,
      );
      final event = service.buildEvent(
        adminId: 'admin-demo-viewer',
        operationType: QoshniPlatformGovernanceAuditOperationType.configurationRead,
        entityType: QoshniPlatformGovernanceAuditEntityType.platformConfiguration,
        targetReference: 'cfg-1',
        permission: QoshniPlatformPermission.viewPlatformConfiguration,
        decision: decision,
        outcome: QoshniPlatformGovernanceAuditOutcome.mutationSucceeded,
        correlationReference: 'corr-1',
        safeSummary: 'demo',
        recordedAtUtc: DateTime.utc(2025, 1, 1),
      );
      expect(repo.append(event), QoshniPlatformGovernanceAuditAppendResult.success);
      expect(
        repo.append(event),
        QoshniPlatformGovernanceAuditAppendResult.invalidInput,
      );
      final dup = service.buildEvent(
        adminId: 'admin-demo-viewer',
        operationType: QoshniPlatformGovernanceAuditOperationType.configurationRead,
        entityType: QoshniPlatformGovernanceAuditEntityType.platformConfiguration,
        targetReference: 'cfg-2',
        permission: QoshniPlatformPermission.viewPlatformConfiguration,
        decision: decision,
        outcome: QoshniPlatformGovernanceAuditOutcome.mutationSucceeded,
        correlationReference: 'corr-1',
        safeSummary: 'demo2',
        recordedAtUtc: DateTime.utc(2025, 1, 2),
      );
      expect(
        repo.append(dup),
        QoshniPlatformGovernanceAuditAppendResult.duplicateCorrelationReference,
      );
      final listed = repo.list();
      expect(listed.length, 1);
    });

    test('failNextAppend surfaces auditPersistFailure on success path', () {
      final auditRepo = InMemoryQoshniPlatformGovernanceAuditRepository(seed: []);
      auditRepo.failNextAppend = true;
      final governance = InMemoryQoshniPlatformGovernanceRepository();
      final authorizer = QoshniPlatformGovernanceAuthorizer(governance);
      final auditService = QoshniPlatformGovernanceAuditService(
        auditRepository: auditRepo,
        governanceRepository: governance,
      );
      final verificationRepo =
          InMemoryQoshniPlatformBusinessVerificationQueueRepository();
      final controller = QoshniPlatformBusinessVerificationQueueController(
        repository: verificationRepo,
        governanceRepository: governance,
        authorizer: authorizer,
        auditService: auditService,
      );
      controller.selectSubmission('bver-demo-001');
      final result = controller.transitionSelected(
        adminId: 'admin-demo-verifier',
        toStatus: QoshniPlatformBusinessVerificationSubmissionStatus.underReview,
        reasonCode: 'review',
        atUtc: DateTime.utc(2025, 6, 1),
      );
      expect(result.outcome, QoshniPlatformGovernanceWriteOutcome.auditPersistFailure);
      expect(result.auditRecorded, isFalse);
      expect(
        verificationRepo.find('bver-demo-001')!.status,
        QoshniPlatformBusinessVerificationSubmissionStatus.underReview,
      );
    });
  });

  group('configuration', () {
    test('rejects secret-like values and restricted settings', () {
      final repo = InMemoryQoshniPlatformConfigurationRepository();
      final governance = InMemoryQoshniPlatformGovernanceRepository();
      final controller = QoshniPlatformConfigurationController(
        repository: repo,
        governanceRepository: governance,
        authorizer: QoshniPlatformGovernanceAuthorizer(governance),
      );
      final before = repo.findSetting(
        'platform.demo.announcement_banner_enabled',
      )!;
      final secretAttempt = repo.updateSetting(
        settingKey: before.settingKey,
        newValue: 'api_key=bad',
        actorAdminReference: 'demo-platform-admin-operations',
        reasonCode: 'x',
        updatedAtUtc: DateTime.utc(2025, 1, 1),
      );
      expect(
        secretAttempt,
        QoshniPlatformConfigurationMutationResult.secretLikeValueRejected,
      );
      expect(repo.findSetting(before.settingKey)!.revision, before.revision);

      final restricted = controller.updateBooleanSetting(
        adminId: 'admin-demo-operations',
        settingKey: 'platform.restricted.payment_provider_mode',
        newValue: true,
        reasonCode: 'try',
        atUtc: DateTime.utc(2025, 1, 1),
      );
      expect(restricted.outcome, QoshniPlatformGovernanceWriteOutcome.invalidInput);
    });
  });

  group('maker-checker approvals', () {
    test('self-approval denied and no wallet execution', () {
      final repo = InMemoryQoshniPlatformApprovalRepository(seed: []);
      final governance = InMemoryQoshniPlatformGovernanceRepository();
      final controller = QoshniPlatformApprovalController(
        repository: repo,
        governanceRepository: governance,
        authorizer: QoshniPlatformGovernanceAuthorizer(governance),
      );
      controller.createProposal(
        adminId: 'admin-demo-operations',
        proposalType: QoshniPlatformApprovalProposalType.hypotheticalWalletAdjustment,
        targetReference: 'demo-wallet-001',
        reasonCode: 'demo',
        atUtc: DateTime.utc(2025, 1, 1),
      );
      final request = repo.find('approval-demo-101')!;
      expect(
        repo.decide(
          requestId: request.requestId,
          toStatus: QoshniPlatformApprovalRequestStatus.approved,
          deciderAdminReference: request.requesterAdminReference,
          decisionReasonCode: 'self',
          decidedAtUtc: DateTime.utc(2025, 1, 2),
        ),
        QoshniPlatformApprovalMutationResult.selfApprovalDenied,
      );

      controller.selectRequest('approval-demo-101');
      final approver = controller.decideSelected(
        adminId: 'admin-demo-approver',
        toStatus: QoshniPlatformApprovalRequestStatus.approved,
        decisionReasonCode: 'second_party',
        atUtc: DateTime.utc(2025, 1, 3),
      );
      expect(approver.isSuccess, isTrue);
    });
  });

  group('operations dashboard', () {
    test('summary is read-only derived counts', () {
      final verification = InMemoryQoshniPlatformBusinessVerificationQueueRepository();
      final moderation = InMemoryQoshniPlatformModerationQueueRepository();
      final support = InMemoryQoshniPlatformSupportCaseRepository();
      final audit = InMemoryQoshniPlatformGovernanceAuditRepository();
      final approval = InMemoryQoshniPlatformApprovalRepository();
      final config = InMemoryQoshniPlatformConfigurationRepository();
      final service = QoshniPlatformGovernanceOperationsSummaryService(
        verificationRepository: verification,
        moderationRepository: moderation,
        supportRepository: support,
        auditRepository: audit,
        approvalRepository: approval,
        configurationRepository: config,
      );
      final beforeVerification = verification.list().length;
      final summary = service.build(asOfUtc: DateTime.utc(2025, 7, 1));
      expect(summary.isSyntheticDemo, isTrue);
      expect(verification.list().length, beforeVerification);
      expect(summary.pendingApprovalCount, greaterThan(0));
    });
  });
}

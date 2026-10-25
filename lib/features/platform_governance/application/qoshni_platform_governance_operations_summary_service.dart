import 'package:qoshni/features/platform_governance/application/qoshni_platform_governance_operations_summary.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_approval_request_status.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_business_verification_submission_status.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_governance_audit_outcome.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_moderation_case_status.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_support_case_status.dart';
import 'package:qoshni/features/platform_governance/domain/repositories/qoshni_platform_approval_repository.dart';
import 'package:qoshni/features/platform_governance/domain/repositories/qoshni_platform_business_verification_queue_repository.dart';
import 'package:qoshni/features/platform_governance/domain/repositories/qoshni_platform_configuration_repository.dart';
import 'package:qoshni/features/platform_governance/domain/repositories/qoshni_platform_governance_audit_repository.dart';
import 'package:qoshni/features/platform_governance/domain/repositories/qoshni_platform_moderation_queue_repository.dart';
import 'package:qoshni/features/platform_governance/domain/repositories/qoshni_platform_support_case_repository.dart';

class QoshniPlatformGovernanceOperationsSummaryService {
  QoshniPlatformGovernanceOperationsSummaryService({
    required QoshniPlatformBusinessVerificationQueueRepository verificationRepository,
    required QoshniPlatformModerationQueueRepository moderationRepository,
    required QoshniPlatformSupportCaseRepository supportRepository,
    required QoshniPlatformGovernanceAuditRepository auditRepository,
    required QoshniPlatformApprovalRepository approvalRepository,
    required QoshniPlatformConfigurationRepository configurationRepository,
  })  : _verificationRepository = verificationRepository,
        _moderationRepository = moderationRepository,
        _supportRepository = supportRepository,
        _auditRepository = auditRepository,
        _approvalRepository = approvalRepository,
        _configurationRepository = configurationRepository;

  final QoshniPlatformBusinessVerificationQueueRepository _verificationRepository;
  final QoshniPlatformModerationQueueRepository _moderationRepository;
  final QoshniPlatformSupportCaseRepository _supportRepository;
  final QoshniPlatformGovernanceAuditRepository _auditRepository;
  final QoshniPlatformApprovalRepository _approvalRepository;
  final QoshniPlatformConfigurationRepository _configurationRepository;

  QoshniPlatformGovernanceOperationsSummary build({DateTime? asOfUtc}) {
    final asOf = (asOfUtc ?? DateTime.now()).toUtc();
    final verificationCounts = {
      for (final status in QoshniPlatformBusinessVerificationSubmissionStatus.values)
        status: 0,
    };
    for (final submission in _verificationRepository.list()) {
      verificationCounts[submission.status] =
          (verificationCounts[submission.status] ?? 0) + 1;
    }

    final moderationCounts = {
      for (final status in QoshniPlatformModerationCaseStatus.values) status: 0,
    };
    for (final moderationCase in _moderationRepository.list()) {
      moderationCounts[moderationCase.status] =
          (moderationCounts[moderationCase.status] ?? 0) + 1;
    }

    final supportCounts = {
      for (final status in QoshniPlatformSupportCaseStatus.values) status: 0,
    };
    for (final supportCase in _supportRepository.list()) {
      supportCounts[supportCase.status] =
          (supportCounts[supportCase.status] ?? 0) + 1;
    }

    final recentWindowStart = asOf.subtract(const Duration(days: 7));
    final auditEvents = _auditRepository.list(
      recordedAfterUtc: recentWindowStart,
      recordedBeforeUtc: asOf,
    );
    final auditOutcomes = {
      for (final outcome in QoshniPlatformGovernanceAuditOutcome.values)
        outcome: 0,
    };
    for (final event in auditEvents) {
      auditOutcomes[event.outcome] = (auditOutcomes[event.outcome] ?? 0) + 1;
    }

    final pendingApprovals = _approvalRepository
        .list(status: QoshniPlatformApprovalRequestStatus.pending)
        .length;

    var revisionCount = 0;
    for (final setting in _configurationRepository.listSettings()) {
      revisionCount +=
          _configurationRepository.revisionHistory(setting.settingKey).length;
    }

    return QoshniPlatformGovernanceOperationsSummary(
      asOfUtc: asOf,
      isSyntheticDemo: true,
      verificationByStatus: verificationCounts,
      moderationByStatus: moderationCounts,
      supportByStatus: supportCounts,
      recentAuditOutcomes: auditOutcomes,
      pendingApprovalCount: pendingApprovals,
      recentConfigurationRevisions: revisionCount,
    );
  }
}

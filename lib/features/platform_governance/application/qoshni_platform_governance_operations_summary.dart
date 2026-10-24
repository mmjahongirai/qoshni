import 'package:qoshni/features/platform_governance/domain/qoshni_platform_approval_request_status.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_business_verification_submission_status.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_governance_audit_outcome.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_moderation_case_status.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_support_case_status.dart';

class QoshniPlatformGovernanceOperationsSummary {
  const QoshniPlatformGovernanceOperationsSummary({
    required this.asOfUtc,
    required this.isSyntheticDemo,
    required this.verificationByStatus,
    required this.moderationByStatus,
    required this.supportByStatus,
    required this.recentAuditOutcomes,
    required this.pendingApprovalCount,
    required this.recentConfigurationRevisions,
  });

  final DateTime asOfUtc;
  final bool isSyntheticDemo;
  final Map<QoshniPlatformBusinessVerificationSubmissionStatus, int>
      verificationByStatus;
  final Map<QoshniPlatformModerationCaseStatus, int> moderationByStatus;
  final Map<QoshniPlatformSupportCaseStatus, int> supportByStatus;
  final Map<QoshniPlatformGovernanceAuditOutcome, int> recentAuditOutcomes;
  final int pendingApprovalCount;
  final int recentConfigurationRevisions;
}

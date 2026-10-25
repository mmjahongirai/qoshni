import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/features/platform_governance/application/qoshni_platform_governance_write_result.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_business_verification_submission_status.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_moderation_case_status.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_support_case_status.dart';
import 'package:qoshni/features/platform_governance/presentation/qoshni_platform_governance_labels.dart';
String qoshniPlatformBusinessVerificationStatusLabel(
  AppLocalizations l10n,
  QoshniPlatformBusinessVerificationSubmissionStatus status,
) {
  return switch (status) {
    QoshniPlatformBusinessVerificationSubmissionStatus.pending =>
      l10n.platformBverStatusPending,
    QoshniPlatformBusinessVerificationSubmissionStatus.underReview =>
      l10n.platformBverStatusUnderReview,
    QoshniPlatformBusinessVerificationSubmissionStatus.approved =>
      l10n.platformBverStatusApproved,
    QoshniPlatformBusinessVerificationSubmissionStatus.rejected =>
      l10n.platformBverStatusRejected,
    QoshniPlatformBusinessVerificationSubmissionStatus.needsMoreInformation =>
      l10n.platformBverStatusNeedsInfo,
  };
}

String qoshniPlatformModerationStatusLabel(
  AppLocalizations l10n,
  QoshniPlatformModerationCaseStatus status,
) {
  return switch (status) {
    QoshniPlatformModerationCaseStatus.pending => l10n.platformModStatusPending,
    QoshniPlatformModerationCaseStatus.underReview =>
      l10n.platformModStatusUnderReview,
    QoshniPlatformModerationCaseStatus.actionProposed =>
      l10n.platformModStatusActionProposed,
    QoshniPlatformModerationCaseStatus.resolved => l10n.platformModStatusResolved,
    QoshniPlatformModerationCaseStatus.dismissed =>
      l10n.platformModStatusDismissed,
  };
}

String qoshniPlatformSupportStatusLabel(
  AppLocalizations l10n,
  QoshniPlatformSupportCaseStatus status,
) {
  return switch (status) {
    QoshniPlatformSupportCaseStatus.open => l10n.platformSupportStatusOpen,
    QoshniPlatformSupportCaseStatus.assigned =>
      l10n.platformSupportStatusAssigned,
    QoshniPlatformSupportCaseStatus.inProgress =>
      l10n.platformSupportStatusInProgress,
    QoshniPlatformSupportCaseStatus.resolved =>
      l10n.platformSupportStatusResolved,
    QoshniPlatformSupportCaseStatus.closed => l10n.platformSupportStatusClosed,
  };
}

String qoshniPlatformWorkflowWriteOutcomeMessage(
  AppLocalizations l10n,
  QoshniPlatformGovernanceWriteResult result,
) {
  if (result.outcome == QoshniPlatformGovernanceWriteOutcome.authorizationDenied &&
      result.authorizationDecision != null) {
    return qoshniPlatformAuthorizationReasonLabel(
      l10n,
      result.authorizationDecision!.reason,
    );
  }
  return switch (result.outcome) {
    QoshniPlatformGovernanceWriteOutcome.success => l10n.platformWorkflowOutcomeSuccess,
    QoshniPlatformGovernanceWriteOutcome.invalidTransition =>
      l10n.platformWorkflowOutcomeInvalidTransition,
    QoshniPlatformGovernanceWriteOutcome.invalidInput =>
      l10n.platformWorkflowOutcomeInvalidInput,
    QoshniPlatformGovernanceWriteOutcome.notFound =>
      l10n.platformWorkflowOutcomeNotFound,
    QoshniPlatformGovernanceWriteOutcome.failure =>
      l10n.platformWorkflowOutcomeFailure,
    QoshniPlatformGovernanceWriteOutcome.authorizationDenied =>
      l10n.platformWorkflowOutcomeAuthorizationDenied,
    QoshniPlatformGovernanceWriteOutcome.auditPersistFailure =>
      l10n.platformWorkflowOutcomeAuditPersistFailure,
  };
}

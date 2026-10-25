import 'package:qoshni/features/platform_governance/domain/qoshni_platform_business_verification_submission.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_business_verification_submission_status.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_governance_history_entry.dart';

enum QoshniPlatformBusinessVerificationMutationResult {
  success,
  notFound,
  invalidInput,
  invalidTransition,
  failure,
}

abstract class QoshniPlatformBusinessVerificationQueueRepository {
  List<QoshniPlatformBusinessVerificationSubmission> list({
    QoshniPlatformBusinessVerificationSubmissionStatus? status,
  });

  QoshniPlatformBusinessVerificationSubmission? find(String submissionId);

  QoshniPlatformBusinessVerificationMutationResult transitionStatus({
    required String submissionId,
    required QoshniPlatformBusinessVerificationSubmissionStatus toStatus,
    required QoshniPlatformGovernanceHistoryEntry historyEntry,
    required DateTime updatedAtUtc,
  });
}

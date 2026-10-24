import 'package:qoshni/features/platform_governance/domain/qoshni_platform_business_verification_submission_status.dart';

abstract final class QoshniPlatformBusinessVerificationLifecyclePolicy {
  static bool canTransition(
    QoshniPlatformBusinessVerificationSubmissionStatus from,
    QoshniPlatformBusinessVerificationSubmissionStatus to,
  ) {
    if (from == to) {
      return false;
    }
    return switch (from) {
      QoshniPlatformBusinessVerificationSubmissionStatus.pending => {
            QoshniPlatformBusinessVerificationSubmissionStatus.underReview,
            QoshniPlatformBusinessVerificationSubmissionStatus.rejected,
            QoshniPlatformBusinessVerificationSubmissionStatus
                .needsMoreInformation,
          }.contains(to),
      QoshniPlatformBusinessVerificationSubmissionStatus.underReview => {
            QoshniPlatformBusinessVerificationSubmissionStatus.approved,
            QoshniPlatformBusinessVerificationSubmissionStatus.rejected,
            QoshniPlatformBusinessVerificationSubmissionStatus
                .needsMoreInformation,
          }.contains(to),
      QoshniPlatformBusinessVerificationSubmissionStatus.needsMoreInformation =>
        {
            QoshniPlatformBusinessVerificationSubmissionStatus.underReview,
            QoshniPlatformBusinessVerificationSubmissionStatus.rejected,
          }.contains(to),
      QoshniPlatformBusinessVerificationSubmissionStatus.approved ||
      QoshniPlatformBusinessVerificationSubmissionStatus.rejected =>
        false,
    };
  }
}

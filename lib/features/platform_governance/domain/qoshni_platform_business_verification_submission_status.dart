/// Admin verification queue status (demo). Aligns with onboarding review vocabulary
/// where practical; `approved` is a queue decision, not live business verification.
enum QoshniPlatformBusinessVerificationSubmissionStatus {
  pending,
  underReview,
  approved,
  rejected,
  needsMoreInformation,
}

extension QoshniPlatformBusinessVerificationSubmissionStatusWire
    on QoshniPlatformBusinessVerificationSubmissionStatus {
  String get wireValue => switch (this) {
        QoshniPlatformBusinessVerificationSubmissionStatus.pending => 'pending',
        QoshniPlatformBusinessVerificationSubmissionStatus.underReview =>
          'under_review',
        QoshniPlatformBusinessVerificationSubmissionStatus.approved => 'approved',
        QoshniPlatformBusinessVerificationSubmissionStatus.rejected => 'rejected',
        QoshniPlatformBusinessVerificationSubmissionStatus.needsMoreInformation =>
          'needs_more_information',
      };
}

QoshniPlatformBusinessVerificationSubmissionStatus?
    qoshniPlatformBusinessVerificationSubmissionStatusFromWire(String value) {
  return switch (value.trim()) {
    'pending' => QoshniPlatformBusinessVerificationSubmissionStatus.pending,
    'under_review' =>
      QoshniPlatformBusinessVerificationSubmissionStatus.underReview,
    'approved' => QoshniPlatformBusinessVerificationSubmissionStatus.approved,
    'rejected' => QoshniPlatformBusinessVerificationSubmissionStatus.rejected,
    'needs_more_information' =>
      QoshniPlatformBusinessVerificationSubmissionStatus.needsMoreInformation,
    _ => null,
  };
}

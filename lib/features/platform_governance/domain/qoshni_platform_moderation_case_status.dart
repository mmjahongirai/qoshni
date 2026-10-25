enum QoshniPlatformModerationCaseStatus {
  pending,
  underReview,
  actionProposed,
  resolved,
  dismissed,
}

extension QoshniPlatformModerationCaseStatusWire
    on QoshniPlatformModerationCaseStatus {
  String get wireValue => switch (this) {
        QoshniPlatformModerationCaseStatus.pending => 'pending',
        QoshniPlatformModerationCaseStatus.underReview => 'under_review',
        QoshniPlatformModerationCaseStatus.actionProposed => 'action_proposed',
        QoshniPlatformModerationCaseStatus.resolved => 'resolved',
        QoshniPlatformModerationCaseStatus.dismissed => 'dismissed',
      };
}

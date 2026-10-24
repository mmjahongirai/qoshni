import 'package:qoshni/features/platform_governance/domain/qoshni_platform_moderation_case_status.dart';

/// Moderation queue lifecycle is independent of Phase 13 complaint/review status.
abstract final class QoshniPlatformModerationLifecyclePolicy {
  static bool canTransition(
    QoshniPlatformModerationCaseStatus from,
    QoshniPlatformModerationCaseStatus to,
  ) {
    if (from == to) {
      return false;
    }
    return switch (from) {
      QoshniPlatformModerationCaseStatus.pending => {
            QoshniPlatformModerationCaseStatus.underReview,
            QoshniPlatformModerationCaseStatus.dismissed,
          }.contains(to),
      QoshniPlatformModerationCaseStatus.underReview => {
            QoshniPlatformModerationCaseStatus.actionProposed,
            QoshniPlatformModerationCaseStatus.resolved,
            QoshniPlatformModerationCaseStatus.dismissed,
          }.contains(to),
      QoshniPlatformModerationCaseStatus.actionProposed => {
            QoshniPlatformModerationCaseStatus.resolved,
            QoshniPlatformModerationCaseStatus.dismissed,
          }.contains(to),
      QoshniPlatformModerationCaseStatus.resolved ||
      QoshniPlatformModerationCaseStatus.dismissed =>
        false,
    };
  }
}

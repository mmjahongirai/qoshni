import 'package:qoshni/features/platform_governance/domain/qoshni_platform_support_case_status.dart';

abstract final class QoshniPlatformSupportLifecyclePolicy {
  static bool canTransition(
    QoshniPlatformSupportCaseStatus from,
    QoshniPlatformSupportCaseStatus to,
  ) {
    if (from == to) {
      return false;
    }
    return switch (from) {
      QoshniPlatformSupportCaseStatus.open => {
            QoshniPlatformSupportCaseStatus.assigned,
            QoshniPlatformSupportCaseStatus.closed,
          }.contains(to),
      QoshniPlatformSupportCaseStatus.assigned => {
            QoshniPlatformSupportCaseStatus.inProgress,
            QoshniPlatformSupportCaseStatus.closed,
          }.contains(to),
      QoshniPlatformSupportCaseStatus.inProgress => {
            QoshniPlatformSupportCaseStatus.resolved,
            QoshniPlatformSupportCaseStatus.closed,
          }.contains(to),
      QoshniPlatformSupportCaseStatus.resolved => {
            QoshniPlatformSupportCaseStatus.closed,
          }.contains(to),
      QoshniPlatformSupportCaseStatus.closed => false,
    };
  }
}

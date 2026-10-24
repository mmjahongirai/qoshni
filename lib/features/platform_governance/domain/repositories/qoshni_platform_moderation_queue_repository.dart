import 'package:qoshni/features/platform_governance/domain/qoshni_platform_governance_history_entry.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_moderation_case.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_moderation_case_status.dart';

enum QoshniPlatformModerationMutationResult {
  success,
  notFound,
  invalidInput,
  invalidTransition,
  failure,
}

abstract class QoshniPlatformModerationQueueRepository {
  List<QoshniPlatformModerationCase> list({
    QoshniPlatformModerationCaseStatus? status,
  });

  QoshniPlatformModerationCase? find(String caseId);

  QoshniPlatformModerationMutationResult transitionStatus({
    required String caseId,
    required QoshniPlatformModerationCaseStatus toStatus,
    required QoshniPlatformGovernanceHistoryEntry historyEntry,
    required DateTime updatedAtUtc,
  });
}

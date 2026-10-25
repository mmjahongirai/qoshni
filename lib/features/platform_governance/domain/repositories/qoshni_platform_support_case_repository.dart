import 'package:qoshni/features/platform_governance/domain/qoshni_platform_governance_history_entry.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_support_case.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_support_case_status.dart';

enum QoshniPlatformSupportMutationResult {
  success,
  notFound,
  invalidInput,
  invalidTransition,
  failure,
}

abstract class QoshniPlatformSupportCaseRepository {
  List<QoshniPlatformSupportCase> list({
    QoshniPlatformSupportCaseStatus? status,
  });

  QoshniPlatformSupportCase? find(String caseId);

  QoshniPlatformSupportMutationResult transitionStatus({
    required String caseId,
    required QoshniPlatformSupportCaseStatus toStatus,
    required QoshniPlatformGovernanceHistoryEntry historyEntry,
    required DateTime updatedAtUtc,
  });

  QoshniPlatformSupportMutationResult assignRole({
    required String caseId,
    required String roleKey,
    required QoshniPlatformGovernanceHistoryEntry historyEntry,
    required DateTime updatedAtUtc,
  });

  QoshniPlatformSupportMutationResult addInternalNote({
    required String caseId,
    required QoshniPlatformSupportInternalNote note,
    required QoshniPlatformGovernanceHistoryEntry historyEntry,
    required DateTime updatedAtUtc,
  });
}

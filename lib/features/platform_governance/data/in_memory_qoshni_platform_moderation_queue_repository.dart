import 'package:qoshni/features/platform_governance/data/qoshni_platform_moderation_demo_seed.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_governance_history_entry.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_moderation_case.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_moderation_case_status.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_moderation_lifecycle_policy.dart';
import 'package:qoshni/features/platform_governance/domain/repositories/qoshni_platform_moderation_queue_repository.dart';

class InMemoryQoshniPlatformModerationQueueRepository
    implements QoshniPlatformModerationQueueRepository {
  InMemoryQoshniPlatformModerationQueueRepository({
    List<QoshniPlatformModerationCase>? seed,
  }) : _items = _cloneSeed(seed ?? buildQoshniPlatformModerationDemoSeed());

  final List<QoshniPlatformModerationCase> _items;

  bool failNextMutation = false;

  static List<QoshniPlatformModerationCase> _cloneSeed(
    List<QoshniPlatformModerationCase> seed,
  ) {
    return seed.map(_clone).toList(growable: true);
  }

  static QoshniPlatformModerationCase _clone(QoshniPlatformModerationCase item) {
    return item.copyWith(history: List.unmodifiable(item.history));
  }

  @override
  List<QoshniPlatformModerationCase> list({
    QoshniPlatformModerationCaseStatus? status,
  }) {
    var result = _items.map(_clone).toList();
    if (status != null) {
      result = result.where((item) => item.status == status).toList();
    }
    result.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return List.unmodifiable(result);
  }

  @override
  QoshniPlatformModerationCase? find(String caseId) {
    for (final item in _items) {
      if (item.caseId == caseId) {
        return _clone(item);
      }
    }
    return null;
  }

  @override
  QoshniPlatformModerationMutationResult transitionStatus({
    required String caseId,
    required QoshniPlatformModerationCaseStatus toStatus,
    required QoshniPlatformGovernanceHistoryEntry historyEntry,
    required DateTime updatedAtUtc,
  }) {
    final index = _items.indexWhere((item) => item.caseId == caseId);
    if (index < 0) {
      return QoshniPlatformModerationMutationResult.notFound;
    }
    final current = _items[index];
    if (!QoshniPlatformModerationLifecyclePolicy.canTransition(
      current.status,
      toStatus,
    )) {
      return QoshniPlatformModerationMutationResult.invalidTransition;
    }
    if (historyEntry.fromStatus != current.status.wireValue) {
      return QoshniPlatformModerationMutationResult.invalidTransition;
    }
    if (failNextMutation) {
      failNextMutation = false;
      return QoshniPlatformModerationMutationResult.failure;
    }
    _items[index] = current.copyWith(
      status: toStatus,
      updatedAt: updatedAtUtc.toUtc(),
      history: List.unmodifiable([...current.history, historyEntry]),
    );
    return QoshniPlatformModerationMutationResult.success;
  }
}

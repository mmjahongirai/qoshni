import 'package:qoshni/features/platform_governance/data/qoshni_platform_support_demo_seed.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_governance_history_entry.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_support_case.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_support_case_status.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_support_lifecycle_policy.dart';
import 'package:qoshni/features/platform_governance/domain/repositories/qoshni_platform_support_case_repository.dart';
import 'package:qoshni/features/platform_governance/presentation/qoshni_platform_workflow_validation.dart';

class InMemoryQoshniPlatformSupportCaseRepository
    implements QoshniPlatformSupportCaseRepository {
  InMemoryQoshniPlatformSupportCaseRepository({
    List<QoshniPlatformSupportCase>? seed,
  }) : _items = _cloneSeed(seed ?? buildQoshniPlatformSupportDemoSeed());

  final List<QoshniPlatformSupportCase> _items;

  bool failNextMutation = false;

  static List<QoshniPlatformSupportCase> _cloneSeed(
    List<QoshniPlatformSupportCase> seed,
  ) {
    return seed.map(_clone).toList(growable: true);
  }

  static QoshniPlatformSupportCase _clone(QoshniPlatformSupportCase item) {
    return item.copyWith(
      history: List.unmodifiable(item.history),
      internalNotes: List.unmodifiable(item.internalNotes),
    );
  }

  @override
  List<QoshniPlatformSupportCase> list({
    QoshniPlatformSupportCaseStatus? status,
  }) {
    var result = _items.map(_clone).toList();
    if (status != null) {
      result = result.where((item) => item.status == status).toList();
    }
    result.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return List.unmodifiable(result);
  }

  @override
  QoshniPlatformSupportCase? find(String caseId) {
    for (final item in _items) {
      if (item.caseId == caseId) {
        return _clone(item);
      }
    }
    return null;
  }

  @override
  QoshniPlatformSupportMutationResult transitionStatus({
    required String caseId,
    required QoshniPlatformSupportCaseStatus toStatus,
    required QoshniPlatformGovernanceHistoryEntry historyEntry,
    required DateTime updatedAtUtc,
  }) {
    final index = _items.indexWhere((item) => item.caseId == caseId);
    if (index < 0) {
      return QoshniPlatformSupportMutationResult.notFound;
    }
    final current = _items[index];
    if (!QoshniPlatformSupportLifecyclePolicy.canTransition(
      current.status,
      toStatus,
    )) {
      return QoshniPlatformSupportMutationResult.invalidTransition;
    }
    if (failNextMutation) {
      failNextMutation = false;
      return QoshniPlatformSupportMutationResult.failure;
    }
    _items[index] = current.copyWith(
      status: toStatus,
      updatedAt: updatedAtUtc.toUtc(),
      history: List.unmodifiable([...current.history, historyEntry]),
    );
    return QoshniPlatformSupportMutationResult.success;
  }

  @override
  QoshniPlatformSupportMutationResult assignRole({
    required String caseId,
    required String roleKey,
    required QoshniPlatformGovernanceHistoryEntry historyEntry,
    required DateTime updatedAtUtc,
  }) {
    if (roleKey.trim().isEmpty) {
      return QoshniPlatformSupportMutationResult.invalidInput;
    }
    final index = _items.indexWhere((item) => item.caseId == caseId);
    if (index < 0) {
      return QoshniPlatformSupportMutationResult.notFound;
    }
    if (failNextMutation) {
      failNextMutation = false;
      return QoshniPlatformSupportMutationResult.failure;
    }
    final current = _items[index];
    _items[index] = current.copyWith(
      assignedRoleKey: roleKey.trim(),
      status: current.status == QoshniPlatformSupportCaseStatus.open
          ? QoshniPlatformSupportCaseStatus.assigned
          : current.status,
      updatedAt: updatedAtUtc.toUtc(),
      history: List.unmodifiable([...current.history, historyEntry]),
    );
    return QoshniPlatformSupportMutationResult.success;
  }

  @override
  QoshniPlatformSupportMutationResult addInternalNote({
    required String caseId,
    required QoshniPlatformSupportInternalNote note,
    required QoshniPlatformGovernanceHistoryEntry historyEntry,
    required DateTime updatedAtUtc,
  }) {
    if (qoshniPlatformSupportNoteValidationError(note.body) != null) {
      return QoshniPlatformSupportMutationResult.invalidInput;
    }
    final index = _items.indexWhere((item) => item.caseId == caseId);
    if (index < 0) {
      return QoshniPlatformSupportMutationResult.notFound;
    }
    if (failNextMutation) {
      failNextMutation = false;
      return QoshniPlatformSupportMutationResult.failure;
    }
    final current = _items[index];
    _items[index] = current.copyWith(
      updatedAt: updatedAtUtc.toUtc(),
      internalNotes: List.unmodifiable([...current.internalNotes, note]),
      history: List.unmodifiable([...current.history, historyEntry]),
    );
    return QoshniPlatformSupportMutationResult.success;
  }
}

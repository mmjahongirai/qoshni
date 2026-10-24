import 'package:qoshni/features/platform_governance/data/qoshni_platform_business_verification_demo_seed.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_business_verification_lifecycle_policy.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_business_verification_submission.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_business_verification_submission_status.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_governance_history_entry.dart';
import 'package:qoshni/features/platform_governance/domain/repositories/qoshni_platform_business_verification_queue_repository.dart';

class InMemoryQoshniPlatformBusinessVerificationQueueRepository
    implements QoshniPlatformBusinessVerificationQueueRepository {
  InMemoryQoshniPlatformBusinessVerificationQueueRepository({
    List<QoshniPlatformBusinessVerificationSubmission>? seed,
  }) : _items = _cloneSeed(seed ?? buildQoshniPlatformBusinessVerificationDemoSeed());

  final List<QoshniPlatformBusinessVerificationSubmission> _items;

  bool failNextMutation = false;

  static List<QoshniPlatformBusinessVerificationSubmission> _cloneSeed(
    List<QoshniPlatformBusinessVerificationSubmission> seed,
  ) {
    return seed.map(_clone).toList(growable: true);
  }

  static QoshniPlatformBusinessVerificationSubmission _clone(
    QoshniPlatformBusinessVerificationSubmission item,
  ) {
    return item.copyWith(
      history: List.unmodifiable(item.history),
    );
  }

  @override
  List<QoshniPlatformBusinessVerificationSubmission> list({
    QoshniPlatformBusinessVerificationSubmissionStatus? status,
  }) {
    var result = _items.map(_clone).toList();
    if (status != null) {
      result = result.where((item) => item.status == status).toList();
    }
    result.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return List.unmodifiable(result);
  }

  @override
  QoshniPlatformBusinessVerificationSubmission? find(String submissionId) {
    for (final item in _items) {
      if (item.submissionId == submissionId) {
        return _clone(item);
      }
    }
    return null;
  }

  @override
  QoshniPlatformBusinessVerificationMutationResult transitionStatus({
    required String submissionId,
    required QoshniPlatformBusinessVerificationSubmissionStatus toStatus,
    required QoshniPlatformGovernanceHistoryEntry historyEntry,
    required DateTime updatedAtUtc,
  }) {
    final index = _items.indexWhere((item) => item.submissionId == submissionId);
    if (index < 0) {
      return QoshniPlatformBusinessVerificationMutationResult.notFound;
    }
    final current = _items[index];
    if (!QoshniPlatformBusinessVerificationLifecyclePolicy.canTransition(
      current.status,
      toStatus,
    )) {
      return QoshniPlatformBusinessVerificationMutationResult.invalidTransition;
    }
    if (historyEntry.fromStatus != current.status.wireValue) {
      return QoshniPlatformBusinessVerificationMutationResult.invalidInput;
    }
    if (failNextMutation) {
      failNextMutation = false;
      return QoshniPlatformBusinessVerificationMutationResult.failure;
    }
    final history = [...current.history, historyEntry];
    _items[index] = current.copyWith(
      status: toStatus,
      updatedAt: updatedAtUtc.toUtc(),
      history: List.unmodifiable(history),
    );
    return QoshniPlatformBusinessVerificationMutationResult.success;
  }
}

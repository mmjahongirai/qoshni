import 'package:qoshni/features/notifications/domain/qoshni_notification_provenance.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_governance_history_entry.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_moderation_case_status.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_moderation_target_type.dart';

enum QoshniPlatformModerationPriority { low, normal, high }

class QoshniPlatformModerationCase {
  const QoshniPlatformModerationCase({
    required this.caseId,
    required this.targetType,
    required this.syntheticTargetReference,
    required this.businessReference,
    this.branchReference,
    required this.reasonCategoryKey,
    required this.priority,
    required this.syntheticSourceReference,
    required this.safeSummary,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.history,
  });

  final String caseId;
  final QoshniPlatformModerationTargetType targetType;
  final String syntheticTargetReference;
  final String businessReference;
  final String? branchReference;
  final String reasonCategoryKey;
  final QoshniPlatformModerationPriority priority;
  final String syntheticSourceReference;
  final String safeSummary;
  final QoshniPlatformModerationCaseStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<QoshniPlatformGovernanceHistoryEntry> history;

  QoshniNotificationProvenance get provenance =>
      QoshniNotificationProvenance.syntheticDemo;

  QoshniPlatformModerationCase copyWith({
    QoshniPlatformModerationCaseStatus? status,
    DateTime? updatedAt,
    List<QoshniPlatformGovernanceHistoryEntry>? history,
  }) {
    return QoshniPlatformModerationCase(
      caseId: caseId,
      targetType: targetType,
      syntheticTargetReference: syntheticTargetReference,
      businessReference: businessReference,
      branchReference: branchReference,
      reasonCategoryKey: reasonCategoryKey,
      priority: priority,
      safeSummary: safeSummary,
      syntheticSourceReference: syntheticSourceReference,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      history: history ?? List.unmodifiable(this.history),
    );
  }
}

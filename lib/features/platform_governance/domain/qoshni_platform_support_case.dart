import 'package:qoshni/features/notifications/domain/qoshni_notification_provenance.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_governance_history_entry.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_support_case_status.dart';

enum QoshniPlatformSupportCaseCategory {
  accountAccess,
  orderIssue,
  businessListing,
  policyQuestion,
}

enum QoshniPlatformSupportCasePriority { low, normal, high }

class QoshniPlatformSupportInternalNote {
  const QoshniPlatformSupportInternalNote({
    required this.noteId,
    required this.authorAdminReference,
    required this.body,
    required this.recordedAt,
  });

  final String noteId;
  final String authorAdminReference;
  final String body;
  final DateTime recordedAt;
}

class QoshniPlatformSupportCase {
  const QoshniPlatformSupportCase({
    required this.caseId,
    required this.syntheticRequesterReference,
    this.businessReference,
    this.branchReference,
    required this.category,
    required this.priority,
    required this.status,
    required this.safeSummary,
    this.assignedRoleKey,
    required this.createdAt,
    required this.updatedAt,
    required this.history,
    required this.internalNotes,
  });

  final String caseId;
  final String syntheticRequesterReference;
  final String? businessReference;
  final String? branchReference;
  final QoshniPlatformSupportCaseCategory category;
  final QoshniPlatformSupportCasePriority priority;
  final QoshniPlatformSupportCaseStatus status;
  final String safeSummary;
  final String? assignedRoleKey;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<QoshniPlatformGovernanceHistoryEntry> history;
  final List<QoshniPlatformSupportInternalNote> internalNotes;

  QoshniNotificationProvenance get provenance =>
      QoshniNotificationProvenance.syntheticDemo;

  QoshniPlatformSupportCase copyWith({
    QoshniPlatformSupportCaseStatus? status,
    String? assignedRoleKey,
    DateTime? updatedAt,
    List<QoshniPlatformGovernanceHistoryEntry>? history,
    List<QoshniPlatformSupportInternalNote>? internalNotes,
  }) {
    return QoshniPlatformSupportCase(
      caseId: caseId,
      syntheticRequesterReference: syntheticRequesterReference,
      businessReference: businessReference,
      branchReference: branchReference,
      category: category,
      priority: priority,
      safeSummary: safeSummary,
      status: status ?? this.status,
      assignedRoleKey: assignedRoleKey ?? this.assignedRoleKey,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      history: history ?? List.unmodifiable(this.history),
      internalNotes: internalNotes ?? List.unmodifiable(this.internalNotes),
    );
  }
}

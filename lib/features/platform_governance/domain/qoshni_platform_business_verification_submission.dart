import 'package:qoshni/features/notifications/domain/qoshni_notification_provenance.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_business_verification_submission_status.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_governance_history_entry.dart';

class QoshniPlatformBusinessVerificationSubmission {
  const QoshniPlatformBusinessVerificationSubmission({
    required this.submissionId,
    required this.syntheticApplicationReference,
    required this.businessReference,
    this.branchReference,
    required this.documentCategoryKey,
    required this.safeSummary,
    required this.status,
    required this.submittedAt,
    required this.updatedAt,
    required this.history,
  });

  final String submissionId;
  final String syntheticApplicationReference;
  final String businessReference;
  final String? branchReference;
  final String documentCategoryKey;
  final String safeSummary;
  final QoshniPlatformBusinessVerificationSubmissionStatus status;
  final DateTime submittedAt;
  final DateTime updatedAt;
  final List<QoshniPlatformGovernanceHistoryEntry> history;

  QoshniNotificationProvenance get provenance =>
      QoshniNotificationProvenance.syntheticDemo;

  QoshniPlatformBusinessVerificationSubmission copyWith({
    QoshniPlatformBusinessVerificationSubmissionStatus? status,
    DateTime? updatedAt,
    List<QoshniPlatformGovernanceHistoryEntry>? history,
  }) {
    return QoshniPlatformBusinessVerificationSubmission(
      submissionId: submissionId,
      syntheticApplicationReference: syntheticApplicationReference,
      businessReference: businessReference,
      branchReference: branchReference,
      documentCategoryKey: documentCategoryKey,
      safeSummary: safeSummary,
      status: status ?? this.status,
      submittedAt: submittedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      history: history ?? List.unmodifiable(this.history),
    );
  }
}

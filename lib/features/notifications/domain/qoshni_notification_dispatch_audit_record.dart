import 'package:qoshni/features/notifications/domain/qoshni_notification_category.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_channel.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_delivery_eligibility.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_dispatch_outcome.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_dispatch_source.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_priority.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_provenance.dart';

class QoshniNotificationDispatchAuditRecord {
  const QoshniNotificationDispatchAuditRecord({
    required this.auditRecordId,
    required this.recordedAt,
    required this.demoRecipientReference,
    required this.category,
    required this.channel,
    required this.priority,
    required this.titleSummary,
    required this.idempotencyReference,
    required this.correlationReference,
    required this.source,
    required this.outcome,
    required this.eligibilityReason,
    required this.channelSimulationMessage,
    required this.provenance,
    this.inboxNotificationId,
  });

  final String auditRecordId;
  final DateTime recordedAt;
  final String demoRecipientReference;
  final QoshniNotificationCategory category;
  final QoshniNotificationChannel channel;
  final QoshniNotificationPriority priority;
  final String titleSummary;
  final String idempotencyReference;
  final String correlationReference;
  final QoshniNotificationDispatchSource source;
  final QoshniNotificationDispatchOutcome outcome;
  final QoshniNotificationEligibilityReason eligibilityReason;
  final String channelSimulationMessage;
  final QoshniNotificationProvenance provenance;
  final String? inboxNotificationId;

  bool get isSyntheticDemo =>
      provenance == QoshniNotificationProvenance.syntheticDemo;
}

class QoshniNotificationDispatchOperationResult {
  const QoshniNotificationDispatchOperationResult({
    required this.outcome,
    this.auditRecord,
  });

  final QoshniNotificationDispatchOutcome outcome;
  final QoshniNotificationDispatchAuditRecord? auditRecord;
}

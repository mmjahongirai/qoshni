import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/features/notifications/data/in_memory_qoshni_notification_dispatch_audit_repository.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_category.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_channel.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_delivery_eligibility.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_dispatch_audit_record.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_dispatch_outcome.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_dispatch_source.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_priority.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_provenance.dart';
import 'package:qoshni/features/notifications/domain/repositories/qoshni_notification_dispatch_audit_repository.dart';

void main() {
  late InMemoryQoshniNotificationDispatchAuditRepository repo;

  setUp(() {
    repo = InMemoryQoshniNotificationDispatchAuditRepository();
  });

  QoshniNotificationDispatchAuditRecord record(String idem) {
    return QoshniNotificationDispatchAuditRecord(
      auditRecordId: repo.nextAuditRecordId(),
      recordedAt: DateTime.utc(2025, 4, 10, 12, 0),
      demoRecipientReference: 'demo-inbox-recipient-001',
      category: QoshniNotificationCategory.orders,
      channel: QoshniNotificationChannel.inApp,
      priority: QoshniNotificationPriority.normal,
      titleSummary: 'Demo audit',
      idempotencyReference: idem,
      correlationReference: 'corr-$idem',
      source: QoshniNotificationDispatchSource.demoDiagnostics,
      outcome: QoshniNotificationDispatchOutcome.deliveredToInbox,
      eligibilityReason: QoshniNotificationEligibilityReason.eligible,
      channelSimulationMessage: 'Simulated in-app delivery succeeded.',
      provenance: QoshniNotificationProvenance.syntheticDemo,
    );
  }

  test('append is duplicate-safe by idempotency reference', () {
    expect(repo.append(record('idem-001')), QoshniNotificationDispatchAuditAppendResult.success);
    expect(
      repo.append(record('idem-001')),
      QoshniNotificationDispatchAuditAppendResult.duplicateIdempotencyReference,
    );
    expect(repo.list().length, 1);
  });

  test('failNextAppend leaves audit list unchanged', () {
    repo.failNextAppend = true;
    expect(repo.append(record('idem-fail')), QoshniNotificationDispatchAuditAppendResult.failure);
    expect(repo.list(), isEmpty);
    expect(repo.hasIdempotencyReference('idem-fail'), isFalse);
  });
}

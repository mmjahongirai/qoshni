import 'package:qoshni/features/notifications/domain/qoshni_notification_category.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_channel.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_dispatch_audit_record.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_dispatch_outcome.dart';

enum QoshniNotificationDispatchAuditAppendResult {
  success,
  duplicateIdempotencyReference,
  invalidInput,
  failure,
}

abstract class QoshniNotificationDispatchAuditRepository {
  List<QoshniNotificationDispatchAuditRecord> list({
    QoshniNotificationDispatchOutcome? outcome,
    QoshniNotificationCategory? category,
    QoshniNotificationChannel? channel,
  });

  bool hasIdempotencyReference(String idempotencyReference);

  QoshniNotificationDispatchAuditRecord? findByIdempotencyReference(
    String idempotencyReference,
  );

  QoshniNotificationDispatchAuditAppendResult append(
    QoshniNotificationDispatchAuditRecord record,
  );
}

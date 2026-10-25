import 'package:qoshni/features/notifications/domain/qoshni_notification_category.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_channel.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_dispatch_audit_record.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_dispatch_outcome.dart';
import 'package:qoshni/features/notifications/domain/repositories/qoshni_notification_dispatch_audit_repository.dart';
import 'package:qoshni/features/notifications/presentation/qoshni_notification_dispatch_validation.dart';
import 'package:qoshni/features/notifications/presentation/qoshni_notification_validation.dart';

class InMemoryQoshniNotificationDispatchAuditRepository
    implements QoshniNotificationDispatchAuditRepository {
  final List<QoshniNotificationDispatchAuditRecord> _records = [];
  final Map<String, String> _idempotencyToAuditId = {};

  int _auditCounter = 0;
  bool failNextAppend = false;

  @override
  List<QoshniNotificationDispatchAuditRecord> list({
    QoshniNotificationDispatchOutcome? outcome,
    QoshniNotificationCategory? category,
    QoshniNotificationChannel? channel,
  }) {
    var result = List<QoshniNotificationDispatchAuditRecord>.from(_records);
    if (outcome != null) {
      result = result.where((r) => r.outcome == outcome).toList(growable: true);
    }
    if (category != null) {
      result = result.where((r) => r.category == category).toList(growable: true);
    }
    if (channel != null) {
      result = result.where((r) => r.channel == channel).toList(growable: true);
    }
    _sortInPlace(result);
    return List.unmodifiable(result);
  }

  @override
  bool hasIdempotencyReference(String idempotencyReference) {
    final idem = idempotencyReference.trim();
    return _idempotencyToAuditId.containsKey(idem);
  }

  @override
  QoshniNotificationDispatchAuditRecord? findByIdempotencyReference(
    String idempotencyReference,
  ) {
    final id = _idempotencyToAuditId[idempotencyReference.trim()];
    if (id == null) {
      return null;
    }
    for (final record in _records) {
      if (record.auditRecordId == id) {
        return record;
      }
    }
    return null;
  }

  @override
  QoshniNotificationDispatchAuditAppendResult append(
    QoshniNotificationDispatchAuditRecord record,
  ) {
    if (qoshniNotificationIdValidationError(record.auditRecordId) != null) {
      return QoshniNotificationDispatchAuditAppendResult.invalidInput;
    }
    final idem = record.idempotencyReference.trim();
    if (idem.isEmpty || idem.length > kQoshniNotificationIdempotencyMaxLength) {
      return QoshniNotificationDispatchAuditAppendResult.invalidInput;
    }
    if (_idempotencyToAuditId.containsKey(idem)) {
      return QoshniNotificationDispatchAuditAppendResult
          .duplicateIdempotencyReference;
    }

    if (failNextAppend) {
      failNextAppend = false;
      return QoshniNotificationDispatchAuditAppendResult.failure;
    }

    _records.add(record);
    _idempotencyToAuditId[idem] = record.auditRecordId;
    _sortInPlace(_records);
    return QoshniNotificationDispatchAuditAppendResult.success;
  }

  String nextAuditRecordId() {
    _auditCounter++;
    return 'dispatch-audit-${_auditCounter.toString().padLeft(4, '0')}';
  }

  void _sortInPlace(List<QoshniNotificationDispatchAuditRecord> list) {
    list.sort((a, b) {
      final byTime = b.recordedAt.compareTo(a.recordedAt);
      if (byTime != 0) {
        return byTime;
      }
      return a.auditRecordId.compareTo(b.auditRecordId);
    });
  }
}

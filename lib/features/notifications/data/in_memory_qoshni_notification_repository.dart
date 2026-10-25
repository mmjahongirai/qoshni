import 'package:qoshni/features/notifications/data/qoshni_notification_demo_seed.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_category.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_read_status.dart';
import 'package:qoshni/features/notifications/domain/repositories/qoshni_notification_repository.dart';
import 'package:qoshni/features/notifications/presentation/qoshni_notification_validation.dart';

class InMemoryQoshniNotificationRepository
    implements QoshniNotificationRepository {
  InMemoryQoshniNotificationRepository();

  final List<QoshniNotification> _items = [];
  final Set<String> _deduplicationKeys = {};
  bool _seeded = false;
  int _deliverCounter = 0;

  bool failNextMarkRead = false;
  bool failNextMarkAllRead = false;
  bool failNextDeliver = false;

  @override
  String get demoRecipientReference => kDemoNotificationRecipientReference;

  @override
  List<QoshniNotification> list({
    QoshniNotificationReadFilter readFilter =
        QoshniNotificationReadFilter.all,
    QoshniNotificationCategory? category,
  }) {
    var result = List<QoshniNotification>.from(_ensureSeeded());
    if (readFilter == QoshniNotificationReadFilter.unreadOnly) {
      result = result.where((n) => n.isUnread).toList(growable: true);
    }
    if (category != null) {
      result = result.where((n) => n.category == category).toList(growable: true);
    }
    _sortInPlace(result);
    return List.unmodifiable(result);
  }

  @override
  int unreadCount() {
    return _ensureSeeded().where((n) => n.isUnread).length;
  }

  @override
  QoshniNotification? findById(String notificationId) {
    if (qoshniNotificationIdValidationError(notificationId) != null) {
      return null;
    }
    final id = notificationId.trim();
    for (final item in _ensureSeeded()) {
      if (item.notificationId == id) {
        return item;
      }
    }
    return null;
  }

  @override
  QoshniNotificationMarkReadResult markRead(String notificationId) {
    if (qoshniNotificationIdValidationError(notificationId) != null) {
      return QoshniNotificationMarkReadResult.invalidId;
    }
    if (failNextMarkRead) {
      failNextMarkRead = false;
      return QoshniNotificationMarkReadResult.failure;
    }

    final id = notificationId.trim();
    final index = _items.indexWhere((n) => n.notificationId == id);
    if (index < 0) {
      return QoshniNotificationMarkReadResult.notFound;
    }
    final current = _items[index];
    if (!current.isUnread) {
      return QoshniNotificationMarkReadResult.alreadyRead;
    }

    final now = DateTime.now().toUtc();
    _items[index] = current.copyWith(
      readStatus: QoshniNotificationReadStatus.read,
      readAt: now,
    );
    return QoshniNotificationMarkReadResult.success;
  }

  @override
  QoshniNotificationMarkAllReadResult markAllRead() {
    if (failNextMarkAllRead) {
      failNextMarkAllRead = false;
      return QoshniNotificationMarkAllReadResult.failure;
    }

    final now = DateTime.now().toUtc();
    for (var i = 0; i < _items.length; i++) {
      final current = _items[i];
      if (current.isUnread) {
        _items[i] = current.copyWith(
          readStatus: QoshniNotificationReadStatus.read,
          readAt: now,
        );
      }
    }
    return QoshniNotificationMarkAllReadResult.success;
  }

  @override
  QoshniNotificationDeliverResult deliver(
    QoshniNotificationDeliverInput input,
  ) {
    if (qoshniNotificationDeliverValidationError(input) != null) {
      return QoshniNotificationDeliverResult.invalidInput;
    }

    final dedupe = input.deduplicationReference?.trim();
    if (dedupe != null && dedupe.isNotEmpty) {
      if (_deduplicationKeys.contains(dedupe)) {
        return QoshniNotificationDeliverResult.duplicateDeduplicationReference;
      }
    }

    if (failNextDeliver) {
      failNextDeliver = false;
      return QoshniNotificationDeliverResult.failure;
    }

    _ensureSeeded();
    _deliverCounter++;
    final id = 'session-notification-$_deliverCounter';
    final notification = QoshniNotification(
      notificationId: id,
      demoRecipientReference: input.demoRecipientReference.trim(),
      category: input.category,
      channel: input.channel,
      title: input.title.trim(),
      body: input.body.trim(),
      createdAt: input.createdAt.toUtc(),
      readStatus: QoshniNotificationReadStatus.unread,
      priority: input.priority,
      internalNavigationRoute: input.internalNavigationRoute?.trim(),
      provenance: input.provenance,
      deduplicationReference: dedupe,
    );

    _items.add(notification);
    if (dedupe != null && dedupe.isNotEmpty) {
      _deduplicationKeys.add(dedupe);
    }
    _sortInPlace(_items);
    return QoshniNotificationDeliverResult.success;
  }

  List<QoshniNotification> _ensureSeeded() {
    if (!_seeded) {
      _items.addAll(
        buildDemoQoshniNotifications(
          demoRecipientReference: demoRecipientReference,
        ),
      );
      for (final item in _items) {
        final dedupe = item.deduplicationReference?.trim();
        if (dedupe != null && dedupe.isNotEmpty) {
          _deduplicationKeys.add(dedupe);
        }
      }
      _sortInPlace(_items);
      _seeded = true;
    }
    return _items;
  }

  void _sortInPlace(List<QoshniNotification> list) {
    list.sort((a, b) {
      final byTime = b.createdAt.compareTo(a.createdAt);
      if (byTime != 0) {
        return byTime;
      }
      return a.notificationId.compareTo(b.notificationId);
    });
  }
}

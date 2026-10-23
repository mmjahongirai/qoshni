import 'package:qoshni/features/notifications/domain/qoshni_notification.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_category.dart';

enum QoshniNotificationReadFilter {
  all,
  unreadOnly,
}

enum QoshniNotificationMarkReadResult {
  success,
  alreadyRead,
  notFound,
  invalidId,
  failure,
}

enum QoshniNotificationMarkAllReadResult {
  success,
  failure,
}

enum QoshniNotificationDeliverResult {
  success,
  duplicateDeduplicationReference,
  invalidInput,
  failure,
}

abstract class QoshniNotificationRepository {
  String get demoRecipientReference;

  List<QoshniNotification> list({
    QoshniNotificationReadFilter readFilter = QoshniNotificationReadFilter.all,
    QoshniNotificationCategory? category,
  });

  int unreadCount();

  QoshniNotification? findById(String notificationId);

  QoshniNotificationMarkReadResult markRead(String notificationId);

  QoshniNotificationMarkAllReadResult markAllRead();

  QoshniNotificationDeliverResult deliver(QoshniNotificationDeliverInput input);
}

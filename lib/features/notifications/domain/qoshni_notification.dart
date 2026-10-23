import 'package:qoshni/features/notifications/domain/qoshni_notification_category.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_channel.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_priority.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_provenance.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_read_status.dart';

class QoshniNotification {
  const QoshniNotification({
    required this.notificationId,
    required this.demoRecipientReference,
    required this.category,
    required this.channel,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.readStatus,
    this.readAt,
    required this.priority,
    this.internalNavigationRoute,
    required this.provenance,
    this.deduplicationReference,
  });

  final String notificationId;
  final String demoRecipientReference;
  final QoshniNotificationCategory category;
  final QoshniNotificationChannel channel;
  final String title;
  final String body;
  final DateTime createdAt;
  final QoshniNotificationReadStatus readStatus;
  final DateTime? readAt;
  final QoshniNotificationPriority priority;
  final String? internalNavigationRoute;
  final QoshniNotificationProvenance provenance;
  final String? deduplicationReference;

  bool get isSyntheticDemo =>
      provenance == QoshniNotificationProvenance.syntheticDemo;

  bool get isUnread => readStatus == QoshniNotificationReadStatus.unread;

  QoshniNotification copyWith({
    QoshniNotificationReadStatus? readStatus,
    DateTime? readAt,
  }) {
    return QoshniNotification(
      notificationId: notificationId,
      demoRecipientReference: demoRecipientReference,
      category: category,
      channel: channel,
      title: title,
      body: body,
      createdAt: createdAt,
      readStatus: readStatus ?? this.readStatus,
      readAt: readAt ?? this.readAt,
      priority: priority,
      internalNavigationRoute: internalNavigationRoute,
      provenance: provenance,
      deduplicationReference: deduplicationReference,
    );
  }
}

class QoshniNotificationDeliverInput {
  const QoshniNotificationDeliverInput({
    required this.demoRecipientReference,
    required this.category,
    required this.channel,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.priority,
    this.internalNavigationRoute,
    required this.provenance,
    this.deduplicationReference,
  });

  final String demoRecipientReference;
  final QoshniNotificationCategory category;
  final QoshniNotificationChannel channel;
  final String title;
  final String body;
  final DateTime createdAt;
  final QoshniNotificationPriority priority;
  final String? internalNavigationRoute;
  final QoshniNotificationProvenance provenance;
  final String? deduplicationReference;
}

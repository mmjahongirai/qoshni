import 'package:qoshni/features/notifications/domain/qoshni_notification_category.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_channel.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_dispatch_source.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_priority.dart';

class QoshniNotificationDispatchRequest {
  const QoshniNotificationDispatchRequest({
    required this.demoRecipientReference,
    required this.category,
    required this.channel,
    required this.priority,
    required this.title,
    required this.body,
    required this.idempotencyReference,
    required this.correlationReference,
    required this.source,
    required this.evaluationLocalDateTime,
    this.internalNavigationRoute,
  });

  final String demoRecipientReference;
  final QoshniNotificationCategory category;
  final QoshniNotificationChannel channel;
  final QoshniNotificationPriority priority;
  final String title;
  final String body;
  final String idempotencyReference;
  final String correlationReference;
  final QoshniNotificationDispatchSource source;
  final DateTime evaluationLocalDateTime;
  final String? internalNavigationRoute;
}

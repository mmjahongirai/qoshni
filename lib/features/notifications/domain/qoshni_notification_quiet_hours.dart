import 'package:qoshni/features/notifications/domain/qoshni_local_time.dart';

class QoshniNotificationQuietHours {
  const QoshniNotificationQuietHours({
    required this.enabled,
    required this.start,
    required this.end,
  });

  final bool enabled;
  final QoshniLocalTime start;
  final QoshniLocalTime end;

  QoshniNotificationQuietHours copyWith({
    bool? enabled,
    QoshniLocalTime? start,
    QoshniLocalTime? end,
  }) {
    return QoshniNotificationQuietHours(
      enabled: enabled ?? this.enabled,
      start: start ?? this.start,
      end: end ?? this.end,
    );
  }
}

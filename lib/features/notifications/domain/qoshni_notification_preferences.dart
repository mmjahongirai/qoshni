import 'package:qoshni/features/notifications/domain/qoshni_notification_category.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_channel.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_quiet_hours.dart';

class QoshniNotificationPreferences {
  const QoshniNotificationPreferences({
    required this.demoRecipientReference,
    required this.categoryEnabled,
    required this.channelEnabled,
    required this.promotionalMarketingConsent,
    required this.quietHours,
  });

  final String demoRecipientReference;
  final Map<QoshniNotificationCategory, bool> categoryEnabled;
  final Map<QoshniNotificationChannel, bool> channelEnabled;
  final bool promotionalMarketingConsent;
  final QoshniNotificationQuietHours quietHours;

  bool isCategoryEnabled(QoshniNotificationCategory category) =>
      categoryEnabled[category] ?? false;

  bool isChannelEnabled(QoshniNotificationChannel channel) =>
      channelEnabled[channel] ?? false;

  QoshniNotificationPreferences copyWith({
    Map<QoshniNotificationCategory, bool>? categoryEnabled,
    Map<QoshniNotificationChannel, bool>? channelEnabled,
    bool? promotionalMarketingConsent,
    QoshniNotificationQuietHours? quietHours,
  }) {
    return QoshniNotificationPreferences(
      demoRecipientReference: demoRecipientReference,
      categoryEnabled: categoryEnabled ?? this.categoryEnabled,
      channelEnabled: channelEnabled ?? this.channelEnabled,
      promotionalMarketingConsent:
          promotionalMarketingConsent ?? this.promotionalMarketingConsent,
      quietHours: quietHours ?? this.quietHours,
    );
  }
}

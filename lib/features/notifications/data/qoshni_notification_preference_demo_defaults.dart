import 'package:qoshni/features/notifications/data/qoshni_notification_demo_seed.dart';
import 'package:qoshni/features/notifications/domain/qoshni_local_time.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_category.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_channel.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_preferences.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_quiet_hours.dart';

QoshniNotificationPreferences buildDefaultDemoNotificationPreferences() {
  final categories = {
    for (final c in QoshniNotificationCategory.values) c: true,
  };
  categories[QoshniNotificationCategory.promotions] = true;

  final channels = {
    for (final c in QoshniNotificationChannel.values)
      c: c == QoshniNotificationChannel.inApp,
  };
  channels[QoshniNotificationChannel.pushPreview] = false;
  channels[QoshniNotificationChannel.smsPreview] = false;
  channels[QoshniNotificationChannel.emailPreview] = false;

  return QoshniNotificationPreferences(
    demoRecipientReference: kDemoNotificationRecipientReference,
    categoryEnabled: categories,
    channelEnabled: channels,
    promotionalMarketingConsent: false,
    quietHours: const QoshniNotificationQuietHours(
      enabled: true,
      start: QoshniLocalTime(hour: 22, minute: 0),
      end: QoshniLocalTime(hour: 7, minute: 0),
    ),
  );
}

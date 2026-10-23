import 'package:qoshni/features/notifications/domain/qoshni_local_time.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_category.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_channel.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_preferences.dart';

enum QoshniNotificationPreferenceUpdateResult {
  success,
  invalidInput,
  failure,
}

abstract class QoshniNotificationPreferenceRepository {
  QoshniNotificationPreferences get preferences;

  QoshniNotificationPreferenceUpdateResult setCategoryEnabled({
    required QoshniNotificationCategory category,
    required bool enabled,
  });

  QoshniNotificationPreferenceUpdateResult setChannelEnabled({
    required QoshniNotificationChannel channel,
    required bool enabled,
  });

  QoshniNotificationPreferenceUpdateResult setPromotionalMarketingConsent({
    required bool consent,
  });

  QoshniNotificationPreferenceUpdateResult setQuietHours({
    required bool enabled,
    required QoshniLocalTime start,
    required QoshniLocalTime end,
  });

  QoshniNotificationPreferenceUpdateResult restoreDemoDefaults();
}

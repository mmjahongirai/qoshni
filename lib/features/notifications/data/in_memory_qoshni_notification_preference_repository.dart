import 'package:qoshni/features/notifications/data/qoshni_notification_preference_demo_defaults.dart';
import 'package:qoshni/features/notifications/domain/qoshni_local_time.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_category.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_channel.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_preferences.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_quiet_hours.dart';
import 'package:qoshni/features/notifications/domain/repositories/qoshni_notification_preference_repository.dart';
import 'package:qoshni/features/notifications/presentation/qoshni_notification_preference_validation.dart';

class InMemoryQoshniNotificationPreferenceRepository
    implements QoshniNotificationPreferenceRepository {
  InMemoryQoshniNotificationPreferenceRepository() {
    _preferences = buildDefaultDemoNotificationPreferences();
  }

  late QoshniNotificationPreferences _preferences;

  bool failNextUpdate = false;

  @override
  QoshniNotificationPreferences get preferences => _clone(_preferences);

  @override
  QoshniNotificationPreferenceUpdateResult setCategoryEnabled({
    required QoshniNotificationCategory category,
    required bool enabled,
  }) {
    if (!QoshniNotificationCategory.values.contains(category)) {
      return QoshniNotificationPreferenceUpdateResult.invalidInput;
    }
    if (failNextUpdate) {
      failNextUpdate = false;
      return QoshniNotificationPreferenceUpdateResult.failure;
    }

    final next = Map<QoshniNotificationCategory, bool>.from(
      _preferences.categoryEnabled,
    )..[category] = enabled;
    _preferences = _preferences.copyWith(categoryEnabled: next);
    return QoshniNotificationPreferenceUpdateResult.success;
  }

  @override
  QoshniNotificationPreferenceUpdateResult setChannelEnabled({
    required QoshniNotificationChannel channel,
    required bool enabled,
  }) {
    if (!QoshniNotificationChannel.values.contains(channel)) {
      return QoshniNotificationPreferenceUpdateResult.invalidInput;
    }
    if (failNextUpdate) {
      failNextUpdate = false;
      return QoshniNotificationPreferenceUpdateResult.failure;
    }

    final next = Map<QoshniNotificationChannel, bool>.from(
      _preferences.channelEnabled,
    )..[channel] = enabled;
    _preferences = _preferences.copyWith(channelEnabled: next);
    return QoshniNotificationPreferenceUpdateResult.success;
  }

  @override
  QoshniNotificationPreferenceUpdateResult setPromotionalMarketingConsent({
    required bool consent,
  }) {
    if (failNextUpdate) {
      failNextUpdate = false;
      return QoshniNotificationPreferenceUpdateResult.failure;
    }
    _preferences = _preferences.copyWith(promotionalMarketingConsent: consent);
    return QoshniNotificationPreferenceUpdateResult.success;
  }

  @override
  QoshniNotificationPreferenceUpdateResult setQuietHours({
    required bool enabled,
    required QoshniLocalTime start,
    required QoshniLocalTime end,
  }) {
    if (qoshniQuietHoursValidationError(start: start, end: end) != null) {
      return QoshniNotificationPreferenceUpdateResult.invalidInput;
    }
    if (failNextUpdate) {
      failNextUpdate = false;
      return QoshniNotificationPreferenceUpdateResult.failure;
    }

    _preferences = _preferences.copyWith(
      quietHours: QoshniNotificationQuietHours(
        enabled: enabled,
        start: start,
        end: end,
      ),
    );
    return QoshniNotificationPreferenceUpdateResult.success;
  }

  @override
  QoshniNotificationPreferenceUpdateResult restoreDemoDefaults() {
    if (failNextUpdate) {
      failNextUpdate = false;
      return QoshniNotificationPreferenceUpdateResult.failure;
    }
    _preferences = buildDefaultDemoNotificationPreferences();
    return QoshniNotificationPreferenceUpdateResult.success;
  }

  QoshniNotificationPreferences _clone(QoshniNotificationPreferences source) {
    return QoshniNotificationPreferences(
      demoRecipientReference: source.demoRecipientReference,
      categoryEnabled: Map<QoshniNotificationCategory, bool>.from(
        source.categoryEnabled,
      ),
      channelEnabled: Map<QoshniNotificationChannel, bool>.from(
        source.channelEnabled,
      ),
      promotionalMarketingConsent: source.promotionalMarketingConsent,
      quietHours: QoshniNotificationQuietHours(
        enabled: source.quietHours.enabled,
        start: source.quietHours.start,
        end: source.quietHours.end,
      ),
    );
  }
}

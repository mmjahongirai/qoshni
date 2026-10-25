import 'package:qoshni/features/notifications/domain/qoshni_local_time.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_category.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_channel.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_delivery_eligibility.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_preferences.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_priority.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_quiet_hours.dart';

/// Pure policy evaluator for hypothetical delivery eligibility (no side effects).
abstract final class QoshniNotificationDeliveryPolicy {
  static QoshniNotificationEligibilityResult evaluate({
    required QoshniNotificationPreferences preferences,
    required QoshniNotificationEligibilityInput scenario,
    required DateTime evaluationLocalDateTime,
  }) {
    if (!_isKnownCategory(scenario.category) || !_isKnownChannel(scenario.channel)) {
      return const QoshniNotificationEligibilityResult(
        isEligible: false,
        reason: QoshniNotificationEligibilityReason.suppressedInvalidInput,
      );
    }

    if (!preferences.isCategoryEnabled(scenario.category)) {
      return const QoshniNotificationEligibilityResult(
        isEligible: false,
        reason: QoshniNotificationEligibilityReason.suppressedCategoryDisabled,
      );
    }

    if (!preferences.isChannelEnabled(scenario.channel)) {
      return const QoshniNotificationEligibilityResult(
        isEligible: false,
        reason: QoshniNotificationEligibilityReason.suppressedChannelDisabled,
      );
    }

    if (scenario.category == QoshniNotificationCategory.promotions &&
        !preferences.promotionalMarketingConsent) {
      return const QoshniNotificationEligibilityResult(
        isEligible: false,
        reason:
            QoshniNotificationEligibilityReason.suppressedPromotionalConsentDisabled,
      );
    }

    if (_isQuietHoursSuppression(
      preferences.quietHours,
      evaluationLocalDateTime,
      scenario,
    )) {
      return const QoshniNotificationEligibilityResult(
        isEligible: false,
        reason: QoshniNotificationEligibilityReason.suppressedQuietHours,
      );
    }

    return const QoshniNotificationEligibilityResult(
      isEligible: true,
      reason: QoshniNotificationEligibilityReason.eligible,
    );
  }

  static bool isWithinQuietHours({
    required QoshniNotificationQuietHours quietHours,
    required DateTime evaluationLocalDateTime,
  }) {
    if (!quietHours.enabled) {
      return false;
    }
    final local = QoshniLocalTime(
      hour: evaluationLocalDateTime.hour,
      minute: evaluationLocalDateTime.minute,
    );
    return _localTimeWithinQuietWindow(
      local,
      quietHours.start,
      quietHours.end,
    );
  }

  /// Local-time quiet window. Equal start/end means the full day is quiet.
  static bool _localTimeWithinQuietWindow(
    QoshniLocalTime now,
    QoshniLocalTime start,
    QoshniLocalTime end,
  ) {
    final nowM = now.minutesSinceMidnight;
    final startM = start.minutesSinceMidnight;
    final endM = end.minutesSinceMidnight;

    if (startM == endM) {
      return true;
    }
    if (startM < endM) {
      return nowM >= startM && nowM < endM;
    }
    return nowM >= startM || nowM < endM;
  }

  static bool _isQuietHoursSuppression(
    QoshniNotificationQuietHours quietHours,
    DateTime evaluationLocalDateTime,
    QoshniNotificationEligibilityInput scenario,
  ) {
    if (!_bypassesQuietHours(scenario)) {
      return isWithinQuietHours(
        quietHours: quietHours,
        evaluationLocalDateTime: evaluationLocalDateTime,
      );
    }
    return false;
  }

  /// Security category and urgent priority bypass quiet hours (category/channel rules still apply).
  static bool _bypassesQuietHours(QoshniNotificationEligibilityInput scenario) {
    return scenario.category == QoshniNotificationCategory.security ||
        scenario.priority == QoshniNotificationPriority.urgent;
  }

  static bool _isKnownCategory(QoshniNotificationCategory category) {
    return QoshniNotificationCategory.values.contains(category);
  }

  static bool _isKnownChannel(QoshniNotificationChannel channel) {
    return QoshniNotificationChannel.values.contains(channel);
  }
}

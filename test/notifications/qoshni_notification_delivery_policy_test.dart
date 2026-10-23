import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/features/notifications/data/qoshni_notification_preference_demo_defaults.dart';
import 'package:qoshni/features/notifications/domain/qoshni_local_time.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_category.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_channel.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_delivery_eligibility.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_delivery_policy.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_preferences.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_priority.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_quiet_hours.dart';

void main() {
  late QoshniNotificationPreferences prefs;

  setUp(() {
    prefs = buildDefaultDemoNotificationPreferences();
  });

  QoshniNotificationEligibilityInput scenario({
    QoshniNotificationCategory category = QoshniNotificationCategory.orders,
    QoshniNotificationChannel channel = QoshniNotificationChannel.inApp,
    QoshniNotificationPriority priority = QoshniNotificationPriority.normal,
  }) {
    return QoshniNotificationEligibilityInput(
      category: category,
      channel: channel,
      priority: priority,
    );
  }

  test('default demo preferences allow transactional delivery at midday', () {
    final result = QoshniNotificationDeliveryPolicy.evaluate(
      preferences: prefs,
      scenario: scenario(),
      evaluationLocalDateTime: DateTime(2025, 4, 10, 12, 0),
    );
    expect(result.isEligible, isTrue);
    expect(result.reason, QoshniNotificationEligibilityReason.eligible);
  });

  test('quiet hours suppress non-critical notifications at night', () {
    final result = QoshniNotificationDeliveryPolicy.evaluate(
      preferences: prefs,
      scenario: scenario(),
      evaluationLocalDateTime: DateTime(2025, 4, 10, 23, 30),
    );
    expect(result.isEligible, isFalse);
    expect(result.reason, QoshniNotificationEligibilityReason.suppressedQuietHours);
  });

  test('security category bypasses quiet hours', () {
    final result = QoshniNotificationDeliveryPolicy.evaluate(
      preferences: prefs,
      scenario: scenario(category: QoshniNotificationCategory.security),
      evaluationLocalDateTime: DateTime(2025, 4, 10, 23, 30),
    );
    expect(result.isEligible, isTrue);
  });

  test('urgent priority bypasses quiet hours', () {
    final result = QoshniNotificationDeliveryPolicy.evaluate(
      preferences: prefs,
      scenario: scenario(priority: QoshniNotificationPriority.urgent),
      evaluationLocalDateTime: DateTime(2025, 4, 10, 23, 30),
    );
    expect(result.isEligible, isTrue);
  });

  test('promotions require separate marketing consent', () {
    final result = QoshniNotificationDeliveryPolicy.evaluate(
      preferences: prefs,
      scenario: scenario(category: QoshniNotificationCategory.promotions),
      evaluationLocalDateTime: DateTime(2025, 4, 10, 12, 0),
    );
    expect(result.isEligible, isFalse);
    expect(
      result.reason,
      QoshniNotificationEligibilityReason.suppressedPromotionalConsentDisabled,
    );
  });

  test('disabled category suppresses delivery', () {
    final disabledCategory = Map<QoshniNotificationCategory, bool>.from(
      prefs.categoryEnabled,
    )..[QoshniNotificationCategory.orders] = false;
    final custom = prefs.copyWith(categoryEnabled: disabledCategory);

    final result = QoshniNotificationDeliveryPolicy.evaluate(
      preferences: custom,
      scenario: scenario(),
      evaluationLocalDateTime: DateTime(2025, 4, 10, 12, 0),
    );
    expect(result.reason, QoshniNotificationEligibilityReason.suppressedCategoryDisabled);
  });

  test('disabled channel suppresses delivery', () {
    final disabledChannel = Map<QoshniNotificationChannel, bool>.from(
      prefs.channelEnabled,
    )..[QoshniNotificationChannel.inApp] = false;
    final custom = prefs.copyWith(channelEnabled: disabledChannel);

    final result = QoshniNotificationDeliveryPolicy.evaluate(
      preferences: custom,
      scenario: scenario(),
      evaluationLocalDateTime: DateTime(2025, 4, 10, 12, 0),
    );
    expect(result.reason, QoshniNotificationEligibilityReason.suppressedChannelDisabled);
  });

  test('quiet hours crossing midnight treat late evening as inside window', () {
    expect(
      QoshniNotificationDeliveryPolicy.isWithinQuietHours(
        quietHours: prefs.quietHours,
        evaluationLocalDateTime: DateTime(2025, 4, 10, 23, 0),
      ),
      isTrue,
    );
    expect(
      QoshniNotificationDeliveryPolicy.isWithinQuietHours(
        quietHours: prefs.quietHours,
        evaluationLocalDateTime: DateTime(2025, 4, 10, 6, 30),
      ),
      isTrue,
    );
    expect(
      QoshniNotificationDeliveryPolicy.isWithinQuietHours(
        quietHours: prefs.quietHours,
        evaluationLocalDateTime: DateTime(2025, 4, 10, 12, 0),
      ),
      isFalse,
    );
  });

  test('equal start and end times mean full-day quiet for non-critical', () {
    final equalQuiet = prefs.copyWith(
      quietHours: const QoshniNotificationQuietHours(
        enabled: true,
        start: QoshniLocalTime(hour: 8, minute: 0),
        end: QoshniLocalTime(hour: 8, minute: 0),
      ),
    );
    final result = QoshniNotificationDeliveryPolicy.evaluate(
      preferences: equalQuiet,
      scenario: scenario(),
      evaluationLocalDateTime: DateTime(2025, 4, 10, 12, 0),
    );
    expect(result.reason, QoshniNotificationEligibilityReason.suppressedQuietHours);
  });

  test('disabled quiet hours never suppress', () {
    final off = prefs.copyWith(
      quietHours: prefs.quietHours.copyWith(enabled: false),
    );
    final result = QoshniNotificationDeliveryPolicy.evaluate(
      preferences: off,
      scenario: scenario(),
      evaluationLocalDateTime: DateTime(2025, 4, 10, 23, 30),
    );
    expect(result.isEligible, isTrue);
  });
}

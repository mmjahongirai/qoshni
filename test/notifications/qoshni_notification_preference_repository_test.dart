import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/features/notifications/data/in_memory_qoshni_notification_preference_repository.dart';
import 'package:qoshni/features/notifications/data/qoshni_notification_preference_demo_defaults.dart';
import 'package:qoshni/features/notifications/domain/qoshni_local_time.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_category.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_channel.dart';
import 'package:qoshni/features/notifications/domain/repositories/qoshni_notification_preference_repository.dart';

void main() {
  late InMemoryQoshniNotificationPreferenceRepository repo;

  setUp(() {
    repo = InMemoryQoshniNotificationPreferenceRepository();
  });

  test('loads deterministic demo defaults', () {
    final defaults = buildDefaultDemoNotificationPreferences();
    final loaded = repo.preferences;
    expect(loaded.demoRecipientReference, defaults.demoRecipientReference);
    expect(loaded.promotionalMarketingConsent, isFalse);
    expect(loaded.isCategoryEnabled(QoshniNotificationCategory.orders), isTrue);
    expect(loaded.quietHours.enabled, isTrue);
  });

  test('updates category preference without affecting other categories', () {
    final before = repo.preferences.isCategoryEnabled(
      QoshniNotificationCategory.delivery,
    );
    expect(
      repo.setCategoryEnabled(
        category: QoshniNotificationCategory.orders,
        enabled: false,
      ),
      QoshniNotificationPreferenceUpdateResult.success,
    );
    expect(repo.preferences.isCategoryEnabled(QoshniNotificationCategory.orders), isFalse);
    expect(
      repo.preferences.isCategoryEnabled(QoshniNotificationCategory.delivery),
      before,
    );
  });

  test('updates promotional consent independently from categories', () {
    expect(
      repo.setPromotionalMarketingConsent(consent: true),
      QoshniNotificationPreferenceUpdateResult.success,
    );
    expect(repo.preferences.promotionalMarketingConsent, isTrue);
    expect(
      repo.preferences.isCategoryEnabled(QoshniNotificationCategory.promotions),
      isTrue,
    );
  });

  test('restore defaults resets mutations', () {
    repo.setCategoryEnabled(
      category: QoshniNotificationCategory.orders,
      enabled: false,
    );
    repo.setPromotionalMarketingConsent(consent: true);
    expect(repo.restoreDemoDefaults(), QoshniNotificationPreferenceUpdateResult.success);
    expect(repo.preferences.isCategoryEnabled(QoshniNotificationCategory.orders), isTrue);
    expect(repo.preferences.promotionalMarketingConsent, isFalse);
  });

  test('failNextUpdate leaves preferences unchanged', () {
    repo.failNextUpdate = true;
    final snapshot = repo.preferences;
    expect(
      repo.setChannelEnabled(
        channel: QoshniNotificationChannel.inApp,
        enabled: false,
      ),
      QoshniNotificationPreferenceUpdateResult.failure,
    );
    expect(repo.preferences.isChannelEnabled(QoshniNotificationChannel.inApp),
        snapshot.isChannelEnabled(QoshniNotificationChannel.inApp));
  });

  test('quiet hours update applies enabled flag and times', () {
    expect(
      repo.setQuietHours(
        enabled: false,
        start: const QoshniLocalTime(hour: 21, minute: 0),
        end: const QoshniLocalTime(hour: 6, minute: 30),
      ),
      QoshniNotificationPreferenceUpdateResult.success,
    );
    expect(repo.preferences.quietHours.enabled, isFalse);
    expect(repo.preferences.quietHours.start.hour, 21);
  });
}

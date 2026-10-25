import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/features/notifications/data/in_memory_qoshni_notification_template_repository.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_category.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_channel.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_template_locale.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_template_status.dart';

void main() {
  test('seed is deterministic and duplicate-safe', () {
    final a = InMemoryQoshniNotificationTemplateRepository();
    final b = InMemoryQoshniNotificationTemplateRepository();
    expect(a.list().length, b.list().length);
    expect(a.list().first.templateId, b.list().first.templateId);
  });

  test('filters by category channel and status', () {
    final repo = InMemoryQoshniNotificationTemplateRepository();
    final promos = repo.list(
      category: QoshniNotificationCategory.promotions,
      status: QoshniNotificationTemplateStatus.active,
    );
    expect(promos.every((t) => t.category == QoshniNotificationCategory.promotions), isTrue);
    expect(
      promos.every((t) => t.status == QoshniNotificationTemplateStatus.active),
      isTrue,
    );

    final sms = repo.list(channel: QoshniNotificationChannel.smsPreview);
    expect(sms, isEmpty);
  });

  test('locale fallback resolves to english when uzbek missing', () {
    final repo = InMemoryQoshniNotificationTemplateRepository();
    final resolved = repo.resolveByKeyAndLocale(
      templateKey: 'demo.order.confirmation',
      requestedLocale: QoshniNotificationTemplateLocale.uz,
    );
    expect(resolved.template, isNotNull);
    expect(resolved.resolution.usedFallback, isFalse);
  });

  test('duplicate template key per locale rejected at seed validation', () {
    final repo = InMemoryQoshniNotificationTemplateRepository();
    final first = repo.getById('tpl-demo.order.confirmation-en');
    expect(first, isNotNull);
    expect(
      () => InMemoryQoshniNotificationTemplateRepository(
        seed: [first!, first],
      ),
      throwsStateError,
    );
  });
}

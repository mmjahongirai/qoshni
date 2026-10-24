import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/features/notifications/data/qoshni_notification_template_demo_seed.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_template_locale.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_template_locale_policy.dart';

void main() {
  test('falls back from missing locale to en ru uz order', () {
    final variants = buildQoshniNotificationTemplateDemoSeed()
        .where((t) => t.templateKey == 'demo.order.confirmation');
    final onlyEn = variants.where((t) => t.locale == QoshniNotificationTemplateLocale.en);
    final resolution = QoshniNotificationTemplateLocalePolicy.resolve(
      requestedLocale: QoshniNotificationTemplateLocale.ru,
      variantsForKey: onlyEn,
    );
    expect(resolution.resolvedLocale, QoshniNotificationTemplateLocale.en);
    expect(resolution.usedFallback, isTrue);
  });
}

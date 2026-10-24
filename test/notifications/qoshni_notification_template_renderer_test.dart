import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/features/notifications/data/qoshni_notification_template_demo_seed.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_template_locale.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_template_renderer.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_template_status.dart';

void main() {
  final seed = buildQoshniNotificationTemplateDemoSeed();
  final orderEn = seed.firstWhere(
    (t) => t.templateKey == 'demo.order.confirmation' &&
        t.locale == QoshniNotificationTemplateLocale.en,
  );

  test('interpolates required and optional variables', () {
    final result = QoshniNotificationTemplateRenderer.render(
      template: orderEn,
      variables: const {
        'orderReference': 'DEMO-1',
        'customerLabel': 'Guest',
        'etaWindow': '12:00',
      },
      clock: () => kQoshniNotificationTemplateDemoUpdatedAt,
    );
    expect(result.isSuccess, isTrue);
    expect(result.successOrNull!.title, contains('DEMO-1'));
    expect(result.successOrNull!.body, contains('Guest'));
  });

  test('rejects missing required variable', () {
    final result = QoshniNotificationTemplateRenderer.render(
      template: orderEn,
      variables: const {'customerLabel': 'Guest'},
      clock: () => kQoshniNotificationTemplateDemoUpdatedAt,
    );
    expect(result.isSuccess, isFalse);
    expect(result.failureOrNull!.errorCode, 'missing_required_variable');
    expect(result.failureOrNull!.missingVariables, contains('orderReference'));
  });

  test('rejects undeclared variable in map', () {
    final result = QoshniNotificationTemplateRenderer.render(
      template: orderEn,
      variables: const {
        'orderReference': 'DEMO-1',
        'extraField': 'x',
      },
      clock: () => kQoshniNotificationTemplateDemoUpdatedAt,
    );
    expect(result.failureOrNull!.errorCode, 'undeclared_variable');
  });

  test('rejects sensitive phone-like values', () {
    final result = QoshniNotificationTemplateRenderer.render(
      template: orderEn,
      variables: const {
        'orderReference': 'DEMO-1',
        'customerLabel': '+998901234567',
      },
      clock: () => kQoshniNotificationTemplateDemoUpdatedAt,
    );
    expect(result.failureOrNull!.errorCode, 'sensitive_phone_like');
  });

  test('blocks inactive archived template', () {
    final archived = seed.firstWhere(
      (t) => t.templateKey == 'demo.archived.promotion',
    );
    final result = QoshniNotificationTemplateRenderer.render(
      template: archived,
      variables: const {'offerTitle': 'Demo'},
      clock: () => kQoshniNotificationTemplateDemoUpdatedAt,
    );
    expect(result.failureOrNull!.errorCode, 'inactive_template');
  });

  test('draft template cannot render for preview', () {
    final draft = seed.firstWhere((t) => t.status == QoshniNotificationTemplateStatus.draft);
    final result = QoshniNotificationTemplateRenderer.render(
      template: draft,
      variables: const {},
      clock: () => kQoshniNotificationTemplateDemoUpdatedAt,
    );
    expect(result.failureOrNull!.errorCode, 'inactive_template');
  });
}

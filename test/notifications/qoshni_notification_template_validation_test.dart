import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/features/notifications/data/qoshni_notification_template_demo_seed.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_category.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_channel.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_priority.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_template_definition.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_template_locale.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_template_status.dart';
import 'package:qoshni/features/notifications/presentation/qoshni_notification_template_validation.dart';

void main() {
  test('seed templates pass definition validation', () {
    for (final template in buildQoshniNotificationTemplateDemoSeed()) {
      expect(
        qoshniNotificationTemplateDefinitionValidationError(template),
        isNull,
        reason: template.templateId,
      );
    }
  });

  test('detects incompatible channel and category', () {
    expect(
      qoshniNotificationTemplateChannelCategoryValidationError(
        QoshniNotificationCategory.promotions,
        QoshniNotificationChannel.emailPreview,
      ),
      'incompatible_channel_category',
    );
  });

  test('detects undeclared placeholder in template text', () {
    final bad = QoshniNotificationTemplateDefinition(
      templateId: 'bad-1',
      templateKey: 'demo.bad',
      category: QoshniNotificationCategory.orders,
      channel: QoshniNotificationChannel.inApp,
      status: QoshniNotificationTemplateStatus.active,
      locale: QoshniNotificationTemplateLocale.en,
      titleTemplate: 'Hello {{unknown}}',
      bodyTemplate: 'Body',
      variables: const [],
      priority: QoshniNotificationPriority.normal,
      version: 1,
      updatedAt: kQoshniNotificationTemplateDemoUpdatedAt,
    );
    expect(
      qoshniNotificationTemplateDefinitionValidationError(bad),
      'undeclared_placeholder',
    );
  });
}

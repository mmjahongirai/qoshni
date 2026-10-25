import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_template_locale.dart';
import 'package:qoshni/features/system_messages/data/qoshni_system_message_demo_seed.dart';
import 'package:qoshni/features/system_messages/domain/qoshni_system_message.dart';
import 'package:qoshni/features/system_messages/domain/qoshni_system_message_category.dart';
import 'package:qoshni/features/system_messages/domain/qoshni_system_message_lifecycle_status.dart';
import 'package:qoshni/features/system_messages/domain/qoshni_system_message_locale_content.dart';
import 'package:qoshni/features/system_messages/presentation/qoshni_system_message_validation.dart';

void main() {
  test('seed published messages have full locale content', () {
    for (final message in buildQoshniSystemMessageDemoSeed()) {
      if (message.lifecycleStatus ==
          QoshniSystemMessageLifecycleStatus.published) {
        expect(
          qoshniSystemMessageLocalizedContentValidationError(
            message.localizedContent,
          ),
          isNull,
        );
      }
    }
  });

  test('rejects missing locale content', () {
    final bad = QoshniSystemMessage(
      messageId: 'bad',
      messageKey: 'demo.bad',
      audienceScope: 'demo-platform-all',
      category: QoshniSystemMessageCategory.generalAnnouncement,
      lifecycleStatus: QoshniSystemMessageLifecycleStatus.draft,
      localizedContent: {
        QoshniNotificationTemplateLocale.en: const QoshniSystemMessageLocaleContent(
          title: 't',
          body: 'b',
        ),
      },
      createdAt: kDemoSystemMessageEpoch,
      updatedAt: kDemoSystemMessageEpoch,
    );
    expect(
      qoshniSystemMessageLocalizedContentValidationError(bad.localizedContent),
      'missing_locale_content',
    );
  });

  test('rejects invalid visible window', () {
    expect(
      qoshniSystemMessageWindowValidationError(
        visibleFrom: DateTime.utc(2025, 5, 1),
        visibleUntil: DateTime.utc(2025, 4, 1),
      ),
      'invalid_visible_window',
    );
  });
}

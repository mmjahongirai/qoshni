import 'package:qoshni/features/notifications/domain/qoshni_notification_template_locale.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_template_locale_resolution.dart';
import 'package:qoshni/features/system_messages/domain/qoshni_system_message.dart';
import 'package:qoshni/features/system_messages/domain/qoshni_system_message_resolved_content.dart';

abstract final class QoshniSystemMessageContentResolver {
  static QoshniSystemMessageResolvedContent? resolve({
    required QoshniSystemMessage message,
    required QoshniNotificationTemplateLocale requestedLocale,
  }) {
    final byLocale = message.localizedContent;
    final attempted = <QoshniNotificationTemplateLocale>[];
    final chain = <QoshniNotificationTemplateLocale>[
      requestedLocale,
      ...QoshniNotificationTemplateLocale.fallbackOrder
          .where((l) => l != requestedLocale),
    ];
    for (final locale in chain) {
      attempted.add(locale);
      final content = byLocale[locale];
      if (content != null) {
        return QoshniSystemMessageResolvedContent(
          title: content.title,
          body: content.body,
          resolution: QoshniNotificationTemplateLocaleResolution(
            requestedLocale: requestedLocale,
            resolvedLocale: locale,
            usedFallback: locale != requestedLocale,
            attemptedLocales: List.unmodifiable(attempted),
          ),
        );
      }
    }
    return null;
  }
}

import 'package:qoshni/features/notifications/domain/qoshni_notification_template_definition.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_template_locale.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_template_locale_resolution.dart';

/// Resolves a template variant for [templateKey] using explicit fallback order:
/// requested locale, then English, Russian, Uzbek (first match wins).
abstract final class QoshniNotificationTemplateLocalePolicy {
  static const List<QoshniNotificationTemplateLocale> fallbackOrder =
      QoshniNotificationTemplateLocale.fallbackOrder;

  static QoshniNotificationTemplateLocaleResolution resolve({
    required QoshniNotificationTemplateLocale requestedLocale,
    required Iterable<QoshniNotificationTemplateDefinition> variantsForKey,
  }) {
    final byLocale = {
      for (final t in variantsForKey) t.locale: t,
    };
    final attempted = <QoshniNotificationTemplateLocale>[];
    final chain = <QoshniNotificationTemplateLocale>[
      requestedLocale,
      ...fallbackOrder.where((l) => l != requestedLocale),
    ];
    for (final locale in chain) {
      attempted.add(locale);
      if (byLocale.containsKey(locale)) {
        return QoshniNotificationTemplateLocaleResolution(
          requestedLocale: requestedLocale,
          resolvedLocale: locale,
          usedFallback: locale != requestedLocale,
          attemptedLocales: List.unmodifiable(attempted),
        );
      }
    }
    return QoshniNotificationTemplateLocaleResolution(
      requestedLocale: requestedLocale,
      resolvedLocale: requestedLocale,
      usedFallback: false,
      attemptedLocales: List.unmodifiable(attempted),
    );
  }

  static QoshniNotificationTemplateDefinition? pickDefinition({
    required QoshniNotificationTemplateLocale requestedLocale,
    required Iterable<QoshniNotificationTemplateDefinition> variantsForKey,
  }) {
    final resolution = resolve(
      requestedLocale: requestedLocale,
      variantsForKey: variantsForKey,
    );
    for (final t in variantsForKey) {
      if (t.locale == resolution.resolvedLocale) {
        return t;
      }
    }
    return null;
  }
}

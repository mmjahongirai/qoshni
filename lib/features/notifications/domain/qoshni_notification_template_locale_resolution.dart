import 'package:qoshni/features/notifications/domain/qoshni_notification_template_locale.dart';

class QoshniNotificationTemplateLocaleResolution {
  const QoshniNotificationTemplateLocaleResolution({
    required this.requestedLocale,
    required this.resolvedLocale,
    required this.usedFallback,
    required this.attemptedLocales,
  });

  final QoshniNotificationTemplateLocale requestedLocale;
  final QoshniNotificationTemplateLocale resolvedLocale;
  final bool usedFallback;
  final List<QoshniNotificationTemplateLocale> attemptedLocales;
}

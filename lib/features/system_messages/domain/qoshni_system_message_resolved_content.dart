import 'package:qoshni/features/notifications/domain/qoshni_notification_template_locale.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_template_locale_resolution.dart';

class QoshniSystemMessageResolvedContent {
  const QoshniSystemMessageResolvedContent({
    required this.title,
    required this.body,
    required this.resolution,
  });

  final String title;
  final String body;
  final QoshniNotificationTemplateLocaleResolution resolution;
}

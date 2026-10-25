import 'package:qoshni/features/notifications/domain/qoshni_notification_template_definition.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_template_locale_resolution.dart';

class QoshniNotificationTemplateResolveResult {
  const QoshniNotificationTemplateResolveResult({
    required this.resolution,
    this.template,
  });

  final QoshniNotificationTemplateLocaleResolution resolution;
  final QoshniNotificationTemplateDefinition? template;
}

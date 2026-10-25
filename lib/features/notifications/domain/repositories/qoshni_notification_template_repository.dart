import 'package:qoshni/features/notifications/domain/qoshni_notification_category.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_channel.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_template_definition.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_template_locale.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_template_resolve_result.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_template_status.dart';

abstract class QoshniNotificationTemplateRepository {
  List<QoshniNotificationTemplateDefinition> list({
    QoshniNotificationCategory? category,
    QoshniNotificationChannel? channel,
    QoshniNotificationTemplateStatus? status,
    QoshniNotificationTemplateLocale? locale,
    String? templateKeyQuery,
  });

  QoshniNotificationTemplateDefinition? getById(String templateId);

  List<QoshniNotificationTemplateDefinition> variantsForKey(String templateKey);

  QoshniNotificationTemplateResolveResult resolveByKeyAndLocale({
    required String templateKey,
    required QoshniNotificationTemplateLocale requestedLocale,
  });
}

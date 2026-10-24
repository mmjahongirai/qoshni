import 'package:qoshni/features/notifications/domain/qoshni_notification_category.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_channel.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_priority.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_provenance.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_template_locale.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_template_status.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_template_variable_definition.dart';

class QoshniNotificationTemplateDefinition {
  const QoshniNotificationTemplateDefinition({
    required this.templateId,
    required this.templateKey,
    required this.category,
    required this.channel,
    required this.status,
    required this.locale,
    required this.titleTemplate,
    required this.bodyTemplate,
    required this.variables,
    required this.priority,
    required this.version,
    required this.updatedAt,
    this.internalNavigationRoute,
  });

  final String templateId;
  final String templateKey;
  final QoshniNotificationCategory category;
  final QoshniNotificationChannel channel;
  final QoshniNotificationTemplateStatus status;
  final QoshniNotificationTemplateLocale locale;
  final String titleTemplate;
  final String bodyTemplate;
  final List<QoshniNotificationTemplateVariableDefinition> variables;
  final QoshniNotificationPriority priority;
  final int version;
  final DateTime updatedAt;
  final String? internalNavigationRoute;

  QoshniNotificationProvenance get provenance =>
      QoshniNotificationProvenance.syntheticDemo;
}

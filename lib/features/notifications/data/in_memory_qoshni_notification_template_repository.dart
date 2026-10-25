import 'package:qoshni/features/notifications/data/qoshni_notification_template_demo_seed.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_category.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_channel.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_template_definition.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_template_locale.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_template_locale_policy.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_template_resolve_result.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_template_status.dart';
import 'package:qoshni/features/notifications/domain/repositories/qoshni_notification_template_repository.dart';
import 'package:qoshni/features/notifications/presentation/qoshni_notification_template_validation.dart';

class InMemoryQoshniNotificationTemplateRepository
    implements QoshniNotificationTemplateRepository {
  InMemoryQoshniNotificationTemplateRepository({
    List<QoshniNotificationTemplateDefinition>? seed,
  }) : _templates = _validateSeed(seed ?? buildQoshniNotificationTemplateDemoSeed());

  final List<QoshniNotificationTemplateDefinition> _templates;

  static List<QoshniNotificationTemplateDefinition> _validateSeed(
    List<QoshniNotificationTemplateDefinition> seed,
  ) {
    final seenIds = <String>{};
    final seenKeyLocale = <String>{};
    for (final template in seed) {
      if (!seenIds.add(template.templateId)) {
        throw StateError('duplicate template id: ${template.templateId}');
      }
      final validation =
          qoshniNotificationTemplateDefinitionValidationError(template);
      if (validation != null) {
        throw StateError(
          'invalid seed template ${template.templateId}: $validation',
        );
      }
      final scope = '${template.templateKey}::${template.locale.name}';
      if (!seenKeyLocale.add(scope)) {
        throw StateError('duplicate template key/locale: $scope');
      }
    }
    return List.unmodifiable(seed);
  }

  @override
  List<QoshniNotificationTemplateDefinition> list({
    QoshniNotificationCategory? category,
    QoshniNotificationChannel? channel,
    QoshniNotificationTemplateStatus? status,
    QoshniNotificationTemplateLocale? locale,
    String? templateKeyQuery,
  }) {
    var result = List<QoshniNotificationTemplateDefinition>.from(_templates);
    if (category != null) {
      result = result.where((t) => t.category == category).toList(growable: true);
    }
    if (channel != null) {
      result = result.where((t) => t.channel == channel).toList(growable: true);
    }
    if (status != null) {
      result = result.where((t) => t.status == status).toList(growable: true);
    }
    if (locale != null) {
      result = result.where((t) => t.locale == locale).toList(growable: true);
    }
    final query = templateKeyQuery?.trim().toLowerCase();
    if (query != null && query.isNotEmpty) {
      result = result
          .where((t) => t.templateKey.toLowerCase().contains(query))
          .toList(growable: true);
    }
    result.sort((a, b) {
      final key = a.templateKey.compareTo(b.templateKey);
      if (key != 0) {
        return key;
      }
      return a.locale.name.compareTo(b.locale.name);
    });
    return List.unmodifiable(result);
  }

  @override
  QoshniNotificationTemplateDefinition? getById(String templateId) {
    final id = templateId.trim();
    for (final template in _templates) {
      if (template.templateId == id) {
        return template;
      }
    }
    return null;
  }

  @override
  List<QoshniNotificationTemplateDefinition> variantsForKey(String templateKey) {
    final key = templateKey.trim();
    return list().where((t) => t.templateKey == key).toList(growable: false);
  }

  @override
  QoshniNotificationTemplateResolveResult resolveByKeyAndLocale({
    required String templateKey,
    required QoshniNotificationTemplateLocale requestedLocale,
  }) {
    final variants = variantsForKey(templateKey);
    final resolution = QoshniNotificationTemplateLocalePolicy.resolve(
      requestedLocale: requestedLocale,
      variantsForKey: variants,
    );
    final template = QoshniNotificationTemplateLocalePolicy.pickDefinition(
      requestedLocale: requestedLocale,
      variantsForKey: variants,
    );
    return QoshniNotificationTemplateResolveResult(
      resolution: resolution,
      template: template,
    );
  }
}

import 'package:qoshni/features/notifications/domain/qoshni_notification_template_definition.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_template_render_result.dart';
import 'package:qoshni/features/notifications/presentation/qoshni_notification_template_validation.dart';

typedef QoshniNotificationTemplateRenderClock = DateTime Function();

abstract final class QoshniNotificationTemplateRenderer {
  static QoshniNotificationTemplateRenderResult render({
    required QoshniNotificationTemplateDefinition template,
    required Map<String, String> variables,
    QoshniNotificationTemplateRenderClock? clock,
  }) {
    final inactive =
        qoshniNotificationTemplateActivePreviewValidationError(template);
    if (inactive != null) {
      return QoshniNotificationTemplateRenderErr(
        QoshniNotificationTemplateRenderFailure(errorCode: inactive),
      );
    }

    final definitionError =
        qoshniNotificationTemplateDefinitionValidationError(template);
    if (definitionError != null) {
      return QoshniNotificationTemplateRenderErr(
        QoshniNotificationTemplateRenderFailure(errorCode: definitionError),
      );
    }

    final normalized = <String, String>{};
    for (final entry in variables.entries) {
      final key = entry.key.trim();
      if (key.isEmpty) {
        return QoshniNotificationTemplateRenderErr(
          const QoshniNotificationTemplateRenderFailure(
            errorCode: 'invalid_variable_key',
          ),
        );
      }
      final valueError =
          qoshniNotificationTemplateVariableValueValidationError(entry.value);
      if (valueError != null) {
        return QoshniNotificationTemplateRenderErr(
          QoshniNotificationTemplateRenderFailure(
            errorCode: valueError,
            detail: key,
          ),
        );
      }
      normalized[key] = entry.value;
    }

    final declared = {
      for (final v in template.variables) v.key: v.required,
    };

    for (final key in normalized.keys) {
      if (!declared.containsKey(key)) {
        return QoshniNotificationTemplateRenderErr(
          QoshniNotificationTemplateRenderFailure(
            errorCode: 'undeclared_variable',
            undeclaredPlaceholders: [key],
          ),
        );
      }
    }

    final missing = <String>[];
    for (final entry in declared.entries) {
      if (!entry.value) {
        continue;
      }
      final value = normalized[entry.key];
      if (value == null || value.trim().isEmpty) {
        missing.add(entry.key);
      }
    }
    if (missing.isNotEmpty) {
      return QoshniNotificationTemplateRenderErr(
        QoshniNotificationTemplateRenderFailure(
          errorCode: 'missing_required_variable',
          missingVariables: missing,
        ),
      );
    }

    String interpolate(String source) {
      return source.replaceAllMapped(
        kQoshniNotificationTemplatePlaceholderPattern,
        (match) {
          final name = match.group(1)!;
          final required = declared[name] ?? false;
          final value = normalized[name];
          if (value == null || value.isEmpty) {
            return required ? match.group(0)! : '';
          }
          return value;
        },
      );
    }

    final title = interpolate(template.titleTemplate).trim();
    final body = interpolate(template.bodyTemplate).trim();

    final renderedValidation = qoshniNotificationRenderedMessageValidationError(
      title: title,
      body: body,
    );
    if (renderedValidation != null) {
      return QoshniNotificationTemplateRenderErr(
        QoshniNotificationTemplateRenderFailure(errorCode: renderedValidation),
      );
    }

    final now = (clock ?? DateTime.now)().toUtc();
    return QoshniNotificationTemplateRenderOk(
      QoshniNotificationTemplateRenderSuccess(
        title: title,
        body: body,
        renderedAt: now,
      ),
    );
  }
}

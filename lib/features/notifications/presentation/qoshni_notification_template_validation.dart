import 'package:qoshni/features/notifications/domain/qoshni_notification_category.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_channel.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_template_definition.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_template_status.dart';
import 'package:qoshni/features/notifications/presentation/qoshni_notification_validation.dart';

const int kQoshniNotificationTemplateKeyMaxLength = 120;
const int kQoshniNotificationTemplateIdMaxLength = 160;
const int kQoshniNotificationTemplateStringMaxLength = 600;

final RegExp kQoshniNotificationTemplatePlaceholderPattern =
    RegExp(r'\{\{([a-zA-Z][a-zA-Z0-9_]*)\}\}');

String? qoshniNotificationTemplateDefinitionValidationError(
  QoshniNotificationTemplateDefinition template,
) {
  final id = template.templateId.trim();
  if (id.isEmpty || id.length > kQoshniNotificationTemplateIdMaxLength) {
    return 'invalid_template_id';
  }

  final key = template.templateKey.trim();
  if (key.isEmpty || key.length > kQoshniNotificationTemplateKeyMaxLength) {
    return 'invalid_template_key';
  }
  if (!RegExp(r'^[a-z][a-z0-9.]*$').hasMatch(key)) {
    return 'invalid_template_key';
  }

  if (template.titleTemplate.trim().isEmpty ||
      template.titleTemplate.length > kQoshniNotificationTemplateStringMaxLength) {
    return 'invalid_title_template';
  }
  if (template.bodyTemplate.trim().isEmpty ||
      template.bodyTemplate.length > kQoshniNotificationTemplateStringMaxLength) {
    return 'invalid_body_template';
  }

  final channelCategory =
      qoshniNotificationTemplateChannelCategoryValidationError(
    template.category,
    template.channel,
  );
  if (channelCategory != null) {
    return channelCategory;
  }

  final declared = <String>{};
  for (final variable in template.variables) {
    final vKey = variable.key.trim();
    if (vKey.isEmpty || !RegExp(r'^[a-zA-Z][a-zA-Z0-9_]*$').hasMatch(vKey)) {
      return 'invalid_variable_key';
    }
    if (!declared.add(vKey)) {
      return 'duplicate_variable_key';
    }
  }

  for (final field in [template.titleTemplate, template.bodyTemplate]) {
    final malformed = qoshniNotificationTemplateMalformedPlaceholderError(field);
    if (malformed != null) {
      return malformed;
    }
    for (final match
        in kQoshniNotificationTemplatePlaceholderPattern.allMatches(field)) {
      final name = match.group(1)!;
      if (!declared.contains(name)) {
        return 'undeclared_placeholder';
      }
    }
  }

  return null;
}

String? qoshniNotificationTemplateMalformedPlaceholderError(String field) {
  var index = 0;
  while (index < field.length) {
    final open = field.indexOf('{{', index);
    if (open == -1) {
      break;
    }
    final close = field.indexOf('}}', open + 2);
    if (close == -1) {
      return 'malformed_placeholder';
    }
    final inner = field.substring(open + 2, close);
    if (inner.isEmpty ||
        !RegExp(r'^[a-zA-Z][a-zA-Z0-9_]*$').hasMatch(inner)) {
      return 'malformed_placeholder';
    }
    index = close + 2;
  }
  if (field.contains('}}') && !kQoshniNotificationTemplatePlaceholderPattern.hasMatch(field)) {
    return 'malformed_placeholder';
  }
  if (field.contains('{{') &&
      !kQoshniNotificationTemplatePlaceholderPattern.hasMatch(field)) {
    return 'malformed_placeholder';
  }
  return null;
}

String? qoshniNotificationTemplateChannelCategoryValidationError(
  QoshniNotificationCategory category,
  QoshniNotificationChannel channel,
) {
  switch (channel) {
    case QoshniNotificationChannel.inApp:
    case QoshniNotificationChannel.pushPreview:
      return null;
    case QoshniNotificationChannel.smsPreview:
      if (category == QoshniNotificationCategory.promotions ||
          category == QoshniNotificationCategory.business) {
        return 'incompatible_channel_category';
      }
      return null;
    case QoshniNotificationChannel.emailPreview:
      if (category == QoshniNotificationCategory.promotions) {
        return 'incompatible_channel_category';
      }
      return null;
  }
}

String? qoshniNotificationTemplateActivePreviewValidationError(
  QoshniNotificationTemplateDefinition template,
) {
  final base = qoshniNotificationTemplateDefinitionValidationError(template);
  if (base != null) {
    return base;
  }
  if (template.status != QoshniNotificationTemplateStatus.active) {
    return 'inactive_template';
  }
  return null;
}

String? qoshniNotificationTemplateVariableValueValidationError(String value) {
  if (value.length > kQoshniNotificationBodyMaxLength) {
    return 'variable_too_long';
  }
  if (value.contains('{{') || value.contains('}}')) {
    return 'variable_contains_placeholder_syntax';
  }
  final lower = value.toLowerCase();
  if (lower.contains('@') && lower.contains('.')) {
    return 'sensitive_email_like';
  }
  final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
  if (value.trim().startsWith('+') && digitsOnly.length >= 9) {
    return 'sensitive_phone_like';
  }
  if (digitsOnly.length >= 11) {
    return 'sensitive_phone_like';
  }
  if (lower.contains('password') ||
      lower.contains('secret') ||
      lower.contains('iban') ||
      lower.contains('credit card')) {
    return 'sensitive_content';
  }
  if (lower.startsWith('http://') || lower.startsWith('https://')) {
    return 'unsafe_url';
  }
  return null;
}

String? qoshniNotificationRenderedMessageValidationError({
  required String title,
  required String body,
}) {
  if (title.trim().isEmpty || title.length > kQoshniNotificationTitleMaxLength) {
    return 'invalid_rendered_title';
  }
  if (body.trim().isEmpty || body.length > kQoshniNotificationBodyMaxLength) {
    return 'invalid_rendered_body';
  }
  if (kQoshniNotificationTemplatePlaceholderPattern.hasMatch(title) ||
      kQoshniNotificationTemplatePlaceholderPattern.hasMatch(body)) {
    return 'unresolved_placeholder';
  }
  return null;
}

import 'package:qoshni/features/notifications/domain/qoshni_notification_template_locale.dart';
import 'package:qoshni/features/notifications/presentation/qoshni_notification_internal_navigation.dart';
import 'package:qoshni/features/system_messages/domain/qoshni_system_message.dart';
import 'package:qoshni/features/system_messages/domain/qoshni_system_message_lifecycle_status.dart';
import 'package:qoshni/features/system_messages/domain/qoshni_system_message_locale_content.dart';

const int kQoshniSystemMessageKeyMaxLength = 120;
const int kQoshniSystemMessageIdMaxLength = 160;
const int kQoshniSystemMessageTitleMaxLength = 120;
const int kQoshniSystemMessageBodyMaxLength = 800;
const int kQoshniSystemMessageRecipientMaxLength = 80;
const String kQoshniSystemMessageDemoAudienceScope = 'demo-platform-all';

String? qoshniSystemMessageKeyValidationError(String messageKey) {
  final key = messageKey.trim();
  if (key.isEmpty || key.length > kQoshniSystemMessageKeyMaxLength) {
    return 'invalid_message_key';
  }
  if (!RegExp(r'^[a-z][a-z0-9.]*$').hasMatch(key)) {
    return 'invalid_message_key';
  }
  return null;
}

String? qoshniSystemMessageLocalizedContentValidationError(
  Map<QoshniNotificationTemplateLocale, QoshniSystemMessageLocaleContent>
      localizedContent,
) {
  for (final locale in QoshniNotificationTemplateLocale.values) {
    final entry = localizedContent[locale];
    if (entry == null) {
      return 'missing_locale_content';
    }
    final title = entry.title.trim();
    final body = entry.body.trim();
    if (title.isEmpty || title.length > kQoshniSystemMessageTitleMaxLength) {
      return 'invalid_title';
    }
    if (body.isEmpty || body.length > kQoshniSystemMessageBodyMaxLength) {
      return 'invalid_body';
    }
    if (!_isSafeSystemMessageText(title) || !_isSafeSystemMessageText(body)) {
      return 'unsafe_content';
    }
  }
  return null;
}

String? qoshniSystemMessagePublishValidationError(QoshniSystemMessage message) {
  if (message.lifecycleStatus != QoshniSystemMessageLifecycleStatus.draft) {
    return 'not_draft';
  }
  final keyError = qoshniSystemMessageKeyValidationError(message.messageKey);
  if (keyError != null) {
    return keyError;
  }
  final contentError =
      qoshniSystemMessageLocalizedContentValidationError(message.localizedContent);
  if (contentError != null) {
    return contentError;
  }
  return qoshniSystemMessageWindowValidationError(
    visibleFrom: message.visibleFrom,
    visibleUntil: message.visibleUntil,
    publishedAt: message.publishedAt,
  );
}

String? qoshniSystemMessageWindowValidationError({
  DateTime? visibleFrom,
  DateTime? visibleUntil,
  DateTime? publishedAt,
}) {
  if (visibleFrom != null && visibleUntil != null) {
    if (!visibleUntil.isAfter(visibleFrom)) {
      return 'invalid_visible_window';
    }
  }
  if (publishedAt != null && visibleUntil != null) {
    if (!visibleUntil.isAfter(publishedAt)) {
      return 'invalid_visible_window';
    }
  }
  return null;
}

String? qoshniSystemMessageNavigationRouteValidationError(String? route) {
  final normalized = route?.trim();
  if (normalized == null || normalized.isEmpty) {
    return null;
  }
  if (!isAllowedQoshniNotificationInternalRoute(normalized)) {
    return 'invalid_navigation_route';
  }
  return null;
}

String? qoshniSystemMessageRecipientValidationError(String recipient) {
  final ref = recipient.trim();
  if (ref.isEmpty || ref.length > kQoshniSystemMessageRecipientMaxLength) {
    return 'invalid_recipient';
  }
  if (ref.contains('@') || ref.contains('+998')) {
    return 'unsafe_recipient';
  }
  final lower = ref.toLowerCase();
  if (lower.startsWith('http://') || lower.startsWith('https://')) {
    return 'unsafe_recipient';
  }
  return null;
}

bool _isSafeSystemMessageText(String value) {
  final lower = value.toLowerCase();
  if (lower.contains('@') && lower.contains('.')) {
    return false;
  }
  if (lower.startsWith('http://') || lower.startsWith('https://')) {
    return false;
  }
  if (lower.contains('password') ||
      lower.contains('credit card') ||
      lower.contains('iban')) {
    return false;
  }
  return true;
}

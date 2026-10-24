import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_template_locale.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_template_status.dart';

String qoshniNotificationTemplateStatusLabel(
  AppLocalizations l10n,
  QoshniNotificationTemplateStatus status,
) {
  return switch (status) {
    QoshniNotificationTemplateStatus.draft =>
      l10n.notificationTemplateStatusDraft,
    QoshniNotificationTemplateStatus.active =>
      l10n.notificationTemplateStatusActive,
    QoshniNotificationTemplateStatus.archived =>
      l10n.notificationTemplateStatusArchived,
  };
}

String qoshniNotificationTemplateLocaleLabel(
  AppLocalizations l10n,
  QoshniNotificationTemplateLocale locale,
) {
  return switch (locale) {
    QoshniNotificationTemplateLocale.en =>
      l10n.notificationTemplateLocaleEnglish,
    QoshniNotificationTemplateLocale.ru =>
      l10n.notificationTemplateLocaleRussian,
    QoshniNotificationTemplateLocale.uz =>
      l10n.notificationTemplateLocaleUzbek,
  };
}

String qoshniNotificationTemplateRenderErrorLabel(
  AppLocalizations l10n,
  String errorCode, {
  List<String> missingVariables = const [],
  List<String> undeclaredPlaceholders = const [],
}) {
  return switch (errorCode) {
    'inactive_template' => l10n.notificationTemplateErrorInactive,
    'missing_required_variable' =>
      l10n.notificationTemplateErrorMissingVariables(
        missingVariables.join(', '),
      ),
    'undeclared_variable' ||
    'undeclared_placeholder' =>
      l10n.notificationTemplateErrorUndeclaredPlaceholder,
    'malformed_placeholder' =>
      l10n.notificationTemplateErrorMalformedPlaceholder,
    'sensitive_email_like' ||
    'sensitive_phone_like' ||
    'sensitive_content' =>
      l10n.notificationTemplateErrorSensitiveValue,
    'unresolved_placeholder' =>
      l10n.notificationTemplateErrorUnresolvedPlaceholder,
    'incompatible_channel_category' =>
      l10n.notificationTemplateErrorIncompatibleChannel,
    _ => l10n.notificationTemplateErrorGeneric,
  };
}

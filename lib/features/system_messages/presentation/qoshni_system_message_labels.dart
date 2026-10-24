import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_template_locale.dart';
import 'package:qoshni/features/system_messages/domain/qoshni_system_message_category.dart';
import 'package:qoshni/features/system_messages/domain/qoshni_system_message_lifecycle_status.dart';

String qoshniSystemMessageCategoryLabel(
  AppLocalizations l10n,
  QoshniSystemMessageCategory category,
) {
  return switch (category) {
    QoshniSystemMessageCategory.generalAnnouncement =>
      l10n.systemMessageCategoryGeneral,
    QoshniSystemMessageCategory.maintenanceNotice =>
      l10n.systemMessageCategoryMaintenance,
    QoshniSystemMessageCategory.serviceUpdate =>
      l10n.systemMessageCategoryServiceUpdate,
    QoshniSystemMessageCategory.policyInformation =>
      l10n.systemMessageCategoryPolicy,
  };
}

String qoshniSystemMessageLifecycleLabel(
  AppLocalizations l10n,
  QoshniSystemMessageLifecycleStatus status,
) {
  return switch (status) {
    QoshniSystemMessageLifecycleStatus.draft => l10n.systemMessageLifecycleDraft,
    QoshniSystemMessageLifecycleStatus.published =>
      l10n.systemMessageLifecyclePublished,
    QoshniSystemMessageLifecycleStatus.withdrawn =>
      l10n.systemMessageLifecycleWithdrawn,
    QoshniSystemMessageLifecycleStatus.archived =>
      l10n.systemMessageLifecycleArchived,
  };
}

String qoshniSystemMessageLocaleLabel(
  AppLocalizations l10n,
  QoshniNotificationTemplateLocale locale,
) {
  return switch (locale) {
    QoshniNotificationTemplateLocale.en => l10n.notificationTemplateLocaleEnglish,
    QoshniNotificationTemplateLocale.ru => l10n.notificationTemplateLocaleRussian,
    QoshniNotificationTemplateLocale.uz => l10n.notificationTemplateLocaleUzbek,
  };
}

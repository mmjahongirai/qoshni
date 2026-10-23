import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_category.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_channel.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_priority.dart';

String qoshniNotificationCategoryLabel(
  AppLocalizations l10n,
  QoshniNotificationCategory category,
) {
  return switch (category) {
    QoshniNotificationCategory.orders => l10n.notificationCategoryOrders,
    QoshniNotificationCategory.bookings => l10n.notificationCategoryBookings,
    QoshniNotificationCategory.delivery => l10n.notificationCategoryDelivery,
    QoshniNotificationCategory.walletPayments =>
      l10n.notificationCategoryWalletPayments,
    QoshniNotificationCategory.aiAlerts => l10n.notificationCategoryAiAlerts,
    QoshniNotificationCategory.location => l10n.notificationCategoryLocation,
    QoshniNotificationCategory.business => l10n.notificationCategoryBusiness,
    QoshniNotificationCategory.trustReviews =>
      l10n.notificationCategoryTrustReviews,
    QoshniNotificationCategory.security => l10n.notificationCategorySecurity,
    QoshniNotificationCategory.promotions =>
      l10n.notificationCategoryPromotions,
  };
}

String qoshniNotificationChannelLabel(
  AppLocalizations l10n,
  QoshniNotificationChannel channel,
) {
  return switch (channel) {
    QoshniNotificationChannel.inApp => l10n.notificationChannelInApp,
    QoshniNotificationChannel.pushPreview =>
      l10n.notificationChannelPushPreview,
    QoshniNotificationChannel.smsPreview => l10n.notificationChannelSmsPreview,
    QoshniNotificationChannel.emailPreview =>
      l10n.notificationChannelEmailPreview,
  };
}

String qoshniNotificationPriorityLabel(
  AppLocalizations l10n,
  QoshniNotificationPriority priority,
) {
  return switch (priority) {
    QoshniNotificationPriority.low => l10n.notificationPriorityLow,
    QoshniNotificationPriority.normal => l10n.notificationPriorityNormal,
    QoshniNotificationPriority.high => l10n.notificationPriorityHigh,
    QoshniNotificationPriority.urgent => l10n.notificationPriorityUrgent,
  };
}

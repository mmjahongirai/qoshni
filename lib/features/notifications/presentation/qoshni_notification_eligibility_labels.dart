import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_delivery_eligibility.dart';

String qoshniNotificationEligibilityReasonLabel(
  AppLocalizations l10n,
  QoshniNotificationEligibilityReason reason,
) {
  return switch (reason) {
    QoshniNotificationEligibilityReason.eligible =>
      l10n.notificationEligibilityReasonEligible,
    QoshniNotificationEligibilityReason.suppressedCategoryDisabled =>
      l10n.notificationEligibilityReasonCategoryDisabled,
    QoshniNotificationEligibilityReason.suppressedChannelDisabled =>
      l10n.notificationEligibilityReasonChannelDisabled,
    QoshniNotificationEligibilityReason.suppressedPromotionalConsentDisabled =>
      l10n.notificationEligibilityReasonPromoConsentDisabled,
    QoshniNotificationEligibilityReason.suppressedQuietHours =>
      l10n.notificationEligibilityReasonQuietHours,
    QoshniNotificationEligibilityReason.suppressedInvalidInput =>
      l10n.notificationEligibilityReasonInvalid,
  };
}

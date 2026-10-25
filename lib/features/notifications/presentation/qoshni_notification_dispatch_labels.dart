import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_dispatch_outcome.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_dispatch_source.dart';

String qoshniNotificationDispatchOutcomeLabel(
  AppLocalizations l10n,
  QoshniNotificationDispatchOutcome outcome,
) {
  return switch (outcome) {
    QoshniNotificationDispatchOutcome.deliveredToInbox =>
      l10n.notificationDispatchOutcomeDeliveredInbox,
    QoshniNotificationDispatchOutcome.simulatedChannelDelivered =>
      l10n.notificationDispatchOutcomeSimulatedChannel,
    QoshniNotificationDispatchOutcome.suppressedByPolicy =>
      l10n.notificationDispatchOutcomeSuppressed,
    QoshniNotificationDispatchOutcome.duplicateIdempotencyReference =>
      l10n.notificationDispatchOutcomeDuplicate,
    QoshniNotificationDispatchOutcome.validationFailed =>
      l10n.notificationDispatchOutcomeValidationFailed,
    QoshniNotificationDispatchOutcome.simulatedChannelFailure =>
      l10n.notificationDispatchOutcomeChannelFailure,
    QoshniNotificationDispatchOutcome.inboxPersistFailure =>
      l10n.notificationDispatchOutcomeInboxFailure,
    QoshniNotificationDispatchOutcome.coordinatorFailure =>
      l10n.notificationDispatchOutcomeCoordinatorFailure,
  };
}

String qoshniNotificationDispatchSourceLabel(
  AppLocalizations l10n,
  QoshniNotificationDispatchSource source,
) {
  return switch (source) {
    QoshniNotificationDispatchSource.demoDiagnostics =>
      l10n.notificationDispatchSourceDiagnostics,
    QoshniNotificationDispatchSource.demoScenarioOrderUpdate =>
      l10n.notificationDispatchSourceOrderScenario,
    QoshniNotificationDispatchSource.demoScenarioPromotion =>
      l10n.notificationDispatchSourcePromotionScenario,
    QoshniNotificationDispatchSource.demoScenarioSecurityAlert =>
      l10n.notificationDispatchSourceSecurityScenario,
    QoshniNotificationDispatchSource.demoTemplatePreview =>
      l10n.notificationDispatchSourceTemplatePreview,
  };
}

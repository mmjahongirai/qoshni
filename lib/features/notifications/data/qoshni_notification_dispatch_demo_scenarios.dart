import 'package:qoshni/features/notifications/data/qoshni_notification_demo_seed.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_category.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_channel.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_dispatch_request.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_dispatch_source.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_priority.dart';
import 'package:qoshni/routing/route_paths.dart';

enum QoshniNotificationDispatchDemoScenario {
  orderInAppMidday,
  orderInAppQuietHours,
  promotionPushPreview,
  securityInAppQuietHours,
}

QoshniNotificationDispatchRequest buildDemoDispatchRequest({
  required QoshniNotificationDispatchDemoScenario scenario,
  required String idempotencySuffix,
}) {
  final recipient = kDemoNotificationRecipientReference;
  final idempotency = 'dispatch-idem-${scenario.name}-$idempotencySuffix';
  final correlation = 'dispatch-corr-${scenario.name}-$idempotencySuffix';

  switch (scenario) {
    case QoshniNotificationDispatchDemoScenario.orderInAppMidday:
      return QoshniNotificationDispatchRequest(
        demoRecipientReference: recipient,
        category: QoshniNotificationCategory.orders,
        channel: QoshniNotificationChannel.inApp,
        priority: QoshniNotificationPriority.normal,
        title: 'Demo dispatch: order update',
        body: 'Synthetic order status dispatch for simulation.',
        idempotencyReference: idempotency,
        correlationReference: correlation,
        source: QoshniNotificationDispatchSource.demoScenarioOrderUpdate,
        evaluationLocalDateTime: DateTime(2025, 4, 10, 12, 0),
        internalNavigationRoute: RoutePaths.demoOrders,
      );
    case QoshniNotificationDispatchDemoScenario.orderInAppQuietHours:
      return QoshniNotificationDispatchRequest(
        demoRecipientReference: recipient,
        category: QoshniNotificationCategory.orders,
        channel: QoshniNotificationChannel.inApp,
        priority: QoshniNotificationPriority.normal,
        title: 'Demo dispatch: quiet-hours order',
        body: 'Expected policy suppression during quiet hours.',
        idempotencyReference: idempotency,
        correlationReference: correlation,
        source: QoshniNotificationDispatchSource.demoScenarioOrderUpdate,
        evaluationLocalDateTime: DateTime(2025, 4, 10, 23, 30),
      );
    case QoshniNotificationDispatchDemoScenario.promotionPushPreview:
      return QoshniNotificationDispatchRequest(
        demoRecipientReference: recipient,
        category: QoshniNotificationCategory.promotions,
        channel: QoshniNotificationChannel.inApp,
        priority: QoshniNotificationPriority.low,
        title: 'Demo dispatch: promotion preview',
        body: 'Requires promotional consent; suppressed when consent is off.',
        idempotencyReference: idempotency,
        correlationReference: correlation,
        source: QoshniNotificationDispatchSource.demoScenarioPromotion,
        evaluationLocalDateTime: DateTime(2025, 4, 10, 12, 0),
      );
    case QoshniNotificationDispatchDemoScenario.securityInAppQuietHours:
      return QoshniNotificationDispatchRequest(
        demoRecipientReference: recipient,
        category: QoshniNotificationCategory.security,
        channel: QoshniNotificationChannel.inApp,
        priority: QoshniNotificationPriority.urgent,
        title: 'Demo dispatch: security alert',
        body: 'Bypasses quiet hours; should deliver to inbox when eligible.',
        idempotencyReference: idempotency,
        correlationReference: correlation,
        source: QoshniNotificationDispatchSource.demoScenarioSecurityAlert,
        evaluationLocalDateTime: DateTime(2025, 4, 10, 23, 30),
        internalNavigationRoute: RoutePaths.profile,
      );
  }
}

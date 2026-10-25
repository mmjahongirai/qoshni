import 'package:qoshni/features/notifications/domain/qoshni_notification.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_dispatch_request.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_provenance.dart';
import 'package:qoshni/features/notifications/presentation/qoshni_notification_validation.dart';

const int kQoshniNotificationIdempotencyMaxLength = 200;
const int kQoshniNotificationCorrelationMaxLength = 200;

String? qoshniNotificationDispatchRequestValidationError(
  QoshniNotificationDispatchRequest request,
) {
  final deliverProbe = QoshniNotificationDeliverInput(
    demoRecipientReference: request.demoRecipientReference,
    category: request.category,
    channel: request.channel,
    title: request.title,
    body: request.body,
    createdAt: request.evaluationLocalDateTime.toUtc(),
    priority: request.priority,
    internalNavigationRoute: request.internalNavigationRoute,
    provenance: QoshniNotificationProvenance.syntheticDemo,
    deduplicationReference: request.idempotencyReference,
  );
  if (qoshniNotificationDeliverValidationError(deliverProbe) != null) {
    return 'invalid_payload';
  }

  final idem = request.idempotencyReference.trim();
  if (idem.isEmpty || idem.length > kQoshniNotificationIdempotencyMaxLength) {
    return 'invalid_idempotency';
  }

  final corr = request.correlationReference.trim();
  if (corr.isEmpty || corr.length > kQoshniNotificationCorrelationMaxLength) {
    return 'invalid_correlation';
  }

  return null;
}

import 'package:qoshni/features/business_platform/domain/business_delivery_exception_status.dart';

enum BusinessDeliveryExceptionHistoryAction {
  created,
  statusChanged,
  reopened,
}

class BusinessDeliveryExceptionHistoryEvent {
  const BusinessDeliveryExceptionHistoryEvent({
    required this.eventId,
    required this.exceptionId,
    required this.deliveryTaskId,
    required this.action,
    this.previousStatus,
    required this.newStatus,
    required this.recordedAt,
    this.reason,
  });

  final String eventId;
  final String exceptionId;
  final String deliveryTaskId;
  final BusinessDeliveryExceptionHistoryAction action;
  final BusinessDeliveryExceptionStatus? previousStatus;
  final BusinessDeliveryExceptionStatus newStatus;
  final DateTime recordedAt;
  final String? reason;
}

import 'package:qoshni/features/business_platform/domain/business_delivery_task_status.dart';

enum BusinessDeliveryTaskHistoryAction {
  created,
  statusChanged,
}

class BusinessDeliveryTaskHistoryEvent {
  const BusinessDeliveryTaskHistoryEvent({
    required this.eventId,
    required this.deliveryTaskId,
    required this.action,
    this.previousStatus,
    required this.newStatus,
    required this.recordedAt,
    this.reason,
  });

  final String eventId;
  final String deliveryTaskId;
  final BusinessDeliveryTaskHistoryAction action;
  final BusinessDeliveryTaskStatus? previousStatus;
  final BusinessDeliveryTaskStatus newStatus;
  final DateTime recordedAt;
  final String? reason;
}

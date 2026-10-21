import 'package:qoshni/features/business_platform/domain/business_delivery_proof_status.dart';

enum BusinessDeliveryProofHistoryAction {
  created,
  statusChanged,
}

class BusinessDeliveryProofHistoryEvent {
  const BusinessDeliveryProofHistoryEvent({
    required this.eventId,
    required this.proofId,
    required this.deliveryTaskId,
    required this.action,
    this.previousStatus,
    required this.newStatus,
    required this.recordedAt,
    this.reason,
  });

  final String eventId;
  final String proofId;
  final String deliveryTaskId;
  final BusinessDeliveryProofHistoryAction action;
  final BusinessDeliveryProofStatus? previousStatus;
  final BusinessDeliveryProofStatus newStatus;
  final DateTime recordedAt;
  final String? reason;
}

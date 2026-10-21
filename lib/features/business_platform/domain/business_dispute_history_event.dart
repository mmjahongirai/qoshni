import 'package:qoshni/features/business_platform/domain/business_dispute_status.dart';

enum BusinessDisputeHistoryAction {
  created,
  statusChanged,
}

class BusinessDisputeHistoryEvent {
  const BusinessDisputeHistoryEvent({
    required this.eventId,
    required this.disputeId,
    required this.complaintId,
    required this.action,
    this.previousStatus,
    required this.newStatus,
    required this.recordedAt,
    this.reason,
  });

  final String eventId;
  final String disputeId;
  final String complaintId;
  final BusinessDisputeHistoryAction action;
  final BusinessDisputeStatus? previousStatus;
  final BusinessDisputeStatus newStatus;
  final DateTime recordedAt;
  final String? reason;
}

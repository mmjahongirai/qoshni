import 'package:qoshni/features/business_platform/domain/business_complaint_status.dart';

enum BusinessComplaintHistoryAction {
  created,
  statusChanged,
}

class BusinessComplaintHistoryEvent {
  const BusinessComplaintHistoryEvent({
    required this.eventId,
    required this.complaintId,
    required this.action,
    this.previousStatus,
    required this.newStatus,
    required this.recordedAt,
    this.reason,
  });

  final String eventId;
  final String complaintId;
  final BusinessComplaintHistoryAction action;
  final BusinessComplaintStatus? previousStatus;
  final BusinessComplaintStatus newStatus;
  final DateTime recordedAt;
  final String? reason;
}

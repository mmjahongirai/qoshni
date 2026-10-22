import 'package:qoshni/features/business_platform/domain/business_review_status.dart';

enum BusinessReviewHistoryAction {
  created,
  statusChanged,
}

class BusinessReviewHistoryEvent {
  const BusinessReviewHistoryEvent({
    required this.eventId,
    required this.reviewId,
    required this.action,
    this.previousStatus,
    required this.newStatus,
    required this.recordedAt,
    this.reason,
  });

  final String eventId;
  final String reviewId;
  final BusinessReviewHistoryAction action;
  final BusinessReviewStatus? previousStatus;
  final BusinessReviewStatus newStatus;
  final DateTime recordedAt;
  final String? reason;
}

import 'package:qoshni/features/business_platform/domain/business_complaint.dart';
import 'package:qoshni/features/business_platform/domain/business_complaint_category.dart';
import 'package:qoshni/features/business_platform/domain/business_complaint_history_event.dart';
import 'package:qoshni/features/business_platform/domain/business_complaint_status.dart';
import 'package:qoshni/features/business_platform/domain/business_review_target_type.dart';

enum BusinessComplaintCreateResult {
  success,
  invalidInput,
  invalidEvidence,
  scopeMismatch,
  relatedReviewNotFound,
  failure,
}

enum BusinessComplaintTransitionResult {
  success,
  notFound,
  invalidTransition,
  duplicateStatus,
  resolutionNoteRequired,
  failure,
}

class BusinessComplaintTransitionRequest {
  const BusinessComplaintTransitionRequest({
    required this.targetStatus,
    this.resolutionNote,
  });

  final BusinessComplaintStatus targetStatus;
  final String? resolutionNote;
}

abstract class BusinessComplaintRepository {
  String get businessScopeId;

  List<BusinessComplaint> listForCurrentScope({
    String? branchId,
    BusinessReviewTargetType? targetType,
    BusinessComplaintCategory? category,
    BusinessComplaintStatus? status,
  });

  BusinessComplaint? findById(String complaintId);

  BusinessComplaintCreateResult createComplaint(
    BusinessComplaintCreateInput input,
  );

  BusinessComplaintTransitionResult applyTransition({
    required String complaintId,
    required BusinessComplaintTransitionRequest request,
  });

  List<BusinessComplaintHistoryEvent> complaintHistory(String complaintId);
}

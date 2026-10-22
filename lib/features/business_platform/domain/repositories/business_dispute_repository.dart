import 'package:qoshni/features/business_platform/domain/business_dispute.dart';
import 'package:qoshni/features/business_platform/domain/business_dispute_history_event.dart';
import 'package:qoshni/features/business_platform/domain/business_dispute_status.dart';

enum BusinessDisputeCreateResult {
  success,
  invalidInput,
  complaintNotFound,
  complaintNotEligible,
  duplicateForComplaint,
  invalidEvidence,
  scopeMismatch,
  failure,
}

enum BusinessDisputeTransitionResult {
  success,
  notFound,
  invalidTransition,
  duplicateStatus,
  resolutionNoteRequired,
  failure,
}

class BusinessDisputeTransitionRequest {
  const BusinessDisputeTransitionRequest({
    required this.targetStatus,
    this.resolutionNote,
  });

  final BusinessDisputeStatus targetStatus;
  final String? resolutionNote;
}

abstract class BusinessDisputeRepository {
  String get businessScopeId;

  List<BusinessDispute> listForCurrentScope({
    String? branchId,
    String? complaintId,
    BusinessDisputeStatus? status,
  });

  BusinessDispute? findById(String disputeId);

  BusinessDispute? findByComplaintId(String complaintId);

  BusinessDisputeCreateResult createDispute(BusinessDisputeCreateInput input);

  BusinessDisputeTransitionResult applyTransition({
    required String disputeId,
    required BusinessDisputeTransitionRequest request,
  });

  List<BusinessDisputeHistoryEvent> disputeHistory(String disputeId);
}

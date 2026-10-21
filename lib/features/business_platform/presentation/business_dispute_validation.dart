import 'package:qoshni/features/business_platform/domain/business_dispute.dart';
import 'package:qoshni/features/business_platform/presentation/business_complaint_validation.dart';

const int kBusinessDisputeSummaryMaxLength = 2000;

String? catalogBusinessDisputeSummaryValidationError(String summary) {
  final s = summary.trim();
  if (s.isEmpty) {
    return 'summary_required';
  }
  if (s.length > kBusinessDisputeSummaryMaxLength) {
    return 'summary_too_long';
  }
  return null;
}

String? catalogBusinessDisputeResolutionNoteValidationError(String? note) {
  return catalogBusinessComplaintResolutionNoteValidationError(note);
}

String? catalogBusinessDisputeCreateValidationError(
  BusinessDisputeCreateInput input,
) {
  if (input.complaintId.trim().isEmpty) {
    return 'invalid_complaint';
  }
  if (input.demoBusinessInitiatorReference.trim().isEmpty) {
    return 'invalid_initiator';
  }
  if (catalogBusinessDisputeSummaryValidationError(input.summary) != null) {
    return 'invalid_summary';
  }
  if (input.syntheticEvidenceReferences.isEmpty) {
    return 'evidence_required';
  }
  for (final ref in input.syntheticEvidenceReferences) {
    if (ref.trim().isEmpty ||
        !catalogBusinessComplaintSyntheticEvidenceAllowed(ref)) {
      return 'invalid_evidence';
    }
  }
  return null;
}

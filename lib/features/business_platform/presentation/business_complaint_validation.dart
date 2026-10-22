import 'package:qoshni/features/business_platform/domain/business_complaint.dart';

const int kBusinessComplaintDescriptionMaxLength = 4000;
const int kBusinessComplaintResolutionNoteMaxLength = 500;

String? catalogBusinessComplaintDescriptionValidationError(String description) {
  final d = description.trim();
  if (d.isEmpty) {
    return 'description_required';
  }
  if (d.length > kBusinessComplaintDescriptionMaxLength) {
    return 'description_too_long';
  }
  return null;
}

String? catalogBusinessComplaintResolutionNoteValidationError(String? note) {
  final n = note?.trim();
  if (n == null || n.isEmpty) {
    return 'resolution_note_required';
  }
  if (n.length > kBusinessComplaintResolutionNoteMaxLength) {
    return 'resolution_note_too_long';
  }
  return null;
}

String? catalogBusinessComplaintCreateValidationError(
  BusinessComplaintCreateInput input,
) {
  if (input.targetId.trim().isEmpty) {
    return 'invalid_target';
  }
  if (input.demoReporterReference.trim().isEmpty) {
    return 'invalid_reporter';
  }
  if (catalogBusinessComplaintDescriptionValidationError(input.description) !=
      null) {
    return 'invalid_description';
  }
  if (input.syntheticEvidenceReferences.isEmpty) {
    return 'evidence_required';
  }
  for (final ref in input.syntheticEvidenceReferences) {
    if (ref.trim().isEmpty) {
      return 'invalid_evidence';
    }
  }
  return null;
}

bool catalogBusinessComplaintSyntheticEvidenceAllowed(String reference) {
  final r = reference.trim();
  return r.startsWith('demo-complaint-evidence-') ||
      r.startsWith('demo-dispute-evidence-');
}

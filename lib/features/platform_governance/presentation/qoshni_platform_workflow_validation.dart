const int kQoshniPlatformWorkflowIdMaxLength = 80;
const int kQoshniPlatformWorkflowReasonMaxLength = 120;
const int kQoshniPlatformWorkflowNoteMaxLength = 2000;
const int kQoshniPlatformWorkflowSummaryMaxLength = 500;

String? qoshniPlatformWorkflowReasonValidationError(String reason) {
  final value = reason.trim();
  if (value.isEmpty || value.length > kQoshniPlatformWorkflowReasonMaxLength) {
    return 'invalid_reason';
  }
  if (value.contains('<') || value.contains('>') || value.contains('http://')) {
    return 'unsafe_reason';
  }
  return null;
}

String? qoshniPlatformSupportNoteValidationError(String body) {
  final value = body.trim();
  if (value.isEmpty || value.length > kQoshniPlatformWorkflowNoteMaxLength) {
    return 'invalid_note';
  }
  if (value.contains('<') || value.contains('>') || value.contains('http://')) {
    return 'unsafe_note';
  }
  return null;
}

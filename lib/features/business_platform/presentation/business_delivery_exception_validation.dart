import 'package:qoshni/features/business_platform/domain/business_delivery_exception.dart';

String? catalogDeliveryExceptionReasonValidationError(String? reason) {
  final trimmed = reason?.trim() ?? '';
  if (trimmed.isEmpty) {
    return 'empty_reason';
  }
  if (trimmed.length > 240) {
    return 'reason_too_long';
  }
  return null;
}

String? catalogDeliveryExceptionResolutionNoteValidationError(String? note) {
  final trimmed = note?.trim() ?? '';
  if (trimmed.isEmpty) {
    return 'resolution_required';
  }
  if (trimmed.length > 240) {
    return 'resolution_too_long';
  }
  return null;
}

String? catalogDeliveryExceptionCreateValidationError(
  BusinessDeliveryExceptionCreateInput input,
) {
  return catalogDeliveryExceptionReasonValidationError(input.reason);
}

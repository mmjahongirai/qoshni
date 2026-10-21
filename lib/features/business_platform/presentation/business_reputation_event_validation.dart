import 'package:qoshni/features/business_platform/domain/business_reputation_event.dart';

const int kBusinessReputationCorrelationMaxLength = 200;
const int kBusinessReputationMetadataMaxLength = 500;

String? catalogBusinessReputationEventRecordValidationError(
  BusinessReputationEventRecordInput input,
) {
  if (input.businessScopeId.trim().isEmpty) {
    return 'invalid_scope';
  }
  if (input.targetId.trim().isEmpty) {
    return 'invalid_target';
  }
  if (input.sourceRecordId.trim().isEmpty) {
    return 'invalid_source';
  }
  final corr = input.correlationReferenceId.trim();
  if (corr.isEmpty || corr.length > kBusinessReputationCorrelationMaxLength) {
    return 'invalid_correlation';
  }
  if (!_isSafeReferenceToken(corr)) {
    return 'unsafe_correlation';
  }
  final meta = input.metadataSummary?.trim();
  if (meta != null && meta.length > kBusinessReputationMetadataMaxLength) {
    return 'metadata_too_long';
  }
  if (meta != null && !_isSafeMetadata(meta)) {
    return 'unsafe_metadata';
  }
  return null;
}

bool _isSafeReferenceToken(String value) {
  if (value.contains('@') || value.contains('+998')) {
    return false;
  }
  return true;
}

bool _isSafeMetadata(String value) {
  final lower = value.toLowerCase();
  if (lower.contains('email') ||
      lower.contains('phone') ||
      lower.contains('password')) {
    return false;
  }
  return _isSafeReferenceToken(value);
}

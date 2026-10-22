import 'package:qoshni/features/business_platform/domain/business_delivery_proof_of_delivery.dart';

/// Rejects strings that look like real OTP codes or URLs to media.
String? catalogDeliveryProofEvidenceValidationError(String? reference) {
  final trimmed = reference?.trim() ?? '';
  if (trimmed.isEmpty) {
    return 'empty_evidence';
  }
  if (trimmed.length > 120) {
    return 'evidence_too_long';
  }
  final lower = trimmed.toLowerCase();
  if (lower.startsWith('http://') ||
      lower.startsWith('https://') ||
      lower.contains('://')) {
    return 'evidence_looks_like_url';
  }
  if (RegExp(r'^\d{4,8}$').hasMatch(trimmed)) {
    return 'evidence_looks_like_otp';
  }
  return null;
}

String? catalogDeliveryProofDescriptionValidationError(String? description) {
  final trimmed = description?.trim() ?? '';
  if (trimmed.isEmpty) {
    return 'empty_description';
  }
  if (trimmed.length > 240) {
    return 'description_too_long';
  }
  return null;
}

String? catalogDeliveryProofCreateValidationError(
  BusinessDeliveryProofCreateInput input,
) {
  if (catalogDeliveryProofEvidenceValidationError(
        input.demoEvidenceReference,
      ) !=
      null) {
    return catalogDeliveryProofEvidenceValidationError(
      input.demoEvidenceReference,
    );
  }
  return catalogDeliveryProofDescriptionValidationError(input.description);
}

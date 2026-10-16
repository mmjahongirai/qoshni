import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/features/business_onboarding/data/onboarding_dtos.dart';
import 'package:qoshni/features/business_onboarding/domain/onboarding_failure.dart';

/// Backend `OnboardingErrorCode` from `app.api.schemas.business_onboarding`.
const _backendOnboardingErrorCodes = [
  'application_not_found',
  'forbidden',
  'invalid_status_transition',
  'validation_failed',
  'storage_unavailable',
  'malware_scan_unavailable',
  'document_rejected',
  'suspended',
];

/// Owner routes under `/api/v1` + prefix from backend contracts.
const backendOwnerOnboardingRoutes = [
  ('POST', '/api/v1/business/onboarding/applications', 201),
  ('GET', '/api/v1/business/onboarding/applications', 200),
  ('GET', '/api/v1/business/onboarding/applications/{application_id}', 200),
  ('PATCH', '/api/v1/business/onboarding/applications/{application_id}', 200),
  (
    'POST',
    '/api/v1/business/onboarding/applications/{application_id}/submit',
    200,
  ),
  (
    'GET',
    '/api/v1/business/onboarding/applications/{application_id}/verification-status',
    200,
  ),
  (
    'POST',
    '/api/v1/business/onboarding/applications/{application_id}/documents',
    201,
  ),
  (
    'GET',
    '/api/v1/business/onboarding/applications/{application_id}/documents',
    200,
  ),
  (
    'POST',
    '/api/v1/business/onboarding/applications/{application_id}/documents/{document_id}/upload',
    200,
  ),
];

void main() {
  test('Flutter OnboardingErrorCode covers backend onboarding error codes', () {
    for (final apiValue in _backendOnboardingErrorCodes) {
      expect(
        OnboardingErrorCode.tryParse(apiValue),
        isNotNull,
        reason: 'missing mapping for $apiValue',
      );
    }
  });

  test('Flutter repository prefix matches owner API contracts', () {
    expect(backendOwnerOnboardingRoutes.length, 9);
    for (final route in backendOwnerOnboardingRoutes) {
      expect(route.$2.startsWith('/api/v1/business/onboarding'), isTrue);
      expect(route.$2.contains('/internal/'), isFalse);
    }
  });

  test('register document request uses snake_case document_type', () {
    expect(
      const RegisterOnboardingDocumentRequestDto(
        documentType: OnboardingDocumentTypes.registrationCertificate,
      ).toJson(),
      {'document_type': 'registration_certificate'},
    );
  });

  test('owner application view parses backend enum strings', () {
    final dto = OwnerApplicationViewDto.fromJson({
      'application_id': 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
      'legal_business_name': 'Ada',
      'trade_display_name': null,
      'service_category': 'shops',
      'registration_jurisdiction': 'UZ',
      'registration_identifier': null,
      'tax_identifier': null,
      'business_contact_email': null,
      'verification_status': 'submitted',
      'rejection_reason_code': null,
      'submitted_at': '2026-10-14T12:00:00Z',
      'reviewed_at': null,
      'created_at': '2026-10-14T12:00:00Z',
      'updated_at': '2026-10-14T12:05:00Z',
    });
    expect(dto.serviceCategory, 'shops');
    expect(dto.verificationStatus, 'submitted');
  });
}

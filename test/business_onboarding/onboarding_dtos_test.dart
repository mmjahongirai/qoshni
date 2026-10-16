import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/features/business_onboarding/data/onboarding_dtos.dart';

void main() {
  const applicationJson = {
    'application_id': 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
    'legal_business_name': 'Acme LLC',
    'trade_display_name': 'Acme',
    'service_category': 'shops',
    'registration_jurisdiction': 'UZ',
    'registration_identifier': 'REG-1',
    'tax_identifier': 'TAX-9',
    'business_contact_email': 'owner@example.com',
    'verification_status': 'draft',
    'rejection_reason_code': null,
    'submitted_at': null,
    'reviewed_at': null,
    'created_at': '2026-10-14T12:00:00Z',
    'updated_at': '2026-10-14T12:05:00Z',
  };

  test('OwnerApplicationViewDto parses owner fields', () {
    final dto = OwnerApplicationViewDto.fromJson(applicationJson);
    expect(dto.applicationId, 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa');
    expect(dto.legalBusinessName, 'Acme LLC');
    expect(dto.verificationStatus, 'draft');
    expect(dto.isDraft, isTrue);
  });

  test('draft update request serializes editable fields', () {
    const request = OnboardingApplicationDraftUpdateRequestDto(
      legalBusinessName: 'New Name',
      serviceCategory: 'groceries',
      registrationJurisdiction: 'UZ',
    );
    expect(request.toJson(), {
      'legal_business_name': 'New Name',
      'service_category': 'groceries',
      'registration_jurisdiction': 'UZ',
    });
  });

  test('OwnerDocumentViewDto ignores unknown future keys via strict client', () {
    final dto = OwnerDocumentViewDto.fromJson({
      'document_id': 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
      'application_id': 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
      'document_type': 'registration_certificate',
      'lifecycle_state': 'awaiting_upload',
      'created_at': '2026-10-14T12:00:00Z',
      'updated_at': '2026-10-14T12:00:00Z',
    });
    expect(dto.documentType, 'registration_certificate');
    expect(dto.lifecycleState, 'awaiting_upload');
  });

  test('create request omits null keys', () {
    const request = OnboardingApplicationCreateRequestDto(
      registrationJurisdiction: 'UZ',
    );
    expect(request.toJson(), {'registration_jurisdiction': 'UZ'});
  });
}

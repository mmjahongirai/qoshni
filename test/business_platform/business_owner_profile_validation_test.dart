import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/features/business_platform/domain/business_owner_profile.dart';
import 'package:qoshni/features/business_platform/presentation/business_owner_profile_validation.dart';
import 'package:qoshni/features/home/presentation/data/service_category_id.dart';

void main() {
  test('valid input passes validation', () {
    const input = BusinessOwnerProfileInput(
      legalBusinessName: 'Legal LLC',
      displayName: 'Shop',
      description: 'Desc',
      categoryId: ServiceCategoryId.shops,
      contactEmail: 'a@example.com',
      websiteUrl: 'https://example.com',
    );

    final result = validateBusinessOwnerProfileInput(
      input,
      legalNameRequired: () => 'legal',
      displayNameRequired: () => 'display',
      descriptionRequired: () => 'desc',
      emailInvalid: () => 'email',
      websiteInvalid: () => 'web',
    );

    expect(result.isValid, isTrue);
  });

  test('invalid email and empty required fields fail', () {
    const input = BusinessOwnerProfileInput(
      legalBusinessName: '',
      displayName: '',
      description: '',
      categoryId: ServiceCategoryId.shops,
      contactEmail: 'not-an-email',
      websiteUrl: 'not a url',
    );

    final result = validateBusinessOwnerProfileInput(
      input,
      legalNameRequired: () => 'legal',
      displayNameRequired: () => 'display',
      descriptionRequired: () => 'desc',
      emailInvalid: () => 'email',
      websiteInvalid: () => 'web',
    );

    expect(result.isValid, isFalse);
    expect(result.legalBusinessNameError, isNotNull);
    expect(result.contactEmailError, isNotNull);
    expect(result.websiteUrlError, isNotNull);
  });
}

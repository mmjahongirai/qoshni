import 'package:qoshni/features/business_platform/domain/business_owner_profile.dart';
class BusinessOwnerProfileValidationResult {
  const BusinessOwnerProfileValidationResult({
    required this.isValid,
    this.legalBusinessNameError,
    this.displayNameError,
    this.descriptionError,
    this.contactEmailError,
    this.websiteUrlError,
  });

  final bool isValid;
  final String? legalBusinessNameError;
  final String? displayNameError;
  final String? descriptionError;
  final String? contactEmailError;
  final String? websiteUrlError;
}

BusinessOwnerProfileValidationResult validateBusinessOwnerProfileInput(
  BusinessOwnerProfileInput input, {
  required String Function() legalNameRequired,
  required String Function() displayNameRequired,
  required String Function() descriptionRequired,
  required String Function() emailInvalid,
  required String Function() websiteInvalid,
}) {
  String? legalError;
  String? displayError;
  String? descriptionError;
  String? emailError;
  String? websiteError;

  if (input.legalBusinessName.trim().isEmpty) {
    legalError = legalNameRequired();
  }
  if (input.displayName.trim().isEmpty) {
    displayError = displayNameRequired();
  }
  if (input.description.trim().isEmpty) {
    descriptionError = descriptionRequired();
  }
  final email = input.contactEmail?.trim();
  if (email != null && email.isNotEmpty && !_looksLikeEmail(email)) {
    emailError = emailInvalid();
  }
  final website = input.websiteUrl?.trim();
  if (website != null &&
      website.isNotEmpty &&
      !_looksLikeWebsite(website)) {
    websiteError = websiteInvalid();
  }
  return BusinessOwnerProfileValidationResult(
    isValid: legalError == null &&
        displayError == null &&
        descriptionError == null &&
        emailError == null &&
        websiteError == null,
    legalBusinessNameError: legalError,
    displayNameError: displayError,
    descriptionError: descriptionError,
    contactEmailError: emailError,
    websiteUrlError: websiteError,
  );
}

bool _looksLikeEmail(String value) {
  return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value);
}

bool _looksLikeWebsite(String value) {
  if (value.contains(' ')) {
    return false;
  }
  final normalized =
      value.startsWith('http://') || value.startsWith('https://')
          ? value
          : 'https://$value';
  final uri = Uri.tryParse(normalized);
  if (uri == null || uri.host.isEmpty) {
    return false;
  }
  return uri.host.contains('.');
}

/// Typed failures for owner business onboarding APIs.
enum OnboardingErrorCode {
  applicationNotFound('application_not_found'),
  forbidden('forbidden'),
  invalidStatusTransition('invalid_status_transition'),
  validationFailed('validation_failed'),
  storageUnavailable('storage_unavailable'),
  malwareScanUnavailable('malware_scan_unavailable'),
  documentRejected('document_rejected'),
  suspended('suspended'),
  authenticationRequired('authentication_required'),
  apiNotConfigured('api_not_configured'),
  network('network'),
  malformedResponse('malformed_response'),
  unknown('unknown');

  const OnboardingErrorCode(this.apiValue);

  final String apiValue;

  static OnboardingErrorCode? tryParse(String? raw) {
    if (raw == null || raw.isEmpty) {
      return null;
    }
    for (final code in OnboardingErrorCode.values) {
      if (code.apiValue == raw) {
        return code;
      }
    }
    return null;
  }

  bool get isSessionFailure =>
      this == OnboardingErrorCode.authenticationRequired ||
      this == OnboardingErrorCode.forbidden;
}

class OnboardingFailure implements Exception {
  const OnboardingFailure({
    required this.code,
    required this.message,
  });

  final OnboardingErrorCode code;
  final String message;

  @override
  String toString() => 'OnboardingFailure(${code.apiValue})';
}

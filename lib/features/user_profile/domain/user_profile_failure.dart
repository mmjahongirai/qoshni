/// Typed failures for `/api/v1/me/profile` and `/api/v1/me/preferences`.
enum UserProfileErrorCode {
  profileNotFound('profile_not_found'),
  preferencesNotFound('preferences_not_found'),
  authenticationRequired('authentication_required'),
  sessionInvalid('session_invalid'),
  accountUnavailable('account_unavailable'),
  apiNotConfigured('api_not_configured'),
  network('network'),
  validationFailed('validation_failed'),
  serviceUnavailable('service_unavailable'),
  malformedResponse('malformed_response'),
  unknown('unknown');

  const UserProfileErrorCode(this.apiValue);

  final String apiValue;

  static UserProfileErrorCode? tryParse(String? raw) {
    if (raw == null || raw.isEmpty) {
      return null;
    }
    for (final code in UserProfileErrorCode.values) {
      if (code.apiValue == raw) {
        return code;
      }
    }
    return null;
  }

  bool get isSessionFailure =>
      this == UserProfileErrorCode.authenticationRequired ||
      this == UserProfileErrorCode.sessionInvalid ||
      this == UserProfileErrorCode.accountUnavailable;
}

class UserProfileFailure implements Exception {
  const UserProfileFailure({
    required this.code,
    required this.message,
  });

  final UserProfileErrorCode code;
  final String message;

  @override
  String toString() => 'UserProfileFailure(${code.apiValue})';
}

/// Typed authentication failures mapped from backend error codes and transport.
enum AuthErrorCode {
  challengeInvalid('challenge_invalid'),
  challengeExpired('challenge_expired'),
  challengeConsumed('challenge_consumed'),
  challengeLocked('challenge_locked'),
  codeIncorrect('code_incorrect'),
  rateLimited('rate_limited'),
  featureNotAvailable('feature_not_available'),
  serviceUnavailable('service_unavailable'),
  accountUnavailable('account_unavailable'),
  sessionInvalid('session_invalid'),
  sessionNotFound('session_not_found'),
  authenticationRequired('authentication_required'),
  apiNotConfigured('api_not_configured'),
  network('network'),
  malformedResponse('malformed_response'),
  unknown('unknown');

  const AuthErrorCode(this.apiValue);

  final String apiValue;

  static AuthErrorCode? tryParse(String? raw) {
    if (raw == null || raw.isEmpty) {
      return null;
    }
    for (final code in AuthErrorCode.values) {
      if (code.apiValue == raw) {
        return code;
      }
    }
    return null;
  }
}

class AuthFailure implements Exception {
  const AuthFailure({
    required this.code,
    required this.message,
    this.retryAfterSeconds,
    this.attemptsRemaining,
  });

  final AuthErrorCode code;
  final String message;
  final int? retryAfterSeconds;
  final int? attemptsRemaining;

  @override
  String toString() => 'AuthFailure(${code.apiValue})';
}

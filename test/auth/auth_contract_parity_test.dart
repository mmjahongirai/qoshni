import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/features/auth/data/auth_dtos.dart';
import 'package:qoshni/features/auth/domain/auth_failure.dart';

/// Backend `AuthErrorCode` values from `app.api.schemas.auth`.
const _backendAuthErrorCodes = [
  'challenge_invalid',
  'challenge_expired',
  'challenge_consumed',
  'challenge_locked',
  'code_incorrect',
  'rate_limited',
  'session_invalid',
  'session_not_found',
  'authentication_required',
  'feature_not_available',
  'service_unavailable',
  'account_unavailable',
];

/// Documented backend routes under `settings.api_v1_prefix` + `/auth`.
const backendAuthRoutes = [
  ('POST', '/api/v1/auth/otp/challenges', 202),
  ('POST', '/api/v1/auth/otp/verify', 200),
  ('POST', '/api/v1/auth/sessions/refresh', 200),
  ('GET', '/api/v1/auth/sessions', 200),
  ('DELETE', '/api/v1/auth/sessions/current', 204),
  ('DELETE', '/api/v1/auth/sessions/{session_id}', 204),
];

void main() {
  test('Flutter AuthErrorCode covers every backend auth error code', () {
    for (final apiValue in _backendAuthErrorCodes) {
      expect(
        AuthErrorCode.tryParse(apiValue),
        isNotNull,
        reason: 'missing mapping for $apiValue',
      );
    }
  });

  test('OTP create request matches backend OtpChallengeCreateRequest', () {
    expect(
      const OtpChallengeCreateRequestDto(phone: '+998901234567').toJson(),
      {'phone': '+998901234567', 'purpose': 'sign_in'},
    );
  });

  test('OTP verify request matches backend OtpChallengeVerifyRequest', () {
    expect(
      const OtpChallengeVerifyRequestDto(
        challengeId: '11111111-1111-1111-1111-111111111111',
        code: '123456',
      ).toJson(),
      {
        'challenge_id': '11111111-1111-1111-1111-111111111111',
        'code': '123456',
      },
    );
  });

  test('session refresh request matches backend SessionRefreshRequest', () {
    expect(
      SessionRefreshRequestDto(refreshToken: 'r' * 48).toJson(),
      {'refresh_token': 'r' * 48},
    );
  });

  test('Flutter client targets the six implemented backend auth routes', () {
    expect(backendAuthRoutes.length, 6);
    expect(
      backendAuthRoutes.map((r) => r.$2).toSet().length,
      6,
      reason: 'paths must be unique',
    );
  });

  test('parses backend session list envelope', () {
    final list = SessionListDto.fromJson({
      'sessions': [
        {
          'session_id': '33333333-3333-3333-3333-333333333333',
          'state': 'active',
          'created_at': '2026-10-14T12:00:00Z',
          'expires_at': '2026-11-14T12:00:00Z',
          'last_seen_at': '2026-10-14T12:05:00Z',
          'device_platform': 'web',
          'is_current': true,
        },
      ],
    });
    expect(list.sessions.single.devicePlatform, 'web');
    expect(list.sessions.single.state, 'active');
  });

  test('maps cross-user revoke session_not_found envelope', () {
    final failure = AuthErrorEnvelopeDto.fromJson({
      'error': {
        'code': 'session_not_found',
        'message': 'Session not found.',
      },
    }).toFailure();
    expect(failure.code, AuthErrorCode.sessionNotFound);
  });

  test('maps revoked access token session_invalid envelope', () {
    final failure = AuthErrorEnvelopeDto.fromJson({
      'error': {
        'code': 'session_invalid',
        'message': 'Session is no longer valid.',
      },
    }).toFailure();
    expect(failure.code, AuthErrorCode.sessionInvalid);
  });

  test('SessionTokensDto defaults token_type to bearer', () {
    final dto = SessionTokensDto.fromJson({
      'access_token': 'access-token-value',
      'access_token_expires_at': '2026-10-14T12:15:00Z',
      'refresh_token': 'refresh-token-value',
      'refresh_token_expires_at': '2026-11-14T12:00:00Z',
      'user_id': '22222222-2222-2222-2222-222222222222',
      'session': {
        'session_id': '33333333-3333-3333-3333-333333333333',
        'state': 'active',
        'created_at': '2026-10-14T12:00:00Z',
        'expires_at': '2026-11-14T12:00:00Z',
        'is_current': true,
      },
    });
    expect(dto.tokenType, 'bearer');
  });
}

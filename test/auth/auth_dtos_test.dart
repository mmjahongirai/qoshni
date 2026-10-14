import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/features/auth/data/auth_dtos.dart';
import 'package:qoshni/features/auth/domain/auth_failure.dart';

void main() {
  test('parses otp challenge created response', () {
    final dto = OtpChallengeCreatedDto.fromJson({
      'challenge_id': '11111111-1111-1111-1111-111111111111',
      'expires_at': '2026-10-14T12:00:00Z',
      'code_length': 6,
    });

    expect(dto.codeLength, 6);
    expect(dto.challengeId, isNotEmpty);
  });

  test('parses session tokens without digest fields', () {
    final dto = SessionTokensDto.fromJson({
      'token_type': 'bearer',
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
    expect(dto.session.state, 'active');
    expect(dto.toString(), isNot(contains('digest')));
  });

  test('maps auth error envelope to typed failure', () {
    final failure = AuthErrorEnvelopeDto.fromJson({
      'error': {
        'code': 'service_unavailable',
        'message': 'Sign-in is temporarily unavailable.',
      },
    }).toFailure();

    expect(failure.code, AuthErrorCode.serviceUnavailable);
  });
}

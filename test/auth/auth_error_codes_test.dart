import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/features/auth/data/auth_dtos.dart';
import 'package:qoshni/features/auth/domain/auth_failure.dart';

void main() {
  for (final expected in [
    ('challenge_invalid', AuthErrorCode.challengeInvalid),
    ('service_unavailable', AuthErrorCode.serviceUnavailable),
    ('session_invalid', AuthErrorCode.sessionInvalid),
    ('rate_limited', AuthErrorCode.rateLimited),
  ]) {
    test('maps ${expected.$1}', () {
      final failure = AuthErrorEnvelopeDto.fromJson({
        'error': {'code': expected.$1, 'message': 'msg'},
      }).toFailure();
      expect(failure.code, expected.$2);
    });
  }

  test('unknown backend code maps to unknown', () {
    final failure = AuthErrorEnvelopeDto.fromJson({
      'error': {'code': 'not_a_real_code', 'message': 'msg'},
    }).toFailure();
    expect(failure.code, AuthErrorCode.unknown);
  });
}

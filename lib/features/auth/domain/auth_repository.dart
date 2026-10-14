import 'package:qoshni/features/auth/data/auth_dtos.dart';

/// Remote authentication API (no fake success paths in production implementations).
abstract class AuthRepository {
  Future<OtpChallengeCreatedDto> requestOtpChallenge(String phoneE164);

  Future<SessionTokensDto> verifyOtpChallenge({
    required String challengeId,
    required String code,
  });

  Future<SessionTokensDto> refreshSession(String refreshToken);

  Future<List<SessionViewDto>> listSessions(String accessToken);

  Future<void> revokeCurrentSession(String accessToken);

  Future<void> revokeSession({
    required String accessToken,
    required String sessionId,
  });
}

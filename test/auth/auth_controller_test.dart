import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/core/config/app_config.dart';
import 'package:qoshni/core/config/app_environment.dart';
import 'package:qoshni/features/auth/data/auth_credential_store.dart';
import 'package:qoshni/features/auth/data/auth_dtos.dart';
import 'package:qoshni/features/auth/domain/auth_failure.dart';
import 'package:qoshni/features/auth/domain/auth_repository.dart';
import 'package:qoshni/features/auth/presentation/auth_controller.dart';

class _MockAuthRepository implements AuthRepository {
  bool failOtpWith503 = false;
  bool allowVerify = true;
  int verifyCalls = 0;

  @override
  Future<OtpChallengeCreatedDto> requestOtpChallenge(String phoneE164) async {
    if (failOtpWith503) {
      throw const AuthFailure(
        code: AuthErrorCode.serviceUnavailable,
        message: 'unavailable',
      );
    }
    return OtpChallengeCreatedDto(
      challengeId: '11111111-1111-1111-1111-111111111111',
      expiresAt: DateTime.utc(2026, 10, 14, 12),
      codeLength: 6,
    );
  }

  @override
  Future<SessionTokensDto> verifyOtpChallenge({
    required String challengeId,
    required String code,
  }) async {
    verifyCalls++;
    if (!allowVerify) {
      throw const AuthFailure(
        code: AuthErrorCode.codeIncorrect,
        message: 'wrong',
      );
    }
    return SessionTokensDto(
      tokenType: 'bearer',
      accessToken: 'access-$verifyCalls',
      accessTokenExpiresAt: DateTime.utc(2026, 10, 14, 12, 15),
      refreshToken: 'refresh-$verifyCalls',
      refreshTokenExpiresAt: DateTime.utc(2026, 11, 14),
      userId: '22222222-2222-2222-2222-222222222222',
      session: SessionViewDto(
        sessionId: '33333333-3333-3333-3333-333333333333',
        state: 'active',
        createdAt: DateTime.utc(2026, 10, 14, 12),
        expiresAt: DateTime.utc(2026, 11, 14),
        isCurrent: true,
      ),
    );
  }

  bool refreshFails = false;

  @override
  Future<SessionTokensDto> refreshSession(String refreshToken) async {
    if (refreshFails) {
      throw const AuthFailure(
        code: AuthErrorCode.sessionInvalid,
        message: 'invalid',
      );
    }
    throw UnimplementedError();
  }

  @override
  Future<List<SessionViewDto>> listSessions(String accessToken) async => [];

  @override
  Future<void> revokeCurrentSession(String accessToken) async {}

  @override
  Future<void> revokeSession({
    required String accessToken,
    required String sessionId,
  }) async {}
}

void main() {
  test('unconfigured api url does not sign in', () async {
    final controller = AuthController(
      repository: _MockAuthRepository(),
      credentialStore: InMemoryAuthCredentialStore(),
      config: AppConfig.forEnvironment(AppEnvironment.development),
    );

    await controller.requestOtp('+998901234567');

    expect(controller.isSignedIn, isFalse);
    expect(controller.lastFailure?.code, AuthErrorCode.apiNotConfigured);
  });

  test('503 from otp request keeps guest state', () async {
    final repo = _MockAuthRepository()..failOtpWith503 = true;
    final controller = AuthController(
      repository: repo,
      credentialStore: InMemoryAuthCredentialStore(),
      config: const AppConfig(
        environment: AppEnvironment.development,
        appName: 'test',
        apiBaseUrl: 'https://api.example.test',
        enableLogging: false,
        enableBusinessProfileSamples: false,
        enableBusinessOfferingSamples: false,
        enableRemoteSearchDiscovery: false,
      ),
    );

    await controller.requestOtp('+998901234567');

    expect(controller.status, AuthStatus.guest);
    expect(controller.lastFailure?.code, AuthErrorCode.serviceUnavailable);
  });

  test('successful verify signs in and logout clears state', () async {
    final controller = AuthController(
      repository: _MockAuthRepository(),
      credentialStore: InMemoryAuthCredentialStore(),
      config: const AppConfig(
        environment: AppEnvironment.development,
        appName: 'test',
        apiBaseUrl: 'https://api.example.test',
        enableLogging: false,
        enableBusinessProfileSamples: false,
        enableBusinessOfferingSamples: false,
        enableRemoteSearchDiscovery: false,
      ),
    );

    await controller.requestOtp('+998901234567');
    expect(controller.isSignedIn, isFalse);
    expect(controller.status, AuthStatus.otpPending);
    await controller.verifyOtp('123456');
    expect(controller.isSignedIn, isTrue);
    expect(controller.accessToken, isNotNull);

    await controller.signOut();
    expect(controller.isSignedIn, isFalse);
    expect(controller.accessToken, isNull);
  });

  test('incorrect code does not sign in', () async {
    final repo = _MockAuthRepository()..allowVerify = false;
    final controller = AuthController(
      repository: repo,
      credentialStore: InMemoryAuthCredentialStore(),
      config: const AppConfig(
        environment: AppEnvironment.development,
        appName: 'test',
        apiBaseUrl: 'https://api.example.test',
        enableLogging: false,
        enableBusinessProfileSamples: false,
        enableBusinessOfferingSamples: false,
        enableRemoteSearchDiscovery: false,
      ),
    );

    await controller.requestOtp('+998901234567');
    await controller.verifyOtp('000000');

    expect(controller.isSignedIn, isFalse);
    expect(controller.lastFailure?.code, AuthErrorCode.codeIncorrect);
  });

  test('revoking current session returns to guest', () async {
    final controller = AuthController(
      repository: _MockAuthRepository(),
      credentialStore: InMemoryAuthCredentialStore(),
      config: const AppConfig(
        environment: AppEnvironment.development,
        appName: 'test',
        apiBaseUrl: 'https://api.example.test',
        enableLogging: false,
        enableBusinessProfileSamples: false,
        enableBusinessOfferingSamples: false,
        enableRemoteSearchDiscovery: false,
      ),
    );

    await controller.requestOtp('+998901234567');
    await controller.verifyOtp('123456');
    final currentId = controller.sessionId!;
    await controller.revokeOwnedSession(currentId);

    expect(controller.isSignedIn, isFalse);
    expect(controller.status, AuthStatus.guest);
  });

  test('auth failure toString omits secrets', () {
    const failure = AuthFailure(
      code: AuthErrorCode.codeIncorrect,
      message: 'The code 123456 was wrong for token abc',
    );
    expect(failure.toString(), isNot(contains('123456')));
    expect(failure.toString(), isNot(contains('abc')));
  });

  test('invalid refresh token clears signed-in state', () async {
    final store = InMemoryAuthCredentialStore();
    await store.writeRefreshToken('stale-refresh');
    final repo = _MockAuthRepository()..refreshFails = true;
    final controller = AuthController(
      repository: repo,
      credentialStore: store,
      config: const AppConfig(
        environment: AppEnvironment.development,
        appName: 'test',
        apiBaseUrl: 'https://api.example.test',
        enableLogging: false,
        enableBusinessProfileSamples: false,
        enableBusinessOfferingSamples: false,
        enableRemoteSearchDiscovery: false,
      ),
    );

    await controller.tryRefreshAccessToken();

    expect(controller.isSignedIn, isFalse);
    expect(controller.status, AuthStatus.sessionExpired);
  });

  test('duplicate verify calls are ignored while busy', () async {
    final repo = _MockAuthRepository();
    final controller = AuthController(
      repository: repo,
      credentialStore: InMemoryAuthCredentialStore(),
      config: const AppConfig(
        environment: AppEnvironment.development,
        appName: 'test',
        apiBaseUrl: 'https://api.example.test',
        enableLogging: false,
        enableBusinessProfileSamples: false,
        enableBusinessOfferingSamples: false,
        enableRemoteSearchDiscovery: false,
      ),
    );

    await controller.requestOtp('+998901234567');
    controller.busy = true;
    await controller.verifyOtp('123456');
    expect(repo.verifyCalls, 0);
  });
}

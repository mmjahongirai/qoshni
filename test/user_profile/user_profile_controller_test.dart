import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/core/config/app_config.dart';
import 'package:qoshni/core/config/app_environment.dart';
import 'package:qoshni/core/localization/locale_controller.dart';
import 'package:qoshni/features/auth/data/auth_credential_store.dart';
import 'package:qoshni/features/auth/data/auth_dtos.dart';
import 'package:qoshni/features/auth/domain/auth_failure.dart';
import 'package:qoshni/features/auth/domain/auth_repository.dart';
import 'package:qoshni/features/auth/presentation/auth_controller.dart';
import 'package:qoshni/features/user_profile/data/user_profile_dtos.dart';
import 'package:qoshni/features/user_profile/domain/user_profile_failure.dart';
import 'package:qoshni/features/user_profile/domain/user_profile_repository.dart';
import 'package:qoshni/features/user_profile/presentation/user_profile_controller.dart';

const _configured = AppConfig(
  environment: AppEnvironment.development,
  appName: 'test',
  apiBaseUrl: 'https://api.example.test',
  enableLogging: false,
  enableBusinessProfileSamples: false,
  enableBusinessOfferingSamples: false,
  enableRemoteSearchDiscovery: false,
);

class _MockUserProfileRepository implements UserProfileRepository {
  int profileFetches = 0;
  int preferencesFetches = 0;
  UserProfileFailure? fetchFailure;
  UserProfileFailure? updateFailure;
  String? lastDisplayName;
  bool lastClearDisplayName = false;
  PreferredLanguageCode? lastLanguage;
  bool? lastPersonalization;

  @override
  Future<UserProfileViewDto> fetchProfile({required String accessToken}) async {
    profileFetches++;
    if (fetchFailure != null) {
      throw fetchFailure!;
    }
    return UserProfileViewDto(
      profileId: '11111111-1111-1111-1111-111111111111',
      displayName: 'Ada',
      avatarStorageRef: null,
      createdAt: DateTime.utc(2026, 10, 14),
      updatedAt: DateTime.utc(2026, 10, 14),
    );
  }

  @override
  Future<UserPreferencesViewDto> fetchPreferences({
    required String accessToken,
  }) async {
    preferencesFetches++;
    if (fetchFailure != null) {
      throw fetchFailure!;
    }
    return UserPreferencesViewDto(
      preferencesId: '22222222-2222-2222-2222-222222222222',
      preferredLanguage: PreferredLanguageCode.en,
      personalizationEnabled: false,
      createdAt: DateTime.utc(2026, 10, 14),
      updatedAt: DateTime.utc(2026, 10, 14),
    );
  }

  @override
  Future<UserProfileViewDto> updateProfile({
    required String accessToken,
    required UserProfileUpdateRequestDto request,
  }) async {
    if (updateFailure != null) {
      throw updateFailure!;
    }
    lastDisplayName = request.displayName;
    lastClearDisplayName = request.clearDisplayName;
    return UserProfileViewDto(
      profileId: '11111111-1111-1111-1111-111111111111',
      displayName: request.clearDisplayName ? null : request.displayName,
      avatarStorageRef: null,
      createdAt: DateTime.utc(2026, 10, 14),
      updatedAt: DateTime.utc(2026, 10, 14, 1),
    );
  }

  @override
  Future<UserPreferencesViewDto> updatePreferences({
    required String accessToken,
    required UserPreferencesUpdateRequestDto request,
  }) async {
    if (updateFailure != null) {
      throw updateFailure!;
    }
    lastLanguage = request.preferredLanguage;
    lastPersonalization = request.personalizationEnabled;
    return UserPreferencesViewDto(
      preferencesId: '22222222-2222-2222-2222-222222222222',
      preferredLanguage: request.preferredLanguage ?? PreferredLanguageCode.en,
      personalizationEnabled: request.personalizationEnabled ?? false,
      createdAt: DateTime.utc(2026, 10, 14),
      updatedAt: DateTime.utc(2026, 10, 14, 1),
    );
  }
}

class _SigningAuthRepository implements AuthRepository {
  @override
  Future<OtpChallengeCreatedDto> requestOtpChallenge(String phoneE164) async {
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
    return SessionTokensDto(
      tokenType: 'bearer',
      accessToken: 'access-token',
      accessTokenExpiresAt: DateTime.utc(2026, 10, 14, 13),
      refreshToken: 'refresh-token',
      refreshTokenExpiresAt: DateTime.utc(2026, 11, 14),
      userId: '33333333-3333-3333-3333-333333333333',
      session: SessionViewDto(
        sessionId: '44444444-4444-4444-4444-444444444444',
        state: 'active',
        createdAt: DateTime.utc(2026, 10, 14, 12),
        expiresAt: DateTime.utc(2026, 11, 14),
        isCurrent: true,
      ),
    );
  }

  @override
  Future<SessionTokensDto> refreshSession(String refreshToken) async {
    throw const AuthFailure(
      code: AuthErrorCode.sessionInvalid,
      message: 'invalid',
    );
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

Future<({AuthController auth, UserProfileController profile, _MockUserProfileRepository repo})>
    _signedInHarness() async {
  final repo = _MockUserProfileRepository();
  final locale = LocaleController();
  final auth = AuthController(
    repository: _SigningAuthRepository(),
    credentialStore: InMemoryAuthCredentialStore(),
    config: _configured,
  );
  final profile = UserProfileController(
    repository: repo,
    authController: auth,
    localeController: locale,
    config: _configured,
  );
  await auth.requestOtp('+998901234567');
  await auth.verifyOtp('123456');
  await Future<void>.delayed(Duration.zero);
  return (auth: auth, profile: profile, repo: repo);
}

void main() {
  test('guest mode does not call protected profile APIs', () async {
    final repo = _MockUserProfileRepository();
    final auth = AuthController(
      repository: _SigningAuthRepository(),
      credentialStore: InMemoryAuthCredentialStore(),
      config: _configured,
    );
    final controller = UserProfileController(
      repository: repo,
      authController: auth,
      localeController: LocaleController(),
      config: _configured,
    );

    await controller.refresh();

    expect(repo.profileFetches, 0);
    expect(repo.preferencesFetches, 0);
    controller.dispose();
  });

  test('signed-in loads profile and preferences from API', () async {
    final harness = await _signedInHarness();

    expect(harness.repo.profileFetches, greaterThan(0));
    expect(harness.repo.preferencesFetches, greaterThan(0));
    expect(harness.profile.profile?.displayName, 'Ada');
    expect(harness.profile.preferences?.personalizationEnabled, isFalse);
    expect(harness.profile.confirmedPreferredLanguage, PreferredLanguageCode.en);

    harness.profile.dispose();
  });

  test('updates display name and clears using backend contract', () async {
    final harness = await _signedInHarness();

    await harness.profile.updateDisplayName('  Bob  ');
    expect(harness.repo.lastDisplayName, 'Bob');
    expect(harness.profile.profileSaveSucceeded, isTrue);

    await harness.profile.clearDisplayName();
    expect(harness.repo.lastClearDisplayName, isTrue);
    expect(harness.profile.profile?.displayName, isNull);

    harness.profile.dispose();
  });

  test('updates preferred language and personalization opt-in', () async {
    final harness = await _signedInHarness();

    await harness.profile.updatePreferredLanguage(PreferredLanguageCode.ru);
    expect(harness.repo.lastLanguage, PreferredLanguageCode.ru);
    expect(harness.profile.preferencesSaveSucceeded, isTrue);

    await harness.profile.setPersonalizationEnabled(true);
    expect(harness.repo.lastPersonalization, isTrue);
    expect(harness.profile.preferences?.personalizationEnabled, isTrue);

    harness.profile.dispose();
  });

  test('failed preference save reverts locale to confirmed server value', () async {
    final harness = await _signedInHarness();
    final locale = LocaleController();
    final repo = harness.repo..updateFailure = const UserProfileFailure(
          code: UserProfileErrorCode.network,
          message: 'network',
        );
    final controller = UserProfileController(
      repository: repo,
      authController: harness.auth,
      localeController: locale,
      config: _configured,
    );
    await controller.refresh();
    locale.setLocale(const Locale('uz'));

    await controller.updatePreferredLanguage(PreferredLanguageCode.ru);

    expect(controller.preferencesSaveFailure?.code, UserProfileErrorCode.network);
    expect(locale.locale, const Locale('en'));
    expect(controller.preferencesSaveSucceeded, isFalse);

    controller.dispose();
    harness.profile.dispose();
  });

  test('failed profile save never reports success', () async {
    final harness = await _signedInHarness();
    harness.repo.updateFailure = const UserProfileFailure(
      code: UserProfileErrorCode.validationFailed,
      message: 'bad',
    );

    await harness.profile.updateDisplayName('!!!');

    expect(harness.profile.profileSaveSucceeded, isFalse);
    expect(
      harness.profile.profileSaveFailure?.code,
      UserProfileErrorCode.validationFailed,
    );

    harness.profile.dispose();
  });

  test('401 on load triggers session expiry via AuthController', () async {
    final harness = await _signedInHarness();
    harness.repo.fetchFailure = const UserProfileFailure(
      code: UserProfileErrorCode.authenticationRequired,
      message: 'auth',
    );

    await harness.profile.refresh();

    expect(harness.auth.status, AuthStatus.sessionExpired);
    expect(harness.auth.isSignedIn, isFalse);

    harness.profile.dispose();
  });

  test('duplicate profile save ignored while saving', () async {
    final harness = await _signedInHarness();
    var updateCalls = 0;
    final slowRepo = _SlowProfileRepository(onUpdate: () => updateCalls++);
    final controller = UserProfileController(
      repository: slowRepo,
      authController: harness.auth,
      localeController: LocaleController(),
      config: _configured,
    );
    await controller.refresh();

    final first = controller.updateDisplayName('One');
    await controller.updateDisplayName('Two');
    await first;

    expect(updateCalls, 1);
    controller.dispose();
    harness.profile.dispose();
  });
}

class _SlowProfileRepository implements UserProfileRepository {
  _SlowProfileRepository({required this.onUpdate});

  final VoidCallback onUpdate;

  @override
  Future<UserProfileViewDto> fetchProfile({required String accessToken}) async {
    return UserProfileViewDto(
      profileId: '11111111-1111-1111-1111-111111111111',
      displayName: null,
      avatarStorageRef: null,
      createdAt: DateTime.utc(2026, 10, 14),
      updatedAt: DateTime.utc(2026, 10, 14),
    );
  }

  @override
  Future<UserPreferencesViewDto> fetchPreferences({
    required String accessToken,
  }) async {
    return UserPreferencesViewDto(
      preferencesId: '22222222-2222-2222-2222-222222222222',
      preferredLanguage: PreferredLanguageCode.en,
      personalizationEnabled: false,
      createdAt: DateTime.utc(2026, 10, 14),
      updatedAt: DateTime.utc(2026, 10, 14),
    );
  }

  @override
  Future<UserProfileViewDto> updateProfile({
    required String accessToken,
    required UserProfileUpdateRequestDto request,
  }) async {
    onUpdate();
    await Future<void>.delayed(const Duration(milliseconds: 50));
    return UserProfileViewDto(
      profileId: '11111111-1111-1111-1111-111111111111',
      displayName: request.displayName,
      avatarStorageRef: null,
      createdAt: DateTime.utc(2026, 10, 14),
      updatedAt: DateTime.utc(2026, 10, 14, 1),
    );
  }

  @override
  Future<UserPreferencesViewDto> updatePreferences({
    required String accessToken,
    required UserPreferencesUpdateRequestDto request,
  }) async {
    return UserPreferencesViewDto(
      preferencesId: '22222222-2222-2222-2222-222222222222',
      preferredLanguage: PreferredLanguageCode.en,
      personalizationEnabled: false,
      createdAt: DateTime.utc(2026, 10, 14),
      updatedAt: DateTime.utc(2026, 10, 14),
    );
  }
}

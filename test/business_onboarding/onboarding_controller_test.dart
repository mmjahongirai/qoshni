import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/core/config/app_config.dart';
import 'package:qoshni/core/config/app_environment.dart';
import 'package:qoshni/features/auth/data/auth_credential_store.dart';
import 'package:qoshni/features/auth/data/auth_dtos.dart';
import 'package:qoshni/features/auth/domain/auth_failure.dart';
import 'package:qoshni/features/auth/domain/auth_repository.dart';
import 'package:qoshni/features/auth/presentation/auth_controller.dart';
import 'package:qoshni/features/business_onboarding/data/onboarding_dtos.dart';
import 'package:qoshni/features/business_onboarding/domain/onboarding_failure.dart';
import 'package:qoshni/features/business_onboarding/domain/onboarding_repository.dart';
import 'package:qoshni/features/business_onboarding/presentation/onboarding_controller.dart';

const _configured = AppConfig(
  environment: AppEnvironment.development,
  appName: 'test',
  apiBaseUrl: 'https://api.example.test',
  enableLogging: false,
  enableBusinessProfileSamples: false,
  enableBusinessOfferingSamples: false,
  enableRemoteSearchDiscovery: false,
);

const _unconfigured = AppConfig(
  environment: AppEnvironment.development,
  appName: 'test',
  apiBaseUrl: '',
  enableLogging: false,
  enableBusinessProfileSamples: false,
  enableBusinessOfferingSamples: false,
  enableRemoteSearchDiscovery: false,
);

OwnerApplicationViewDto _application({String status = 'draft'}) {
  return OwnerApplicationViewDto(
    applicationId: 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
    legalBusinessName: 'Acme',
    tradeDisplayName: null,
    serviceCategory: 'shops',
    registrationJurisdiction: 'UZ',
    registrationIdentifier: null,
    taxIdentifier: null,
    businessContactEmail: null,
    verificationStatus: status,
    rejectionReasonCode: null,
    submittedAt: null,
    reviewedAt: null,
    createdAt: DateTime.utc(2026, 10, 14),
    updatedAt: DateTime.utc(2026, 10, 14),
  );
}

class _MockOnboardingRepository implements OnboardingRepository {
  int listCalls = 0;
  int submitCalls = 0;
  int uploadCalls = 0;
  OnboardingFailure? failure;
  bool slowUpload = false;

  @override
  Future<OwnerApplicationViewDto> createApplication({
    required String accessToken,
    OnboardingApplicationCreateRequestDto? request,
  }) async {
    if (failure != null) {
      throw failure!;
    }
    return _application();
  }

  @override
  Future<List<OwnerApplicationViewDto>> listApplications({
    required String accessToken,
  }) async {
    listCalls++;
    if (failure != null) {
      throw failure!;
    }
    return [_application()];
  }

  @override
  Future<OwnerApplicationViewDto> fetchApplication({
    required String accessToken,
    required String applicationId,
  }) async {
    if (failure != null) {
      throw failure!;
    }
    return _application();
  }

  @override
  Future<OwnerApplicationViewDto> updateDraft({
    required String accessToken,
    required String applicationId,
    required OnboardingApplicationDraftUpdateRequestDto request,
  }) async {
    if (failure != null) {
      throw failure!;
    }
    return _application();
  }

  @override
  Future<OwnerApplicationViewDto> submitApplication({
    required String accessToken,
    required String applicationId,
  }) async {
    submitCalls++;
    if (failure != null) {
      throw failure!;
    }
    return _application(status: 'submitted');
  }

  @override
  Future<OnboardingVerificationStatusViewDto> fetchVerificationStatus({
    required String accessToken,
    required String applicationId,
  }) async {
    return OnboardingVerificationStatusViewDto(
      applicationId: applicationId,
      verificationStatus: 'draft',
      rejectionReasonCode: null,
      submittedAt: null,
      reviewedAt: null,
      updatedAt: DateTime.utc(2026, 10, 14),
    );
  }

  @override
  Future<OwnerDocumentViewDto> registerDocument({
    required String accessToken,
    required String applicationId,
    required RegisterOnboardingDocumentRequestDto request,
  }) async {
    return OwnerDocumentViewDto(
      documentId: 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
      applicationId: applicationId,
      documentType: request.documentType,
      lifecycleState: 'awaiting_upload',
      createdAt: DateTime.utc(2026, 10, 14),
      updatedAt: DateTime.utc(2026, 10, 14),
    );
  }

  @override
  Future<List<OwnerDocumentViewDto>> listDocuments({
    required String accessToken,
    required String applicationId,
  }) async {
    return const [];
  }

  @override
  Future<OwnerDocumentViewDto> uploadDocument({
    required String accessToken,
    required String applicationId,
    required String documentId,
    required List<int> bytes,
    required String filename,
  }) async {
    uploadCalls++;
    if (slowUpload) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
    if (failure != null) {
      throw failure!;
    }
    return OwnerDocumentViewDto(
      documentId: documentId,
      applicationId: applicationId,
      documentType: 'registration_certificate',
      lifecycleState: 'uploaded_pending_validation',
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

Future<AuthController> _signedInAuth() async {
  final auth = AuthController(
    repository: _SigningAuthRepository(),
    credentialStore: InMemoryAuthCredentialStore(),
    config: _configured,
  );
  await auth.requestOtp('+998901234567');
  await auth.verifyOtp('123456');
  await Future<void>.delayed(Duration.zero);
  return auth;
}

void main() {
  test('guest refresh sets authenticationRequired', () async {
    final repo = _MockOnboardingRepository();
    final controller = OnboardingController(
      repository: repo,
      authController: AuthController(
        repository: _SigningAuthRepository(),
        credentialStore: InMemoryAuthCredentialStore(),
        config: _configured,
      ),
      config: _configured,
    );

    await controller.refreshApplications();
    expect(repo.listCalls, 0);
    expect(
      controller.lastFailure?.code,
      OnboardingErrorCode.authenticationRequired,
    );
  });

  test('submit blocks duplicate while in flight', () async {
    final repo = _MockOnboardingRepository()..slowUpload = false;
    final auth = await _signedInAuth();
    final controller = OnboardingController(
      repository: repo,
      authController: auth,
      config: _configured,
    );

    final first = controller.submitApplication(
      'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
    );
    final second = controller.submitApplication(
      'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
    );
    await first;
    await second;
    expect(repo.submitCalls, 1);
  });

  test('upload rejects oversize file before repository', () async {
    final repo = _MockOnboardingRepository();
    final auth = await _signedInAuth();
    final controller = OnboardingController(
      repository: repo,
      authController: auth,
      config: _configured,
    );

    final ok = await controller.uploadDocument(
      applicationId: 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
      documentId: 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
      bytes: List.filled(onboardingMaxUploadBytes + 1, 0),
      filename: 'big.pdf',
    );
    expect(ok, isFalse);
    expect(repo.uploadCalls, 0);
    expect(controller.lastFailure?.code, OnboardingErrorCode.validationFailed);
  });

  test('api not configured short-circuits list', () async {
    final repo = _MockOnboardingRepository();
    final auth = await _signedInAuth();
    final controller = OnboardingController(
      repository: repo,
      authController: auth,
      config: _unconfigured,
    );

    await controller.refreshApplications();
    expect(repo.listCalls, 0);
    expect(
      controller.lastFailure?.code,
      OnboardingErrorCode.apiNotConfigured,
    );
  });
}

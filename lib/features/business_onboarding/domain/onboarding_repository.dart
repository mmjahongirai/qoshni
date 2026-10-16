import 'package:qoshni/features/business_onboarding/data/onboarding_dtos.dart';

/// Owner-scoped business onboarding API (KYC registration).
abstract class OnboardingRepository {
  Future<OwnerApplicationViewDto> createApplication({
    required String accessToken,
    OnboardingApplicationCreateRequestDto? request,
  });

  Future<List<OwnerApplicationViewDto>> listApplications({
    required String accessToken,
  });

  Future<OwnerApplicationViewDto> fetchApplication({
    required String accessToken,
    required String applicationId,
  });

  Future<OwnerApplicationViewDto> updateDraft({
    required String accessToken,
    required String applicationId,
    required OnboardingApplicationDraftUpdateRequestDto request,
  });

  Future<OwnerApplicationViewDto> submitApplication({
    required String accessToken,
    required String applicationId,
  });

  Future<OnboardingVerificationStatusViewDto> fetchVerificationStatus({
    required String accessToken,
    required String applicationId,
  });

  Future<OwnerDocumentViewDto> registerDocument({
    required String accessToken,
    required String applicationId,
    required RegisterOnboardingDocumentRequestDto request,
  });

  Future<List<OwnerDocumentViewDto>> listDocuments({
    required String accessToken,
    required String applicationId,
  });

  Future<OwnerDocumentViewDto> uploadDocument({
    required String accessToken,
    required String applicationId,
    required String documentId,
    required List<int> bytes,
    required String filename,
  });
}

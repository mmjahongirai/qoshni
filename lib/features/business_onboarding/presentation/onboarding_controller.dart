import 'package:flutter/foundation.dart';
import 'package:qoshni/core/config/app_config.dart';
import 'package:qoshni/features/auth/presentation/auth_controller.dart';
import 'package:qoshni/features/business_onboarding/data/onboarding_dtos.dart';
import 'package:qoshni/features/business_onboarding/domain/onboarding_failure.dart';
import 'package:qoshni/features/business_onboarding/domain/onboarding_repository.dart';

enum OnboardingLoadState { idle, loading, ready, error }

/// Owner onboarding applications, documents, and verification state.
class OnboardingController extends ChangeNotifier {
  OnboardingController({
    required OnboardingRepository repository,
    required AuthController authController,
    required AppConfig config,
  })  : _repository = repository,
        _authController = authController,
        _config = config;

  final OnboardingRepository _repository;
  final AuthController _authController;
  final AppConfig _config;

  OnboardingLoadState listState = OnboardingLoadState.idle;
  List<OwnerApplicationViewDto> applications = const [];
  OwnerApplicationViewDto? selectedApplication;
  OnboardingVerificationStatusViewDto? verificationStatus;
  List<OwnerDocumentViewDto> documents = const [];
  OnboardingFailure? lastFailure;

  bool listBusy = false;
  bool detailBusy = false;
  bool saveBusy = false;
  bool submitBusy = false;
  bool documentsBusy = false;
  String? uploadingDocumentId;

  String? _requireToken() {
    if (!_config.apiConfigured) {
      lastFailure = const OnboardingFailure(
        code: OnboardingErrorCode.apiNotConfigured,
        message: 'API not configured',
      );
      return null;
    }
    if (!_authController.isSignedIn) {
      lastFailure = const OnboardingFailure(
        code: OnboardingErrorCode.authenticationRequired,
        message: 'Sign in required',
      );
      return null;
    }
    final token = _authController.accessToken;
    if (token == null || token.isEmpty) {
      lastFailure = const OnboardingFailure(
        code: OnboardingErrorCode.authenticationRequired,
        message: 'Sign in required',
      );
      return null;
    }
    return token;
  }

  Future<void> refreshApplications() async {
    final token = _requireToken();
    if (token == null) {
      notifyListeners();
      return;
    }
    if (listBusy) {
      return;
    }
    listBusy = true;
    listState = OnboardingLoadState.loading;
    lastFailure = null;
    notifyListeners();
    try {
      applications = await _repository.listApplications(accessToken: token);
      listState = OnboardingLoadState.ready;
    } on OnboardingFailure catch (failure) {
      lastFailure = failure;
      listState = OnboardingLoadState.error;
    } finally {
      listBusy = false;
      notifyListeners();
    }
  }

  Future<OwnerApplicationViewDto?> createApplication({
    OnboardingApplicationCreateRequestDto? seed,
  }) async {
    final token = _requireToken();
    if (token == null) {
      notifyListeners();
      return null;
    }
    if (saveBusy) {
      return null;
    }
    saveBusy = true;
    lastFailure = null;
    notifyListeners();
    try {
      final created = await _repository.createApplication(
        accessToken: token,
        request: seed ??
            const OnboardingApplicationCreateRequestDto(
              registrationJurisdiction: 'UZ',
            ),
      );
      selectedApplication = created;
      await refreshApplications();
      return created;
    } on OnboardingFailure catch (failure) {
      lastFailure = failure;
      return null;
    } finally {
      saveBusy = false;
      notifyListeners();
    }
  }

  Future<void> loadApplicationDetail(String applicationId) async {
    final token = _requireToken();
    if (token == null) {
      notifyListeners();
      return;
    }
    if (detailBusy) {
      return;
    }
    detailBusy = true;
    lastFailure = null;
    notifyListeners();
    try {
      selectedApplication = await _repository.fetchApplication(
        accessToken: token,
        applicationId: applicationId,
      );
      verificationStatus = await _repository.fetchVerificationStatus(
        accessToken: token,
        applicationId: applicationId,
      );
      documents = await _repository.listDocuments(
        accessToken: token,
        applicationId: applicationId,
      );
    } on OnboardingFailure catch (failure) {
      lastFailure = failure;
    } finally {
      detailBusy = false;
      notifyListeners();
    }
  }

  Future<bool> saveDraft({
    required String applicationId,
    required OnboardingApplicationDraftUpdateRequestDto request,
  }) async {
    final token = _requireToken();
    if (token == null) {
      notifyListeners();
      return false;
    }
    if (saveBusy) {
      return false;
    }
    saveBusy = true;
    lastFailure = null;
    notifyListeners();
    try {
      selectedApplication = await _repository.updateDraft(
        accessToken: token,
        applicationId: applicationId,
        request: request,
      );
      await refreshApplications();
      return true;
    } on OnboardingFailure catch (failure) {
      lastFailure = failure;
      return false;
    } finally {
      saveBusy = false;
      notifyListeners();
    }
  }

  Future<bool> submitApplication(String applicationId) async {
    final token = _requireToken();
    if (token == null) {
      notifyListeners();
      return false;
    }
    if (submitBusy) {
      return false;
    }
    submitBusy = true;
    lastFailure = null;
    notifyListeners();
    try {
      selectedApplication = await _repository.submitApplication(
        accessToken: token,
        applicationId: applicationId,
      );
      verificationStatus = await _repository.fetchVerificationStatus(
        accessToken: token,
        applicationId: applicationId,
      );
      await refreshApplications();
      return true;
    } on OnboardingFailure catch (failure) {
      lastFailure = failure;
      return false;
    } finally {
      submitBusy = false;
      notifyListeners();
    }
  }

  Future<bool> registerDocument({
    required String applicationId,
    required String documentType,
  }) async {
    final token = _requireToken();
    if (token == null) {
      notifyListeners();
      return false;
    }
    if (documentsBusy) {
      return false;
    }
    documentsBusy = true;
    lastFailure = null;
    notifyListeners();
    try {
      await _repository.registerDocument(
        accessToken: token,
        applicationId: applicationId,
        request: RegisterOnboardingDocumentRequestDto(
          documentType: documentType,
        ),
      );
      documents = await _repository.listDocuments(
        accessToken: token,
        applicationId: applicationId,
      );
      return true;
    } on OnboardingFailure catch (failure) {
      lastFailure = failure;
      return false;
    } finally {
      documentsBusy = false;
      notifyListeners();
    }
  }

  Future<bool> uploadDocument({
    required String applicationId,
    required String documentId,
    required List<int> bytes,
    required String filename,
  }) async {
    if (bytes.length > onboardingMaxUploadBytes) {
      lastFailure = const OnboardingFailure(
        code: OnboardingErrorCode.validationFailed,
        message: 'File exceeds the maximum allowed size.',
      );
      notifyListeners();
      return false;
    }
    final token = _requireToken();
    if (token == null) {
      notifyListeners();
      return false;
    }
    if (uploadingDocumentId != null) {
      return false;
    }
    uploadingDocumentId = documentId;
    lastFailure = null;
    notifyListeners();
    try {
      await _repository.uploadDocument(
        accessToken: token,
        applicationId: applicationId,
        documentId: documentId,
        bytes: bytes,
        filename: filename,
      );
      documents = await _repository.listDocuments(
        accessToken: token,
        applicationId: applicationId,
      );
      verificationStatus = await _repository.fetchVerificationStatus(
        accessToken: token,
        applicationId: applicationId,
      );
      return true;
    } on OnboardingFailure catch (failure) {
      lastFailure = failure;
      return false;
    } finally {
      uploadingDocumentId = null;
      notifyListeners();
    }
  }
}

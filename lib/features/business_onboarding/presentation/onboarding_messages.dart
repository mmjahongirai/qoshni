import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/features/business_onboarding/domain/onboarding_failure.dart';

String onboardingFailureMessage(AppLocalizations l10n, OnboardingFailure failure) {
  return switch (failure.code) {
    OnboardingErrorCode.applicationNotFound => l10n.onboardingErrorNotFound,
    OnboardingErrorCode.forbidden => l10n.onboardingErrorForbidden,
    OnboardingErrorCode.invalidStatusTransition =>
      l10n.onboardingErrorInvalidTransition,
    OnboardingErrorCode.validationFailed => failure.message.isNotEmpty
        ? failure.message
        : l10n.onboardingErrorValidation,
    OnboardingErrorCode.storageUnavailable => l10n.onboardingErrorUnavailable,
    OnboardingErrorCode.malwareScanUnavailable => l10n.onboardingErrorScanUnavailable,
    OnboardingErrorCode.documentRejected => l10n.onboardingErrorDocumentRejected,
    OnboardingErrorCode.suspended => l10n.onboardingErrorSuspended,
    OnboardingErrorCode.authenticationRequired => l10n.onboardingErrorSignInRequired,
    OnboardingErrorCode.apiNotConfigured => l10n.onboardingErrorApiNotConfigured,
    OnboardingErrorCode.network => l10n.onboardingErrorNetwork,
    OnboardingErrorCode.malformedResponse => l10n.onboardingErrorUnexpected,
    OnboardingErrorCode.unknown => l10n.onboardingErrorUnexpected,
  };
}

String onboardingStatusLabel(AppLocalizations l10n, String status) {
  return switch (status) {
    'draft' => l10n.onboardingStatusDraft,
    'submitted' => l10n.onboardingStatusSubmitted,
    'under_review' => l10n.onboardingStatusUnderReview,
    'verified' => l10n.onboardingStatusVerified,
    'rejected' => l10n.onboardingStatusRejected,
    'suspended' => l10n.onboardingStatusSuspended,
    _ => status,
  };
}

String onboardingDocumentLifecycleLabel(AppLocalizations l10n, String state) {
  return switch (state) {
    'awaiting_upload' => l10n.onboardingDocAwaitingUpload,
    'uploaded_pending_validation' => l10n.onboardingDocUploadedPending,
    'quarantined' => l10n.onboardingDocQuarantined,
    'rejected' => l10n.onboardingDocRejected,
    'accepted_for_review' => l10n.onboardingDocAcceptedForReview,
    'deleted' => l10n.onboardingDocDeleted,
    _ => state,
  };
}

String onboardingRejectionLabel(AppLocalizations l10n, String code) {
  return switch (code) {
    'incomplete_information' => l10n.onboardingRejectionIncomplete,
    'registration_mismatch' => l10n.onboardingRejectionMismatch,
    'jurisdiction_unsupported' => l10n.onboardingRejectionJurisdiction,
    'policy_violation' => l10n.onboardingRejectionPolicy,
    'other' => l10n.onboardingRejectionOther,
    _ => code,
  };
}

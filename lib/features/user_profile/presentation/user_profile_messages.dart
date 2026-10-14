import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/features/user_profile/domain/user_profile_failure.dart';

String localizedUserProfileFailure(
  AppLocalizations l10n,
  UserProfileFailure failure,
) {
  return switch (failure.code) {
    UserProfileErrorCode.apiNotConfigured => l10n.userProfileApiNotConfigured,
    UserProfileErrorCode.network => l10n.userProfileErrorNetwork,
    UserProfileErrorCode.serviceUnavailable =>
      l10n.userProfileErrorServiceUnavailable,
    UserProfileErrorCode.profileNotFound => l10n.userProfileNotFound,
    UserProfileErrorCode.preferencesNotFound =>
      l10n.userProfilePreferencesNotFound,
    UserProfileErrorCode.validationFailed => l10n.userProfileErrorValidation,
    UserProfileErrorCode.authenticationRequired ||
    UserProfileErrorCode.sessionInvalid ||
    UserProfileErrorCode.accountUnavailable =>
      l10n.authSessionExpiredNotice,
    UserProfileErrorCode.malformedResponse ||
    UserProfileErrorCode.unknown =>
      l10n.userProfileErrorGeneric,
  };
}

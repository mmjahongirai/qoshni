import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qoshni/core/config/app_config.dart';
import 'package:qoshni/core/localization/locale_controller.dart';
import 'package:qoshni/features/auth/domain/auth_failure.dart';
import 'package:qoshni/features/auth/presentation/auth_controller.dart';
import 'package:qoshni/features/user_profile/data/user_profile_dtos.dart';
import 'package:qoshni/features/user_profile/domain/user_profile_failure.dart';
import 'package:qoshni/features/user_profile/domain/user_profile_repository.dart';

/// Loads and saves the signed-in user's profile and preferences.
class UserProfileController extends ChangeNotifier {
  UserProfileController({
    required UserProfileRepository repository,
    required AuthController authController,
    required LocaleController localeController,
    required AppConfig config,
  })  : _repository = repository,
        _authController = authController,
        _localeController = localeController,
        _config = config {
    _authController.addListener(_onAuthChanged);
    _onAuthChanged();
  }

  final UserProfileRepository _repository;
  final AuthController _authController;
  final LocaleController _localeController;
  final AppConfig _config;

  UserProfileViewDto? profile;
  UserPreferencesViewDto? preferences;
  PreferredLanguageCode? _confirmedPreferredLanguage;

  bool loading = false;
  bool savingProfile = false;
  bool savingPreferences = false;
  bool profileSaveSucceeded = false;
  bool preferencesSaveSucceeded = false;

  UserProfileFailure? loadFailure;
  UserProfileFailure? profileSaveFailure;
  UserProfileFailure? preferencesSaveFailure;

  bool get apiConfigured => _config.apiConfigured;

  PreferredLanguageCode? get confirmedPreferredLanguage =>
      _confirmedPreferredLanguage;

  @override
  void dispose() {
    _authController.removeListener(_onAuthChanged);
    super.dispose();
  }

  void _onAuthChanged() {
    if (_authController.isSignedIn) {
      unawaited(refresh());
    } else {
      _clearState();
      notifyListeners();
    }
  }

  void _clearState() {
    profile = null;
    preferences = null;
    _confirmedPreferredLanguage = null;
    loading = false;
    savingProfile = false;
    savingPreferences = false;
    profileSaveSucceeded = false;
    preferencesSaveSucceeded = false;
    loadFailure = null;
    profileSaveFailure = null;
    preferencesSaveFailure = null;
  }

  Future<void> refresh() async {
    if (!_authController.isSignedIn) {
      return;
    }
    final token = _authController.accessToken;
    if (token == null || token.isEmpty) {
      return;
    }
    if (!_config.apiConfigured) {
      loadFailure = const UserProfileFailure(
        code: UserProfileErrorCode.apiNotConfigured,
        message: 'API not configured',
      );
      notifyListeners();
      return;
    }
    loading = true;
    loadFailure = null;
    profileSaveSucceeded = false;
    preferencesSaveSucceeded = false;
    notifyListeners();
    try {
      final results = await Future.wait([
        _repository.fetchProfile(accessToken: token),
        _repository.fetchPreferences(accessToken: token),
      ]);
      profile = results[0] as UserProfileViewDto;
      preferences = results[1] as UserPreferencesViewDto;
      _applyConfirmedPreferences(preferences!);
    } on UserProfileFailure catch (failure) {
      loadFailure = failure;
      await _handleFailure(failure);
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  void _applyConfirmedPreferences(UserPreferencesViewDto prefs) {
    _confirmedPreferredLanguage = prefs.preferredLanguage;
    _localeController.setLocale(_localeForCode(prefs.preferredLanguage));
  }

  Future<void> updateDisplayName(String rawName) async {
    final trimmed = rawName.trim();
    if (trimmed.isEmpty || savingProfile) {
      return;
    }
    await _saveProfile(
      UserProfileUpdateRequestDto(displayName: trimmed),
    );
  }

  Future<void> clearDisplayName() async {
    if (savingProfile) {
      return;
    }
    await _saveProfile(
      const UserProfileUpdateRequestDto(clearDisplayName: true),
    );
  }

  Future<void> _saveProfile(UserProfileUpdateRequestDto request) async {
    final token = _accessTokenOrReturn();
    if (token == null) {
      return;
    }
    savingProfile = true;
    profileSaveFailure = null;
    profileSaveSucceeded = false;
    notifyListeners();
    try {
      profile = await _repository.updateProfile(
        accessToken: token,
        request: request,
      );
      profileSaveSucceeded = true;
    } on UserProfileFailure catch (failure) {
      profileSaveFailure = failure;
      await _handleFailure(failure);
    } finally {
      savingProfile = false;
      notifyListeners();
    }
  }

  Future<void> updatePreferredLanguage(PreferredLanguageCode language) async {
    if (savingPreferences) {
      return;
    }
    final previousLocale = _localeController.locale;
    final previousConfirmed = _confirmedPreferredLanguage;
    _localeController.setLocale(_localeForCode(language));
    await _savePreferences(
      UserPreferencesUpdateRequestDto(preferredLanguage: language),
      onFailure: () {
        _confirmedPreferredLanguage = previousConfirmed;
        if (previousConfirmed != null) {
          _localeController.setLocale(_localeForCode(previousConfirmed));
        } else {
          _localeController.setLocale(previousLocale);
        }
      },
    );
  }

  Future<void> setPersonalizationEnabled(bool enabled) async {
    if (savingPreferences) {
      return;
    }
    final previous = preferences?.personalizationEnabled ?? false;
    if (preferences != null) {
      preferences = UserPreferencesViewDto(
        preferencesId: preferences!.preferencesId,
        preferredLanguage: preferences!.preferredLanguage,
        personalizationEnabled: enabled,
        createdAt: preferences!.createdAt,
        updatedAt: preferences!.updatedAt,
      );
      notifyListeners();
    }
    await _savePreferences(
      UserPreferencesUpdateRequestDto(personalizationEnabled: enabled),
      onFailure: () {
        if (preferences != null) {
          preferences = UserPreferencesViewDto(
            preferencesId: preferences!.preferencesId,
            preferredLanguage: preferences!.preferredLanguage,
            personalizationEnabled: previous,
            createdAt: preferences!.createdAt,
            updatedAt: preferences!.updatedAt,
          );
        }
      },
    );
  }

  Future<void> _savePreferences(
    UserPreferencesUpdateRequestDto request, {
    VoidCallback? onFailure,
  }) async {
    final token = _accessTokenOrReturn();
    if (token == null) {
      return;
    }
    savingPreferences = true;
    preferencesSaveFailure = null;
    preferencesSaveSucceeded = false;
    notifyListeners();
    try {
      final updated = await _repository.updatePreferences(
        accessToken: token,
        request: request,
      );
      preferences = updated;
      _confirmedPreferredLanguage = updated.preferredLanguage;
      preferencesSaveSucceeded = true;
    } on UserProfileFailure catch (failure) {
      preferencesSaveFailure = failure;
      onFailure?.call();
      await _handleFailure(failure);
    } finally {
      savingPreferences = false;
      notifyListeners();
    }
  }

  String? _accessTokenOrReturn() {
    if (!_authController.isSignedIn) {
      return null;
    }
    if (!_config.apiConfigured) {
      preferencesSaveFailure = const UserProfileFailure(
        code: UserProfileErrorCode.apiNotConfigured,
        message: 'API not configured',
      );
      profileSaveFailure = preferencesSaveFailure;
      notifyListeners();
      return null;
    }
    return _authController.accessToken;
  }

  Future<void> _handleFailure(UserProfileFailure failure) async {
    if (!failure.code.isSessionFailure) {
      return;
    }
    await _authController.reportAuthenticatedRequestFailure(
      AuthFailure(code: _authCode(failure.code), message: failure.message),
    );
  }

  AuthErrorCode _authCode(UserProfileErrorCode code) {
    return switch (code) {
      UserProfileErrorCode.authenticationRequired =>
        AuthErrorCode.authenticationRequired,
      UserProfileErrorCode.sessionInvalid => AuthErrorCode.sessionInvalid,
      UserProfileErrorCode.accountUnavailable =>
        AuthErrorCode.accountUnavailable,
      _ => AuthErrorCode.unknown,
    };
  }

  static Locale _localeForCode(PreferredLanguageCode code) {
    return Locale(code.apiValue);
  }
}

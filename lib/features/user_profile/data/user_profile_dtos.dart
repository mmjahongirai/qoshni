import 'package:qoshni/features/user_profile/domain/user_profile_failure.dart';

/// Supported backend locale codes (`SupportedLocale` in Python).
enum PreferredLanguageCode {
  uz('uz'),
  ru('ru'),
  en('en');

  const PreferredLanguageCode(this.apiValue);

  final String apiValue;

  static PreferredLanguageCode? tryParse(String? raw) {
    if (raw == null || raw.isEmpty) {
      return null;
    }
    for (final code in PreferredLanguageCode.values) {
      if (code.apiValue == raw) {
        return code;
      }
    }
    return null;
  }
}

class UserProfileViewDto {
  UserProfileViewDto({
    required this.profileId,
    required this.displayName,
    required this.avatarStorageRef,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfileViewDto.fromJson(Map<String, dynamic> json) {
    return UserProfileViewDto(
      profileId: json['profile_id'] as String,
      displayName: json['display_name'] as String?,
      avatarStorageRef: json['avatar_storage_ref'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  final String profileId;
  final String? displayName;
  final String? avatarStorageRef;
  final DateTime createdAt;
  final DateTime updatedAt;
}

class UserProfileUpdateRequestDto {
  const UserProfileUpdateRequestDto({
    this.displayName,
    this.clearDisplayName = false,
  });

  final String? displayName;
  final bool clearDisplayName;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (displayName != null) {
      map['display_name'] = displayName;
    }
    if (clearDisplayName) {
      map['clear_display_name'] = true;
    }
    return map;
  }
}

class UserPreferencesViewDto {
  UserPreferencesViewDto({
    required this.preferencesId,
    required this.preferredLanguage,
    required this.personalizationEnabled,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserPreferencesViewDto.fromJson(Map<String, dynamic> json) {
    final language = PreferredLanguageCode.tryParse(
      json['preferred_language'] as String?,
    );
    if (language == null) {
      throw const UserProfileFailure(
        code: UserProfileErrorCode.malformedResponse,
        message: 'Unexpected preferred_language.',
      );
    }
    return UserPreferencesViewDto(
      preferencesId: json['preferences_id'] as String,
      preferredLanguage: language,
      personalizationEnabled: json['personalization_enabled'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  final String preferencesId;
  final PreferredLanguageCode preferredLanguage;
  final bool personalizationEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;
}

class UserPreferencesUpdateRequestDto {
  const UserPreferencesUpdateRequestDto({
    this.preferredLanguage,
    this.personalizationEnabled,
  });

  final PreferredLanguageCode? preferredLanguage;
  final bool? personalizationEnabled;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (preferredLanguage != null) {
      map['preferred_language'] = preferredLanguage!.apiValue;
    }
    if (personalizationEnabled != null) {
      map['personalization_enabled'] = personalizationEnabled;
    }
    return map;
  }
}

class UserProfileErrorEnvelopeDto {
  UserProfileErrorEnvelopeDto({
    required this.code,
    required this.message,
  });

  factory UserProfileErrorEnvelopeDto.fromJson(Map<String, dynamic> json) {
    final error = json['error'] as Map<String, dynamic>;
    return UserProfileErrorEnvelopeDto(
      code: error['code'] as String,
      message: error['message'] as String,
    );
  }

  UserProfileFailure toFailure() {
    return UserProfileFailure(
      code: UserProfileErrorCode.tryParse(code) ??
          UserProfileErrorCode.unknown,
      message: message,
    );
  }

  final String code;
  final String message;
}

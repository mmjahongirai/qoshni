import 'package:qoshni/features/user_profile/data/user_profile_dtos.dart';

abstract class UserProfileRepository {
  Future<UserProfileViewDto> fetchProfile({required String accessToken});

  Future<UserProfileViewDto> updateProfile({
    required String accessToken,
    required UserProfileUpdateRequestDto request,
  });

  Future<UserPreferencesViewDto> fetchPreferences({
    required String accessToken,
  });

  Future<UserPreferencesViewDto> updatePreferences({
    required String accessToken,
    required UserPreferencesUpdateRequestDto request,
  });
}

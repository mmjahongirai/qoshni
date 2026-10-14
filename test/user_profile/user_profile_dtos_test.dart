import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/features/user_profile/data/user_profile_dtos.dart';
import 'package:qoshni/features/user_profile/domain/user_profile_failure.dart';

void main() {
  group('UserProfileViewDto', () {
    test('parses profile response', () {
      final dto = UserProfileViewDto.fromJson({
        'profile_id': '11111111-1111-1111-1111-111111111111',
        'display_name': 'Ada',
        'avatar_storage_ref': null,
        'created_at': '2026-10-14T12:00:00Z',
        'updated_at': '2026-10-14T12:05:00Z',
      });

      expect(dto.displayName, 'Ada');
      expect(dto.avatarStorageRef, isNull);
    });
  });

  group('UserProfileUpdateRequestDto', () {
    test('serializes display name patch', () {
      const dto = UserProfileUpdateRequestDto(displayName: 'Ada');
      expect(dto.toJson(), {'display_name': 'Ada'});
    });

    test('serializes clear_display_name contract', () {
      const dto = UserProfileUpdateRequestDto(clearDisplayName: true);
      expect(dto.toJson(), {'clear_display_name': true});
    });
  });

  group('UserPreferencesViewDto', () {
    test('parses preferences with default personalization off', () {
      final dto = UserPreferencesViewDto.fromJson({
        'preferences_id': '22222222-2222-2222-2222-222222222222',
        'preferred_language': 'en',
        'personalization_enabled': false,
        'created_at': '2026-10-14T12:00:00Z',
        'updated_at': '2026-10-14T12:00:00Z',
      });

      expect(dto.preferredLanguage, PreferredLanguageCode.en);
      expect(dto.personalizationEnabled, isFalse);
    });

    test('rejects unsupported language', () {
      expect(
        () => UserPreferencesViewDto.fromJson({
          'preferences_id': '22222222-2222-2222-2222-222222222222',
          'preferred_language': 'fr',
          'personalization_enabled': false,
          'created_at': '2026-10-14T12:00:00Z',
          'updated_at': '2026-10-14T12:00:00Z',
        }),
        throwsA(isA<UserProfileFailure>()),
      );
    });
  });

  group('UserPreferencesUpdateRequestDto', () {
    test('serializes language and personalization patches', () {
      const dto = UserPreferencesUpdateRequestDto(
        preferredLanguage: PreferredLanguageCode.uz,
        personalizationEnabled: true,
      );
      expect(
        dto.toJson(),
        {
          'preferred_language': 'uz',
          'personalization_enabled': true,
        },
      );
    });
  });

  group('UserProfileErrorEnvelopeDto', () {
    test('maps profile_not_found', () {
      final failure = UserProfileErrorEnvelopeDto.fromJson({
        'error': {
          'code': 'profile_not_found',
          'message': 'Profile missing',
        },
      }).toFailure();

      expect(failure.code, UserProfileErrorCode.profileNotFound);
    });
  });
}

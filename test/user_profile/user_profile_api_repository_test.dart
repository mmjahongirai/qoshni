import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/core/config/app_config.dart';
import 'package:qoshni/core/config/app_environment.dart';
import 'package:qoshni/core/logging/app_logger.dart';
import 'package:qoshni/core/network/api_client.dart';
import 'package:qoshni/features/user_profile/data/user_profile_api_repository.dart';
import 'package:qoshni/features/user_profile/data/user_profile_dtos.dart';
import 'package:qoshni/features/user_profile/domain/user_profile_failure.dart';

const _config = AppConfig(
  environment: AppEnvironment.development,
  appName: 'test',
  apiBaseUrl: 'https://api.example.test',
  enableLogging: false,
  enableBusinessProfileSamples: false,
  enableBusinessOfferingSamples: false,
  enableRemoteSearchDiscovery: false,
);

const _profileJson = {
  'profile_id': '11111111-1111-1111-1111-111111111111',
  'display_name': 'Ada',
  'avatar_storage_ref': null,
  'created_at': '2026-10-14T12:00:00Z',
  'updated_at': '2026-10-14T12:05:00Z',
};

const _preferencesJson = {
  'preferences_id': '22222222-2222-2222-2222-222222222222',
  'preferred_language': 'en',
  'personalization_enabled': false,
  'created_at': '2026-10-14T12:00:00Z',
  'updated_at': '2026-10-14T12:00:00Z',
};

UserProfileApiRepository _repository(Dio dio) {
  return UserProfileApiRepository(
    apiClient: ApiClient(
      config: _config,
      logger: AppLogger(_config),
      dio: dio,
    ),
    config: _config,
  );
}

void main() {
  test('GET /api/v1/me/profile uses bearer auth', () async {
    String? authHeader;
    final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test'));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          authHeader = options.headers['Authorization'] as String?;
          handler.resolve(
            Response<Map<String, dynamic>>(
              requestOptions: options,
              statusCode: 200,
              data: _profileJson,
            ),
          );
        },
      ),
    );

    final repo = _repository(dio);
    await repo.fetchProfile(accessToken: 'secret-token');

    expect(authHeader, 'Bearer secret-token');
    expect(
      dio.options.baseUrl,
      isNot(contains('user_id')),
    );
  });

  test('PATCH profile sends display_name payload', () async {
    Map<String, dynamic>? body;
    String? path;
    final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test'));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          path = options.path;
          body = options.data as Map<String, dynamic>?;
          handler.resolve(
            Response<Map<String, dynamic>>(
              requestOptions: options,
              statusCode: 200,
              data: {..._profileJson, 'display_name': 'Updated'},
            ),
          );
        },
      ),
    );

    final repo = _repository(dio);
    final result = await repo.updateProfile(
      accessToken: 'token',
      request: const UserProfileUpdateRequestDto(displayName: 'Updated'),
    );

    expect(path, '/api/v1/me/profile');
    expect(body, {'display_name': 'Updated'});
    expect(result.displayName, 'Updated');
  });

  test('PATCH profile clear_display_name payload', () async {
    Map<String, dynamic>? body;
    final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test'));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          body = options.data as Map<String, dynamic>?;
          handler.resolve(
            Response<Map<String, dynamic>>(
              requestOptions: options,
              statusCode: 200,
              data: {..._profileJson, 'display_name': null},
            ),
          );
        },
      ),
    );

    await _repository(dio).updateProfile(
      accessToken: 'token',
      request: const UserProfileUpdateRequestDto(clearDisplayName: true),
    );

    expect(body, {'clear_display_name': true});
  });

  test('GET preferences path and PATCH language', () async {
    final paths = <String>[];
    final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test'));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          paths.add(options.path);
          final isPatch = options.method == 'PATCH';
          handler.resolve(
            Response<Map<String, dynamic>>(
              requestOptions: options,
              statusCode: 200,
              data: isPatch
                  ? {..._preferencesJson, 'preferred_language': 'ru'}
                  : _preferencesJson,
            ),
          );
        },
      ),
    );

    final repo = _repository(dio);
    await repo.fetchPreferences(accessToken: 'token');
    await repo.updatePreferences(
      accessToken: 'token',
      request: const UserPreferencesUpdateRequestDto(
        preferredLanguage: PreferredLanguageCode.ru,
      ),
    );

    expect(paths, [
      '/api/v1/me/preferences',
      '/api/v1/me/preferences',
    ]);
  });

  test('maps 404 profile_not_found', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test'));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.reject(
            DioException(
              requestOptions: options,
              response: Response<Map<String, dynamic>>(
                requestOptions: options,
                statusCode: 404,
                data: {
                  'error': {
                    'code': 'profile_not_found',
                    'message': 'missing',
                  },
                },
              ),
              type: DioExceptionType.badResponse,
            ),
          );
        },
      ),
    );

    await expectLater(
      _repository(dio).fetchProfile(accessToken: 'token'),
      throwsA(
        isA<UserProfileFailure>().having(
          (e) => e.code,
          'code',
          UserProfileErrorCode.profileNotFound,
        ),
      ),
    );
  });

  test('maps network, 401, 422 and 503', () async {
    Future<UserProfileFailure> failureFor(int status, {Map<String, dynamic>? data}) async {
      final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test'));
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            if (status == 0) {
              handler.reject(
                DioException(
                  requestOptions: options,
                  type: DioExceptionType.connectionError,
                ),
              );
              return;
            }
            handler.reject(
              DioException(
                requestOptions: options,
                response: Response<Map<String, dynamic>>(
                  requestOptions: options,
                  statusCode: status,
                  data: data,
                ),
                type: DioExceptionType.badResponse,
              ),
            );
          },
        ),
      );
      try {
        await _repository(dio).fetchProfile(accessToken: 'token');
        fail('expected throw');
      } on UserProfileFailure catch (e) {
        return e;
      }
    }

    expect(
      (await failureFor(0)).code,
      UserProfileErrorCode.network,
    );
    expect(
      (await failureFor(401)).code,
      UserProfileErrorCode.authenticationRequired,
    );
    expect(
      (await failureFor(422)).code,
      UserProfileErrorCode.validationFailed,
    );
    expect(
      (await failureFor(503)).code,
      UserProfileErrorCode.serviceUnavailable,
    );
  });

  test('unconfigured api throws before network', () async {
    const unconfigured = AppConfig(
      environment: AppEnvironment.development,
      appName: 'test',
      apiBaseUrl: '',
      enableLogging: false,
      enableBusinessProfileSamples: false,
      enableBusinessOfferingSamples: false,
  enableRemoteSearchDiscovery: false,
    );
    final repo = UserProfileApiRepository(
      apiClient: ApiClient(
        config: unconfigured,
        logger: AppLogger(unconfigured),
      ),
      config: unconfigured,
    );

    await expectLater(
      repo.fetchProfile(accessToken: 'token'),
      throwsA(
        isA<UserProfileFailure>().having(
          (e) => e.code,
          'code',
          UserProfileErrorCode.apiNotConfigured,
        ),
      ),
    );
  });
}

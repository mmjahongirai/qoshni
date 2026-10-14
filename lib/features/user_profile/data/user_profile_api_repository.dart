import 'package:dio/dio.dart';
import 'package:qoshni/core/config/app_config.dart';
import 'package:qoshni/core/network/api_client.dart';
import 'package:qoshni/features/user_profile/data/user_profile_dtos.dart';
import 'package:qoshni/features/user_profile/domain/user_profile_failure.dart';
import 'package:qoshni/features/user_profile/domain/user_profile_repository.dart';

class UserProfileApiRepository implements UserProfileRepository {
  UserProfileApiRepository({
    required ApiClient apiClient,
    required AppConfig config,
  })  : _dio = apiClient.dio,
        _config = config;

  final Dio _dio;
  final AppConfig _config;

  static const _prefix = '/api/v1/me';

  void _ensureApiConfigured() {
    if (!_config.apiConfigured) {
      throw const UserProfileFailure(
        code: UserProfileErrorCode.apiNotConfigured,
        message: 'API base URL is not configured.',
      );
    }
  }

  Map<String, String> _authHeader(String accessToken) {
    return {'Authorization': 'Bearer $accessToken'};
  }

  @override
  Future<UserProfileViewDto> fetchProfile({required String accessToken}) async {
    _ensureApiConfigured();
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '$_prefix/profile',
        options: Options(headers: _authHeader(accessToken)),
      );
      return _parseProfile(response.data);
    } on UserProfileFailure {
      rethrow;
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<UserProfileViewDto> updateProfile({
    required String accessToken,
    required UserProfileUpdateRequestDto request,
  }) async {
    _ensureApiConfigured();
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        '$_prefix/profile',
        data: request.toJson(),
        options: Options(headers: _authHeader(accessToken)),
      );
      return _parseProfile(response.data);
    } on UserProfileFailure {
      rethrow;
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<UserPreferencesViewDto> fetchPreferences({
    required String accessToken,
  }) async {
    _ensureApiConfigured();
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '$_prefix/preferences',
        options: Options(headers: _authHeader(accessToken)),
      );
      return _parsePreferences(response.data);
    } on UserProfileFailure {
      rethrow;
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<UserPreferencesViewDto> updatePreferences({
    required String accessToken,
    required UserPreferencesUpdateRequestDto request,
  }) async {
    _ensureApiConfigured();
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        '$_prefix/preferences',
        data: request.toJson(),
        options: Options(headers: _authHeader(accessToken)),
      );
      return _parsePreferences(response.data);
    } on UserProfileFailure {
      rethrow;
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  UserProfileViewDto _parseProfile(Map<String, dynamic>? data) {
    if (data == null) {
      throw const UserProfileFailure(
        code: UserProfileErrorCode.malformedResponse,
        message: 'Unexpected empty response.',
      );
    }
    try {
      return UserProfileViewDto.fromJson(data);
    } on UserProfileFailure {
      rethrow;
    } catch (_) {
      throw const UserProfileFailure(
        code: UserProfileErrorCode.malformedResponse,
        message: 'Unexpected profile response.',
      );
    }
  }

  UserPreferencesViewDto _parsePreferences(Map<String, dynamic>? data) {
    if (data == null) {
      throw const UserProfileFailure(
        code: UserProfileErrorCode.malformedResponse,
        message: 'Unexpected empty response.',
      );
    }
    try {
      return UserPreferencesViewDto.fromJson(data);
    } on UserProfileFailure {
      rethrow;
    } catch (_) {
      throw const UserProfileFailure(
        code: UserProfileErrorCode.malformedResponse,
        message: 'Unexpected preferences response.',
      );
    }
  }

  UserProfileFailure _mapDioError(DioException error) {
    final status = error.response?.statusCode;
    final body = error.response?.data;
    if (body is Map<String, dynamic> && body['error'] is Map<String, dynamic>) {
      return UserProfileErrorEnvelopeDto.fromJson(body).toFailure();
    }
    if (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return const UserProfileFailure(
        code: UserProfileErrorCode.network,
        message: 'Network connection failed.',
      );
    }
    if (status == 503) {
      return const UserProfileFailure(
        code: UserProfileErrorCode.serviceUnavailable,
        message: 'Service temporarily unavailable.',
      );
    }
    if (status == 401) {
      return const UserProfileFailure(
        code: UserProfileErrorCode.authenticationRequired,
        message: 'Authentication required.',
      );
    }
    if (status == 422) {
      return const UserProfileFailure(
        code: UserProfileErrorCode.validationFailed,
        message: 'Invalid profile or preferences data.',
      );
    }
    return const UserProfileFailure(
      code: UserProfileErrorCode.unknown,
      message: 'Request failed.',
    );
  }
}

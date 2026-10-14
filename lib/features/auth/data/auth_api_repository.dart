import 'package:dio/dio.dart';
import 'package:qoshni/core/config/app_config.dart';
import 'package:qoshni/core/network/api_client.dart';
import 'package:qoshni/features/auth/data/auth_dtos.dart';
import 'package:qoshni/features/auth/domain/auth_failure.dart';
import 'package:qoshni/features/auth/domain/auth_repository.dart';

class AuthApiRepository implements AuthRepository {
  AuthApiRepository({
    required ApiClient apiClient,
    required AppConfig config,
  })  : _dio = apiClient.dio,
        _config = config;

  final Dio _dio;
  final AppConfig _config;

  static const _prefix = '/api/v1/auth';

  void _ensureApiConfigured() {
    if (!_config.apiConfigured) {
      throw const AuthFailure(
        code: AuthErrorCode.apiNotConfigured,
        message: 'API base URL is not configured.',
      );
    }
  }

  @override
  Future<OtpChallengeCreatedDto> requestOtpChallenge(String phoneE164) async {
    _ensureApiConfigured();
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '$_prefix/otp/challenges',
        data: OtpChallengeCreateRequestDto(phone: phoneE164).toJson(),
      );
      final data = response.data;
      if (data == null) {
        throw const AuthFailure(
          code: AuthErrorCode.malformedResponse,
          message: 'Unexpected empty response.',
        );
      }
      return OtpChallengeCreatedDto.fromJson(data);
    } on AuthFailure {
      rethrow;
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<SessionTokensDto> verifyOtpChallenge({
    required String challengeId,
    required String code,
  }) async {
    _ensureApiConfigured();
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '$_prefix/otp/verify',
        data: OtpChallengeVerifyRequestDto(
          challengeId: challengeId,
          code: code,
        ).toJson(),
      );
      final data = response.data;
      if (data == null) {
        throw const AuthFailure(
          code: AuthErrorCode.malformedResponse,
          message: 'Unexpected empty response.',
        );
      }
      return SessionTokensDto.fromJson(data);
    } on AuthFailure {
      rethrow;
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<SessionTokensDto> refreshSession(String refreshToken) async {
    _ensureApiConfigured();
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '$_prefix/sessions/refresh',
        data: SessionRefreshRequestDto(refreshToken: refreshToken).toJson(),
      );
      final data = response.data;
      if (data == null) {
        throw const AuthFailure(
          code: AuthErrorCode.malformedResponse,
          message: 'Unexpected empty response.',
        );
      }
      return SessionTokensDto.fromJson(data);
    } on AuthFailure {
      rethrow;
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<List<SessionViewDto>> listSessions(String accessToken) async {
    _ensureApiConfigured();
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '$_prefix/sessions',
        options: Options(headers: _authHeader(accessToken)),
      );
      final data = response.data;
      if (data == null) {
        throw const AuthFailure(
          code: AuthErrorCode.malformedResponse,
          message: 'Unexpected empty response.',
        );
      }
      return SessionListDto.fromJson(data).sessions;
    } on AuthFailure {
      rethrow;
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<void> revokeCurrentSession(String accessToken) async {
    _ensureApiConfigured();
    try {
      await _dio.delete<void>(
        '$_prefix/sessions/current',
        options: Options(headers: _authHeader(accessToken)),
      );
    } on AuthFailure {
      rethrow;
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<void> revokeSession({
    required String accessToken,
    required String sessionId,
  }) async {
    _ensureApiConfigured();
    try {
      await _dio.delete<void>(
        '$_prefix/sessions/$sessionId',
        options: Options(headers: _authHeader(accessToken)),
      );
    } on AuthFailure {
      rethrow;
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  Map<String, String> _authHeader(String accessToken) {
    return {'Authorization': 'Bearer $accessToken'};
  }

  AuthFailure _mapDioError(DioException error) {
    final status = error.response?.statusCode;
    final body = error.response?.data;
    if (body is Map<String, dynamic> && body['error'] is Map<String, dynamic>) {
      return AuthErrorEnvelopeDto.fromJson(body).toFailure();
    }
    if (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return const AuthFailure(
        code: AuthErrorCode.network,
        message: 'Network connection failed.',
      );
    }
    if (status == 503) {
      return const AuthFailure(
        code: AuthErrorCode.serviceUnavailable,
        message: 'Sign-in is temporarily unavailable.',
      );
    }
    if (status == 401) {
      return const AuthFailure(
        code: AuthErrorCode.authenticationRequired,
        message: 'Authentication required.',
      );
    }
    return AuthFailure(
      code: AuthErrorCode.unknown,
      message: 'Request failed.',
    );
  }
}

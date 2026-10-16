import 'package:dio/dio.dart';
import 'package:qoshni/core/config/app_config.dart';
import 'package:qoshni/core/network/api_client.dart';
import 'package:qoshni/features/business_onboarding/data/onboarding_dtos.dart';
import 'package:qoshni/features/business_onboarding/domain/onboarding_failure.dart';
import 'package:qoshni/features/business_onboarding/domain/onboarding_repository.dart';

class OnboardingApiRepository implements OnboardingRepository {
  OnboardingApiRepository({
    required ApiClient apiClient,
    required AppConfig config,
  })  : _dio = apiClient.dio,
        _config = config;

  final Dio _dio;
  final AppConfig _config;

  static const _prefix = '/api/v1/business/onboarding';

  void _ensureApiConfigured() {
    if (!_config.apiConfigured) {
      throw const OnboardingFailure(
        code: OnboardingErrorCode.apiNotConfigured,
        message: 'API base URL is not configured.',
      );
    }
  }

  Options _authOptions(String accessToken) {
    return Options(headers: {'Authorization': 'Bearer $accessToken'});
  }

  @override
  Future<OwnerApplicationViewDto> createApplication({
    required String accessToken,
    OnboardingApplicationCreateRequestDto? request,
  }) async {
    _ensureApiConfigured();
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '$_prefix/applications',
        data: request?.toJson() ?? <String, dynamic>{},
        options: _authOptions(accessToken),
      );
      return _parseApplication(response.data);
    } on OnboardingFailure {
      rethrow;
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<List<OwnerApplicationViewDto>> listApplications({
    required String accessToken,
  }) async {
    _ensureApiConfigured();
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '$_prefix/applications',
        options: _authOptions(accessToken),
      );
      final data = response.data;
      if (data == null) {
        throw _malformed();
      }
      final items = data['applications'];
      if (items is! List) {
        throw _malformed();
      }
      return items
          .whereType<Map<String, dynamic>>()
          .map(OwnerApplicationViewDto.fromJson)
          .toList();
    } on OnboardingFailure {
      rethrow;
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<OwnerApplicationViewDto> fetchApplication({
    required String accessToken,
    required String applicationId,
  }) async {
    _ensureApiConfigured();
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '$_prefix/applications/$applicationId',
        options: _authOptions(accessToken),
      );
      return _parseApplication(response.data);
    } on OnboardingFailure {
      rethrow;
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<OwnerApplicationViewDto> updateDraft({
    required String accessToken,
    required String applicationId,
    required OnboardingApplicationDraftUpdateRequestDto request,
  }) async {
    _ensureApiConfigured();
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        '$_prefix/applications/$applicationId',
        data: request.toJson(),
        options: _authOptions(accessToken),
      );
      return _parseApplication(response.data);
    } on OnboardingFailure {
      rethrow;
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<OwnerApplicationViewDto> submitApplication({
    required String accessToken,
    required String applicationId,
  }) async {
    _ensureApiConfigured();
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '$_prefix/applications/$applicationId/submit',
        data: <String, dynamic>{},
        options: _authOptions(accessToken),
      );
      return _parseApplication(response.data);
    } on OnboardingFailure {
      rethrow;
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<OnboardingVerificationStatusViewDto> fetchVerificationStatus({
    required String accessToken,
    required String applicationId,
  }) async {
    _ensureApiConfigured();
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '$_prefix/applications/$applicationId/verification-status',
        options: _authOptions(accessToken),
      );
      final data = response.data;
      if (data == null) {
        throw _malformed();
      }
      return OnboardingVerificationStatusViewDto.fromJson(data);
    } on OnboardingFailure {
      rethrow;
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<OwnerDocumentViewDto> registerDocument({
    required String accessToken,
    required String applicationId,
    required RegisterOnboardingDocumentRequestDto request,
  }) async {
    _ensureApiConfigured();
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '$_prefix/applications/$applicationId/documents',
        data: request.toJson(),
        options: _authOptions(accessToken),
      );
      return _parseDocument(response.data);
    } on OnboardingFailure {
      rethrow;
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<List<OwnerDocumentViewDto>> listDocuments({
    required String accessToken,
    required String applicationId,
  }) async {
    _ensureApiConfigured();
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '$_prefix/applications/$applicationId/documents',
        options: _authOptions(accessToken),
      );
      final data = response.data;
      if (data == null) {
        throw _malformed();
      }
      final items = data['documents'];
      if (items is! List) {
        throw _malformed();
      }
      return items
          .whereType<Map<String, dynamic>>()
          .map(OwnerDocumentViewDto.fromJson)
          .toList();
    } on OnboardingFailure {
      rethrow;
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<OwnerDocumentViewDto> uploadDocument({
    required String accessToken,
    required String applicationId,
    required String documentId,
    required List<int> bytes,
    required String filename,
  }) async {
    _ensureApiConfigured();
    try {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(
          bytes,
          filename: filename,
        ),
      });
      final response = await _dio.post<Map<String, dynamic>>(
        '$_prefix/applications/$applicationId/documents/$documentId/upload',
        data: formData,
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
          sendTimeout: const Duration(minutes: 2),
          receiveTimeout: const Duration(minutes: 2),
        ),
      );
      return _parseDocument(response.data);
    } on OnboardingFailure {
      rethrow;
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  OwnerApplicationViewDto _parseApplication(Map<String, dynamic>? data) {
    if (data == null) {
      throw _malformed();
    }
    try {
      return OwnerApplicationViewDto.fromJson(data);
    } catch (_) {
      throw _malformed();
    }
  }

  OwnerDocumentViewDto _parseDocument(Map<String, dynamic>? data) {
    if (data == null) {
      throw _malformed();
    }
    try {
      return OwnerDocumentViewDto.fromJson(data);
    } catch (_) {
      throw _malformed();
    }
  }

  OnboardingFailure _malformed() {
    return const OnboardingFailure(
      code: OnboardingErrorCode.malformedResponse,
      message: 'Unexpected response.',
    );
  }

  OnboardingFailure _mapDioError(DioException error) {
    final status = error.response?.statusCode;
    final body = error.response?.data;
    if (body is Map<String, dynamic> && body['error'] is Map<String, dynamic>) {
      final err = body['error'] as Map<String, dynamic>;
      final code =
          OnboardingErrorCode.tryParse(err['code'] as String?) ??
          OnboardingErrorCode.unknown;
      final message = (err['message'] as String?) ?? 'Request failed.';
      return OnboardingFailure(code: code, message: message);
    }
    if (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return const OnboardingFailure(
        code: OnboardingErrorCode.network,
        message: 'Network connection failed.',
      );
    }
    if (status == 401) {
      return const OnboardingFailure(
        code: OnboardingErrorCode.authenticationRequired,
        message: 'Authentication required.',
      );
    }
    if (status == 503) {
      return const OnboardingFailure(
        code: OnboardingErrorCode.storageUnavailable,
        message: 'Service temporarily unavailable.',
      );
    }
    return const OnboardingFailure(
      code: OnboardingErrorCode.unknown,
      message: 'Request failed.',
    );
  }
}

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/core/config/app_config.dart';
import 'package:qoshni/core/config/app_environment.dart';
import 'package:qoshni/core/logging/app_logger.dart';
import 'package:qoshni/core/network/api_client.dart';
import 'package:qoshni/features/business_onboarding/data/onboarding_api_repository.dart';
import 'package:qoshni/features/business_onboarding/data/onboarding_dtos.dart';
import 'package:qoshni/features/business_onboarding/domain/onboarding_failure.dart';

const _config = AppConfig(
  environment: AppEnvironment.development,
  appName: 'test',
  apiBaseUrl: 'https://api.example.test',
  enableLogging: false,
  enableBusinessProfileSamples: false,
  enableBusinessOfferingSamples: false,
);

const _applicationJson = {
  'application_id': 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
  'legal_business_name': 'Acme LLC',
  'trade_display_name': null,
  'service_category': 'shops',
  'registration_jurisdiction': 'UZ',
  'registration_identifier': null,
  'tax_identifier': null,
  'business_contact_email': null,
  'verification_status': 'draft',
  'rejection_reason_code': null,
  'submitted_at': null,
  'reviewed_at': null,
  'created_at': '2026-10-14T12:00:00Z',
  'updated_at': '2026-10-14T12:05:00Z',
};

OnboardingApiRepository _repository(Dio dio) {
  return OnboardingApiRepository(
    apiClient: ApiClient(
      config: _config,
      logger: AppLogger(_config),
      dio: dio,
    ),
    config: _config,
  );
}

void main() {
  test('POST applications uses bearer auth and prefix', () async {
    String? auth;
    String? path;
    final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test'));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          auth = options.headers['Authorization'] as String?;
          path = options.path;
          handler.resolve(
            Response<Map<String, dynamic>>(
              requestOptions: options,
              statusCode: 201,
              data: _applicationJson,
            ),
          );
        },
      ),
    );

    await _repository(dio).createApplication(accessToken: 'tok');
    expect(path, '/api/v1/business/onboarding/applications');
    expect(auth, 'Bearer tok');
  });

  test('GET list parses applications array', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test'));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.resolve(
            Response<Map<String, dynamic>>(
              requestOptions: options,
              statusCode: 200,
              data: {'applications': [_applicationJson]},
            ),
          );
        },
      ),
    );

    final list = await _repository(dio).listApplications(accessToken: 'tok');
    expect(list, hasLength(1));
    expect(list.first.applicationId, 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa');
  });

  test('PATCH draft sends snake_case body', () async {
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
              data: _applicationJson,
            ),
          );
        },
      ),
    );

    await _repository(dio).updateDraft(
      accessToken: 'tok',
      applicationId: 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
      request: const OnboardingApplicationDraftUpdateRequestDto(
        legalBusinessName: 'Updated',
      ),
    );
    expect(body, {'legal_business_name': 'Updated'});
  });

  test('upload uses multipart field file', () async {
    FormData? form;
    String? path;
    final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test'));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          path = options.path;
          form = options.data as FormData?;
          handler.resolve(
            Response<Map<String, dynamic>>(
              requestOptions: options,
              statusCode: 200,
              data: {
                'document_id': 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
                'application_id': 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
                'document_type': 'registration_certificate',
                'lifecycle_state': 'uploaded_pending_validation',
                'created_at': '2026-10-14T12:00:00Z',
                'updated_at': '2026-10-14T12:10:00Z',
              },
            ),
          );
        },
      ),
    );

    await _repository(dio).uploadDocument(
      accessToken: 'tok',
      applicationId: 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
      documentId: 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
      bytes: [1, 2, 3],
      filename: 'cert.pdf',
    );

    expect(
      path,
      '/api/v1/business/onboarding/applications/aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa/documents/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb/upload',
    );
    expect(form, isNotNull);
    expect(form!.fields, isEmpty);
    expect(form!.files, hasLength(1));
    expect(form!.files.single.key, 'file');
    expect(form!.files.single.value.filename, 'cert.pdf');
  });

  test('maps 422 validation_failed', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test'));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.reject(
            DioException(
              requestOptions: options,
              response: Response<Map<String, dynamic>>(
                requestOptions: options,
                statusCode: 422,
                data: {
                  'error': {
                    'code': 'validation_failed',
                    'message': 'legal_business_name is required',
                  },
                },
              ),
            ),
          );
        },
      ),
    );

    expect(
      _repository(dio).submitApplication(
        accessToken: 'tok',
        applicationId: 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
      ),
      throwsA(
        isA<OnboardingFailure>().having(
          (e) => e.code,
          'code',
          OnboardingErrorCode.validationFailed,
        ),
      ),
    );
  });

  test('maps 503 storage_unavailable', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test'));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.reject(
            DioException(
              requestOptions: options,
              response: Response<Map<String, dynamic>>(
                requestOptions: options,
                statusCode: 503,
                data: {
                  'error': {
                    'code': 'storage_unavailable',
                    'message': 'Storage down',
                  },
                },
              ),
            ),
          );
        },
      ),
    );

    expect(
      _repository(dio).listDocuments(
        accessToken: 'tok',
        applicationId: 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
      ),
      throwsA(
        isA<OnboardingFailure>().having(
          (e) => e.code,
          'code',
          OnboardingErrorCode.storageUnavailable,
        ),
      ),
    );
  });

  test('maps 409 invalid_status_transition', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test'));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.reject(
            DioException(
              requestOptions: options,
              response: Response<Map<String, dynamic>>(
                requestOptions: options,
                statusCode: 409,
                data: {
                  'error': {
                    'code': 'invalid_status_transition',
                    'message': 'Cannot submit in current status.',
                  },
                },
              ),
            ),
          );
        },
      ),
    );

    expect(
      _repository(dio).submitApplication(
        accessToken: 'tok',
        applicationId: 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
      ),
      throwsA(
        isA<OnboardingFailure>().having(
          (e) => e.code,
          'code',
          OnboardingErrorCode.invalidStatusTransition,
        ),
      ),
    );
  });

  test('maps connection timeout to network', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test'));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.reject(
            DioException(
              requestOptions: options,
              type: DioExceptionType.connectionTimeout,
            ),
          );
        },
      ),
    );

    expect(
      _repository(dio).fetchApplication(
        accessToken: 'tok',
        applicationId: 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
      ),
      throwsA(
        isA<OnboardingFailure>().having(
          (e) => e.code,
          'code',
          OnboardingErrorCode.network,
        ),
      ),
    );
  });
}

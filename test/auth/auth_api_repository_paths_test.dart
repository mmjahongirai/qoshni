import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/core/config/app_config.dart';
import 'package:qoshni/core/config/app_environment.dart';
import 'package:qoshni/core/logging/app_logger.dart';
import 'package:qoshni/core/network/api_client.dart';
import 'package:qoshni/features/auth/data/auth_api_repository.dart';
import 'package:qoshni/features/auth/domain/auth_failure.dart';

void main() {
  test('maps JSON auth error envelope from non-2xx responses', () async {
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
                    'code': 'service_unavailable',
                    'message': 'Sign-in is temporarily unavailable.',
                  },
                },
              ),
              type: DioExceptionType.badResponse,
            ),
          );
        },
      ),
    );

    const config = AppConfig(
      environment: AppEnvironment.development,
      appName: 'test',
      apiBaseUrl: 'https://api.example.test',
      enableLogging: false,
      enableBusinessProfileSamples: false,
      enableBusinessOfferingSamples: false,
    );

    final repository = AuthApiRepository(
      apiClient: ApiClient(
        config: config,
        logger: AppLogger(config),
        dio: dio,
      ),
      config: config,
    );

    await expectLater(
      repository.requestOtpChallenge('+998901234567'),
      throwsA(
        isA<AuthFailure>().having(
          (e) => e.code,
          'code',
          AuthErrorCode.serviceUnavailable,
        ),
      ),
    );
  });
}

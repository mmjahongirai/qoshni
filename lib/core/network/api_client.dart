import 'package:dio/dio.dart';
import 'package:qoshni/core/config/app_config.dart';
import 'package:qoshni/core/logging/app_logger.dart';
import 'package:qoshni/core/network/api_interceptors.dart';

/// Shared HTTP client. No real endpoints are called in the foundation phase.
class ApiClient {
  ApiClient({
    required AppConfig config,
    required AppLogger logger,
    Dio? dio,
  }) : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: config.apiConfigured ? config.apiBaseUrl : 'http://invalid.local',
                connectTimeout: const Duration(seconds: 20),
                receiveTimeout: const Duration(seconds: 20),
                sendTimeout: const Duration(seconds: 20),
                headers: const {
                  'Accept': 'application/json',
                  'Content-Type': 'application/json',
                },
              ),
            ) {
    _dio.interceptors.addAll([
      AppLogInterceptor(logger),
      AppErrorInterceptor(),
    ]);
  }

  final Dio _dio;

  Dio get dio => _dio;
}

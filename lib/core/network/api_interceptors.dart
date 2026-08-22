import 'package:dio/dio.dart';
import 'package:qoshni/core/error/exceptions.dart';
import 'package:qoshni/core/logging/app_logger.dart';

class AppLogInterceptor extends Interceptor {
  AppLogInterceptor(this._logger);

  final AppLogger _logger;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _logger.debug('HTTP → ${options.method} ${options.uri}');
    handler.next(options);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    _logger.debug('HTTP ← ${response.statusCode} ${response.requestOptions.uri}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logger.error(
      'HTTP ✕ ${err.requestOptions.method} ${err.requestOptions.uri}',
      error: err,
      stackTrace: err.stackTrace,
    );
    handler.next(err);
  }
}

/// Converts transport errors into typed [AppException]s for repositories.
class AppErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final exception = switch (err.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.connectionError =>
        NetworkException(err.message ?? 'Connection failed', err),
      DioExceptionType.badResponse => ServerException(
          'Server responded with ${err.response?.statusCode}',
          err,
        ),
      _ => AppException(err.message ?? 'Unexpected network error', cause: err),
    };

    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: exception,
        stackTrace: err.stackTrace,
        message: err.message,
      ),
    );
  }
}

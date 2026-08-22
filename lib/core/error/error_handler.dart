import 'package:qoshni/core/error/exceptions.dart';
import 'package:qoshni/core/error/failures.dart';
import 'package:qoshni/core/logging/app_logger.dart';

/// Central mapping from thrown errors to domain [Failure]s.
class ErrorHandler {
  ErrorHandler(this._logger);

  final AppLogger _logger;

  Failure handle(Object error, [StackTrace? stackTrace]) {
    _logger.error('Handled error', error: error, stackTrace: stackTrace);

    if (error is NetworkException) {
      return NetworkFailure(error.message);
    }
    if (error is ServerException) {
      return ServerFailure(error.message);
    }
    if (error is CacheException) {
      return CacheFailure(error.message);
    }
    if (error is AppException) {
      return UnexpectedFailure(error.message);
    }

    return UnexpectedFailure(error.toString());
  }
}

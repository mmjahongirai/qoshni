/// Data-layer exceptions. Catch in repositories and convert to [Failure].
class AppException implements Exception {
  const AppException(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => 'AppException($message)';
}

class NetworkException extends AppException {
  const NetworkException([
    String message = 'Network exception',
    Object? cause,
  ]) : super(message, cause: cause);
}

class ServerException extends AppException {
  const ServerException([
    String message = 'Server exception',
    Object? cause,
  ]) : super(message, cause: cause);
}

class CacheException extends AppException {
  const CacheException([
    String message = 'Cache exception',
    Object? cause,
  ]) : super(message, cause: cause);
}

/// Abstraction for connectivity checks.
///
/// Implementation will be added when the first online feature lands.
abstract interface class NetworkInfo {
  Future<bool> get isConnected;
}

class UnimplementedNetworkInfo implements NetworkInfo {
  @override
  Future<bool> get isConnected async =>
      throw UnimplementedError('NetworkInfo is not wired yet');
}

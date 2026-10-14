// Stores refresh credentials outside widgets.
//
// Session-only credential storage (no persistent secure storage in this increment).
// Web and mobile persistent login requires a vetted secure-storage plugin plus
// CSP/XSS hardening on web. Refresh tokens are kept in memory only and are
// cleared on app restart.
abstract class AuthCredentialStore {
  Future<String?> readRefreshToken();
  Future<void> writeRefreshToken(String? token);
  Future<void> clear();
}

class InMemoryAuthCredentialStore implements AuthCredentialStore {
  String? _refreshToken;

  @override
  Future<void> clear() async {
    _refreshToken = null;
  }

  @override
  Future<String?> readRefreshToken() async => _refreshToken;

  @override
  Future<void> writeRefreshToken(String? token) async {
    _refreshToken = token;
  }
}

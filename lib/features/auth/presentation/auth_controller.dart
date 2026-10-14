import 'package:flutter/foundation.dart';
import 'package:qoshni/core/config/app_config.dart';
import 'package:qoshni/features/auth/data/auth_credential_store.dart';
import 'package:qoshni/features/auth/data/auth_dtos.dart';
import 'package:qoshni/features/auth/domain/auth_failure.dart';
import 'package:qoshni/features/auth/domain/auth_repository.dart';

enum AuthStatus {
  guest,
  loading,
  otpPending,
  signedIn,
  sessionExpired,
}

/// Single source of truth for authentication state.
class AuthController extends ChangeNotifier {
  AuthController({
    required AuthRepository repository,
    required AuthCredentialStore credentialStore,
    required AppConfig config,
  })  : _repository = repository,
        _credentialStore = credentialStore,
        _config = config;

  final AuthRepository _repository;
  final AuthCredentialStore _credentialStore;
  final AppConfig _config;

  AuthStatus status = AuthStatus.guest;
  String? userId;
  String? sessionId;
  String? challengeId;
  DateTime? challengeExpiresAt;
  int? otpCodeLength;
  AuthFailure? lastFailure;
  List<SessionViewDto> sessions = const [];
  bool busy = false;

  String? _accessToken;

  bool get isSignedIn => status == AuthStatus.signedIn;
  bool get apiConfigured => _config.apiConfigured;

  String? get accessToken => _accessToken;

  Future<void> requestOtp(String phoneE164) async {
    if (busy) {
      return;
    }
    lastFailure = null;
    if (!_config.apiConfigured) {
      lastFailure = const AuthFailure(
        code: AuthErrorCode.apiNotConfigured,
        message: 'API not configured',
      );
      notifyListeners();
      return;
    }
    busy = true;
    status = AuthStatus.loading;
    notifyListeners();
    try {
      final created = await _repository.requestOtpChallenge(phoneE164);
      challengeId = created.challengeId;
      challengeExpiresAt = created.expiresAt;
      otpCodeLength = created.codeLength;
      status = AuthStatus.otpPending;
    } on AuthFailure catch (failure) {
      lastFailure = failure;
      status = AuthStatus.guest;
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<void> verifyOtp(String code) async {
    if (busy || challengeId == null) {
      return;
    }
    lastFailure = null;
    busy = true;
    status = AuthStatus.loading;
    notifyListeners();
    try {
      final tokens = await _repository.verifyOtpChallenge(
        challengeId: challengeId!,
        code: code.trim(),
      );
      await _applySessionTokens(tokens);
      status = AuthStatus.signedIn;
      challengeId = null;
    } on AuthFailure catch (failure) {
      lastFailure = failure;
      status = AuthStatus.otpPending;
      if (failure.code == AuthErrorCode.challengeConsumed ||
          failure.code == AuthErrorCode.challengeExpired ||
          failure.code == AuthErrorCode.challengeLocked) {
        status = AuthStatus.guest;
        challengeId = null;
      }
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<void> refreshSessions() async {
    final token = _accessToken;
    if (token == null) {
      return;
    }
    try {
      sessions = await _repository.listSessions(token);
      notifyListeners();
    } on AuthFailure catch (failure) {
      await _handleSessionFailure(failure);
    }
  }

  Future<void> signOut() async {
    final token = _accessToken;
    if (token != null) {
      try {
        await _repository.revokeCurrentSession(token);
      } on AuthFailure {
        // Local sign-out still proceeds.
      }
    }
    await _clearSession(localOnly: true);
    status = AuthStatus.guest;
    notifyListeners();
  }

  Future<void> revokeOwnedSession(String targetSessionId) async {
    final token = _accessToken;
    if (token == null || busy) {
      return;
    }
    busy = true;
    notifyListeners();
    try {
      await _repository.revokeSession(
        accessToken: token,
        sessionId: targetSessionId,
      );
      if (targetSessionId == sessionId) {
        await _clearSession(localOnly: true);
        status = AuthStatus.guest;
      } else {
        await refreshSessions();
      }
    } on AuthFailure catch (failure) {
      lastFailure = failure;
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<void> tryRefreshAccessToken() async {
    final refresh = await _credentialStore.readRefreshToken();
    if (refresh == null || refresh.isEmpty) {
      await _clearSession(localOnly: true);
      status = AuthStatus.sessionExpired;
      notifyListeners();
      return;
    }
    try {
      final tokens = await _repository.refreshSession(refresh);
      await _applySessionTokens(tokens);
      status = AuthStatus.signedIn;
      notifyListeners();
    } on AuthFailure catch (failure) {
      await _handleSessionFailure(failure);
    }
  }

  Future<void> _applySessionTokens(SessionTokensDto tokens) async {
    _accessToken = tokens.accessToken;
    userId = tokens.userId;
    sessionId = tokens.session.sessionId;
    await _credentialStore.writeRefreshToken(tokens.refreshToken);
    sessions = [tokens.session];
  }

  Future<void> _clearSession({required bool localOnly}) async {
    _accessToken = null;
    userId = null;
    sessionId = null;
    challengeId = null;
    challengeExpiresAt = null;
    otpCodeLength = null;
    sessions = const [];
    await _credentialStore.clear();
  }

  Future<void> _handleSessionFailure(AuthFailure failure) async {
    lastFailure = failure;
    if (failure.code == AuthErrorCode.authenticationRequired ||
        failure.code == AuthErrorCode.sessionInvalid ||
        failure.code == AuthErrorCode.accountUnavailable) {
      if (_accessToken != null &&
          failure.code == AuthErrorCode.authenticationRequired) {
        await tryRefreshAccessToken();
        return;
      }
      await _clearSession(localOnly: true);
      status = AuthStatus.sessionExpired;
    }
    notifyListeners();
  }

  void resetOtpFlow() {
    challengeId = null;
    challengeExpiresAt = null;
    otpCodeLength = null;
    lastFailure = null;
    if (status == AuthStatus.otpPending) {
      status = AuthStatus.guest;
    }
    notifyListeners();
  }
}

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:qoshni/core/config/app_config.dart';
import 'package:qoshni/features/auth/domain/auth_failure.dart';
import 'package:qoshni/features/auth/presentation/auth_controller.dart';
import 'package:qoshni/features/wallet/domain/wallet.dart';

enum WalletViewState {
  /// Nothing requested yet.
  idle,
  loading,
  loaded,

  /// No signed-in session. The page offers the existing sign-in flow.
  signedOut,

  /// 404: the server has no wallet for this account.
  notFound,

  /// 5xx, network errors, malformed bodies, or the wallet tables are not
  /// migrated yet. Technical details are never shown to the user.
  unavailable,

  /// This build has no API base URL.
  apiNotConfigured,
}

/// Loads the signed-in user's wallet from the server. One per Wallet page.
///
/// It shows only what the server returned: no derived, demo, or cached
/// balances. Signing out clears the loaded wallet.
class WalletController extends ChangeNotifier {
  WalletController({
    required WalletRepository repository,
    required AuthController authController,
    required AppConfig config,
  })  : _repository = repository,
        _authController = authController,
        _config = config {
    _wasSignedIn = _authController.isSignedIn;
    _authController.addListener(_onAuthChanged);
  }

  final WalletRepository _repository;
  final AuthController _authController;
  final AppConfig _config;

  WalletViewState state = WalletViewState.idle;
  WalletBalance? wallet;

  bool _wasSignedIn = false;
  bool _disposed = false;
  int _generation = 0;

  bool get loading => state == WalletViewState.loading;

  @override
  void dispose() {
    _disposed = true;
    _authController.removeListener(_onAuthChanged);
    super.dispose();
  }

  void _onAuthChanged() {
    final signedIn = _authController.isSignedIn;
    if (signedIn == _wasSignedIn) {
      return;
    }
    _wasSignedIn = signedIn;
    if (signedIn) {
      unawaited(load());
    } else {
      _generation++;
      wallet = null;
      state = WalletViewState.signedOut;
      _notify();
    }
  }

  Future<void> load() => _load(allowAuthRetry: true);

  Future<void> _load({required bool allowAuthRetry}) async {
    if (!_config.apiConfigured) {
      _show(WalletViewState.apiNotConfigured);
      return;
    }
    final token = _authController.accessToken;
    if (!_authController.isSignedIn || token == null || token.isEmpty) {
      _show(WalletViewState.signedOut);
      return;
    }
    final generation = ++_generation;
    state = WalletViewState.loading;
    _notify();
    try {
      final result = await _repository.fetchMyWallet(accessToken: token);
      if (generation != _generation) {
        return;
      }
      wallet = result;
      state = WalletViewState.loaded;
      _notify();
    } on WalletFailure catch (failure) {
      if (generation != _generation) {
        return;
      }
      await _handleFailure(failure, token, allowAuthRetry: allowAuthRetry);
    }
  }

  Future<void> _handleFailure(
    WalletFailure failure,
    String usedToken, {
    required bool allowAuthRetry,
  }) async {
    switch (failure.kind) {
      case WalletFailureKind.authenticationRequired:
        wallet = null;
        // The auth controller refreshes the session or signs out.
        await _authController.reportAuthenticatedRequestFailure(
          const AuthFailure(
            code: AuthErrorCode.authenticationRequired,
            message: 'wallet request was not authenticated',
          ),
        );
        if (_disposed) {
          return;
        }
        final refreshed = _authController.accessToken;
        if (allowAuthRetry &&
            _authController.isSignedIn &&
            refreshed != null &&
            refreshed != usedToken) {
          // One retry with the refreshed token, never more.
          await _load(allowAuthRetry: false);
          return;
        }
        _show(WalletViewState.signedOut);
      case WalletFailureKind.notFound:
        _show(WalletViewState.notFound);
      case WalletFailureKind.apiNotConfigured:
        _show(WalletViewState.apiNotConfigured);
      case WalletFailureKind.unavailable:
      case WalletFailureKind.malformedResponse:
        _show(WalletViewState.unavailable);
    }
  }

  void _show(WalletViewState next) {
    wallet = null;
    state = next;
    _notify();
  }

  void _notify() {
    if (!_disposed) {
      notifyListeners();
    }
  }
}

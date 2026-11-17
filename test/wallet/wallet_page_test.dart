import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/core/config/app_config.dart';
import 'package:qoshni/core/config/app_environment.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/features/auth/data/auth_credential_store.dart';
import 'package:qoshni/features/auth/data/auth_dtos.dart';
import 'package:qoshni/features/auth/domain/auth_failure.dart';
import 'package:qoshni/features/auth/domain/auth_repository.dart';
import 'package:qoshni/features/auth/presentation/auth_controller.dart';
import 'package:qoshni/features/wallet/application/wallet_controller.dart';
import 'package:qoshni/features/wallet/domain/wallet.dart';
import 'package:qoshni/features/wallet/presentation/pages/wallet_page.dart';

const _configured = AppConfig(
  environment: AppEnvironment.development,
  appName: 'test',
  apiBaseUrl: 'https://api.example.test',
  enableLogging: false,
  enableBusinessProfileSamples: false,
  enableBusinessOfferingSamples: false,
  enableRemoteSearchDiscovery: false,
);

const _wallet = WalletBalance(
  walletId: 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
  currencyCode: 'UZS',
  availableMinor: 1250000,
  holdMinor: 8000,
  pendingMinor: 0,
  status: WalletStatus.active,
);

class _FakeAuthRepository implements AuthRepository {
  int issued = 0;
  bool refreshSucceeds = false;

  SessionTokensDto _tokens() {
    issued += 1;
    return SessionTokensDto(
      tokenType: 'bearer',
      accessToken: 'access-$issued',
      accessTokenExpiresAt: DateTime.utc(2026, 11, 17, 12, 15),
      refreshToken: 'refresh-$issued',
      refreshTokenExpiresAt: DateTime.utc(2026, 12, 17),
      userId: '22222222-2222-2222-2222-222222222222',
      session: SessionViewDto(
        sessionId: '33333333-3333-3333-3333-333333333333',
        state: 'active',
        createdAt: DateTime.utc(2026, 11, 17, 12),
        expiresAt: DateTime.utc(2026, 12, 17),
        isCurrent: true,
      ),
    );
  }

  @override
  Future<OtpChallengeCreatedDto> requestOtpChallenge(String phoneE164) async {
    return OtpChallengeCreatedDto(
      challengeId: '11111111-1111-1111-1111-111111111111',
      expiresAt: DateTime.utc(2026, 11, 17, 12),
      codeLength: 6,
    );
  }

  @override
  Future<SessionTokensDto> verifyOtpChallenge({
    required String challengeId,
    required String code,
  }) async => _tokens();

  @override
  Future<SessionTokensDto> refreshSession(String refreshToken) async {
    if (!refreshSucceeds) {
      throw const AuthFailure(code: AuthErrorCode.sessionInvalid, message: 'invalid');
    }
    return _tokens();
  }

  @override
  Future<List<SessionViewDto>> listSessions(String accessToken) async => [];

  @override
  Future<void> revokeCurrentSession(String accessToken) async {}

  @override
  Future<void> revokeSession({
    required String accessToken,
    required String sessionId,
  }) async {}
}

class _FakeWallets implements WalletRepository {
  final List<String> tokens = [];
  final List<Object> results = [];
  Completer<WalletBalance>? pending;

  @override
  Future<WalletBalance> fetchMyWallet({required String accessToken}) async {
    tokens.add(accessToken);
    final waiting = pending;
    if (waiting != null) {
      return waiting.future;
    }
    final next = results.isEmpty ? _wallet : results.removeAt(0);
    if (next is WalletFailure) {
      throw next;
    }
    return next as WalletBalance;
  }
}

Future<AuthController> _auth({bool signedIn = true, _FakeAuthRepository? repository}) async {
  final auth = AuthController(
    repository: repository ?? _FakeAuthRepository(),
    credentialStore: InMemoryAuthCredentialStore(),
    config: _configured,
  );
  if (signedIn) {
    await auth.requestOtp('+998901234567');
    await auth.verifyOtp('123456');
  }
  return auth;
}

Widget _app(WalletController controller) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
    home: WalletPage(controller: controller),
  );
}

void main() {
  testWidgets('shows a loading indicator while the server answers', (tester) async {
    final wallets = _FakeWallets()..pending = Completer<WalletBalance>();
    final controller = WalletController(
      repository: wallets,
      authController: await _auth(),
      config: _configured,
    );

    await tester.pumpWidget(_app(controller));
    await tester.pump();

    expect(controller.state, WalletViewState.loading);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.textContaining("so'm"), findsNothing);

    wallets.pending!.complete(_wallet);
    wallets.pending = null;
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('wallet-available-amount')), findsOneWidget);
  });

  testWidgets('shows server balances, currency, and status', (tester) async {
    final wallets = _FakeWallets();
    final controller = WalletController(
      repository: wallets,
      authController: await _auth(),
      config: _configured,
    );

    await tester.pumpWidget(_app(controller));
    await tester.pumpAndSettle();

    expect(wallets.tokens, ['access-1']);
    expect(find.text('Wallet'), findsOneWidget);
    expect(find.text('Available balance'), findsOneWidget);
    expect(
      tester.widget<Text>(find.byKey(const Key('wallet-available-amount'))).data,
      "1,250,000 so'm",
    );
    expect(tester.widget<Text>(find.byKey(const Key('wallet-hold-amount'))).data, "8,000 so'm");
    expect(tester.widget<Text>(find.byKey(const Key('wallet-pending-amount'))).data, "0 so'm");
    expect(find.text('UZS'), findsOneWidget);
    expect(find.text('Active'), findsWidgets);
    // Read-only: the only action is the refresh icon; no money buttons.
    for (final type in [FilledButton, ElevatedButton, OutlinedButton, TextButton]) {
      expect(find.byType(type), findsNothing, reason: '$type');
    }
    expect(find.widgetWithIcon(IconButton, Icons.refresh_rounded), findsOneWidget);
    expect(
      find.textContaining('Top-ups and withdrawals are not available yet.'),
      findsOneWidget,
    );

    await tester.tap(find.byTooltip('Refresh'));
    await tester.pumpAndSettle();
    expect(wallets.tokens, ['access-1', 'access-1']);
  });

  testWidgets('5xx shows a friendly unavailable state without details or balances', (tester) async {
    final wallets = _FakeWallets()
      ..results.add(const WalletFailure(WalletFailureKind.unavailable));
    final controller = WalletController(
      repository: wallets,
      authController: await _auth(),
      config: _configured,
    );

    await tester.pumpWidget(_app(controller));
    await tester.pumpAndSettle();

    expect(controller.state, WalletViewState.unavailable);
    expect(find.text('Wallet is temporarily unavailable'), findsOneWidget);
    expect(find.textContaining("so'm"), findsNothing);
    expect(find.textContaining(RegExp('500|relation|exception', caseSensitive: false)), findsNothing);

    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(controller.state, WalletViewState.loaded);
    expect(find.byKey(const Key('wallet-available-amount')), findsOneWidget);
  });

  testWidgets('malformed response is shown as unavailable', (tester) async {
    final wallets = _FakeWallets()
      ..results.add(const WalletFailure(WalletFailureKind.malformedResponse));
    final controller = WalletController(
      repository: wallets,
      authController: await _auth(),
      config: _configured,
    );

    await tester.pumpWidget(_app(controller));
    await tester.pumpAndSettle();

    expect(find.text('Wallet is temporarily unavailable'), findsOneWidget);
  });

  testWidgets('404 shows that no wallet exists yet', (tester) async {
    final wallets = _FakeWallets()..results.add(const WalletFailure(WalletFailureKind.notFound));
    final controller = WalletController(
      repository: wallets,
      authController: await _auth(),
      config: _configured,
    );

    await tester.pumpWidget(_app(controller));
    await tester.pumpAndSettle();

    expect(find.text('No wallet yet'), findsOneWidget);
    expect(find.textContaining("so'm"), findsNothing);
  });

  testWidgets('signed-out user is asked to sign in and no request is sent', (tester) async {
    final wallets = _FakeWallets();
    final controller = WalletController(
      repository: wallets,
      authController: await _auth(signedIn: false),
      config: _configured,
    );

    await tester.pumpWidget(_app(controller));
    await tester.pumpAndSettle();

    expect(controller.state, WalletViewState.signedOut);
    expect(find.text('Sign in to see your wallet'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Sign in'), findsOneWidget);
    expect(wallets.tokens, isEmpty);
  });

  testWidgets('401 with a failed refresh signs out and asks to sign in', (tester) async {
    final auth = await _auth();
    final wallets = _FakeWallets()
      ..results.add(const WalletFailure(WalletFailureKind.authenticationRequired));
    final controller = WalletController(repository: wallets, authController: auth, config: _configured);

    await tester.pumpWidget(_app(controller));
    await tester.pumpAndSettle();

    expect(auth.isSignedIn, isFalse);
    expect(controller.state, WalletViewState.signedOut);
    expect(controller.wallet, isNull);
    expect(find.text('Sign in to see your wallet'), findsOneWidget);
    expect(wallets.tokens, ['access-1']);
  });

  test('401 retries once with a refreshed token, never more', () async {
    final authRepository = _FakeAuthRepository()..refreshSucceeds = true;
    final auth = await _auth(repository: authRepository);
    final wallets = _FakeWallets()
      ..results.addAll(const [
        WalletFailure(WalletFailureKind.authenticationRequired),
        WalletFailure(WalletFailureKind.authenticationRequired),
      ]);
    final controller = WalletController(repository: wallets, authController: auth, config: _configured);

    await controller.load();

    expect(wallets.tokens, ['access-1', 'access-2']);
    expect(controller.state, WalletViewState.signedOut);
    expect(controller.wallet, isNull);
  });

  test('signing out clears a loaded wallet', () async {
    final auth = await _auth();
    final controller = WalletController(
      repository: _FakeWallets(),
      authController: auth,
      config: _configured,
    );
    await controller.load();
    expect(controller.wallet, isNotNull);

    await auth.signOut();

    expect(controller.state, WalletViewState.signedOut);
    expect(controller.wallet, isNull);
  });

  testWidgets('build without an API URL shows a configuration notice', (tester) async {
    final unconfigured = AppConfig.forEnvironment(AppEnvironment.development);
    final wallets = _FakeWallets();
    final controller = WalletController(
      repository: wallets,
      authController: AuthController(
        repository: _FakeAuthRepository(),
        credentialStore: InMemoryAuthCredentialStore(),
        config: unconfigured,
      ),
      config: unconfigured,
    );

    await tester.pumpWidget(_app(controller));
    await tester.pumpAndSettle();

    expect(find.text('Wallet server is not configured for this build.'), findsOneWidget);
    expect(wallets.tokens, isEmpty);
  });
}

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/core/config/app_config.dart';
import 'package:qoshni/core/config/app_environment.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/logging/app_logger.dart';
import 'package:qoshni/core/network/api_client.dart';
import 'package:qoshni/features/wallet/data/wallet_api_repository.dart';
import 'package:qoshni/features/wallet/domain/wallet.dart';
import 'package:qoshni/features/wallet/presentation/wallet_amount_format.dart';
import 'package:flutter/widgets.dart';

const _configured = AppConfig(
  environment: AppEnvironment.development,
  appName: 'test',
  apiBaseUrl: 'https://api.example.test',
  enableLogging: false,
  enableBusinessProfileSamples: false,
  enableBusinessOfferingSamples: false,
  enableRemoteSearchDiscovery: false,
);

Map<String, dynamic> walletJson({
  Object? available = 125000,
  Object? hold = 8000,
  Object? pending = 0,
  Object? status = 'active',
}) {
  return {
    'wallet_id': 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
    'owner_type': 'user',
    'owner_id': 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
    'currency_code': 'UZS',
    'available_minor': available,
    'hold_minor': hold,
    'pending_minor': pending,
    'status': status,
  };
}

WalletApiRepository _repository(
  void Function(RequestOptions options, RequestInterceptorHandler handler) onRequest, {
  AppConfig config = _configured,
}) {
  final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test'));
  dio.interceptors.add(InterceptorsWrapper(onRequest: onRequest));
  return WalletApiRepository(
    apiClient: ApiClient(config: config, logger: AppLogger(config), dio: dio),
    config: config,
  );
}

void _reject(RequestOptions options, RequestInterceptorHandler handler, int status) {
  handler.reject(
    DioException(
      requestOptions: options,
      response: Response<Object?>(
        requestOptions: options,
        statusCode: status,
        data: {'detail': 'relation "wallets" does not exist'},
      ),
      type: DioExceptionType.badResponse,
    ),
  );
}

Future<WalletFailureKind> _failureOf(Future<WalletBalance> call) async {
  try {
    await call;
  } on WalletFailure catch (failure) {
    return failure.kind;
  }
  fail('expected WalletFailure');
}

void main() {
  test('GET /api/v1/wallets/me sends bearer auth and reads server values', () async {
    String? path;
    String? method;
    String? auth;
    Object? body;
    final repository = _repository((options, handler) {
      path = options.path;
      method = options.method;
      auth = options.headers['Authorization'] as String?;
      body = options.data;
      handler.resolve(
        Response<Object?>(requestOptions: options, statusCode: 200, data: walletJson()),
      );
    });

    final wallet = await repository.fetchMyWallet(accessToken: 'access-1');

    expect(method, 'GET');
    expect(path, '/api/v1/wallets/me');
    expect(auth, 'Bearer access-1');
    expect(body, isNull);
    expect(wallet.availableMinor, 125000);
    expect(wallet.holdMinor, 8000);
    expect(wallet.pendingMinor, 0);
    expect(wallet.currencyCode, 'UZS');
    expect(wallet.status, WalletStatus.active);
  });

  test('401 maps to authentication required', () async {
    final repository = _repository((options, handler) => _reject(options, handler, 401));
    expect(
      await _failureOf(repository.fetchMyWallet(accessToken: 'access-1')),
      WalletFailureKind.authenticationRequired,
    );
  });

  test('404 maps to wallet not found', () async {
    final repository = _repository((options, handler) => _reject(options, handler, 404));
    expect(
      await _failureOf(repository.fetchMyWallet(accessToken: 'access-1')),
      WalletFailureKind.notFound,
    );
  });

  test('5xx (for example missing wallet tables) maps to unavailable', () async {
    for (final status in [500, 502, 503]) {
      final repository = _repository((options, handler) => _reject(options, handler, status));
      expect(
        await _failureOf(repository.fetchMyWallet(accessToken: 'access-1')),
        WalletFailureKind.unavailable,
      );
    }
  });

  test('network error maps to unavailable', () async {
    final repository = _repository((options, handler) {
      handler.reject(
        DioException(requestOptions: options, type: DioExceptionType.connectionError),
      );
    });
    expect(
      await _failureOf(repository.fetchMyWallet(accessToken: 'access-1')),
      WalletFailureKind.unavailable,
    );
  });

  test('unconfigured API and empty token never send a request', () async {
    var requests = 0;
    final unconfigured = _repository(
      (options, handler) => requests++,
      config: AppConfig.forEnvironment(AppEnvironment.development),
    );
    expect(
      await _failureOf(unconfigured.fetchMyWallet(accessToken: 'access-1')),
      WalletFailureKind.apiNotConfigured,
    );
    final configured = _repository((options, handler) => requests++);
    expect(
      await _failureOf(configured.fetchMyWallet(accessToken: '')),
      WalletFailureKind.authenticationRequired,
    );
    expect(requests, 0);
  });

  test('malformed or unsafe amounts are rejected, never shown', () {
    for (final json in [
      walletJson(available: '125000'),
      walletJson(hold: 12.5),
      walletJson(pending: null),
      walletJson(available: WalletBalance.maxSafeMinor + 1),
      {...walletJson(), 'currency_code': null},
      {...walletJson(), 'wallet_id': ''},
    ]) {
      expect(
        () => WalletBalance.fromJson(json),
        throwsA(
          isA<WalletFailure>().having(
            (failure) => failure.kind,
            'kind',
            WalletFailureKind.malformedResponse,
          ),
        ),
        reason: '$json',
      );
    }
  });

  test('largest safe amount and unknown status are kept as returned', () {
    final wallet = WalletBalance.fromJson(
      walletJson(available: WalletBalance.maxSafeMinor, status: 'something-new'),
    );
    expect(wallet.availableMinor, WalletBalance.maxSafeMinor);
    expect(wallet.status, WalletStatus.unknown);
    expect(WalletBalance.fromJson(walletJson(status: 'frozen')).status, WalletStatus.frozen);
  });

  group('minor units to UZS', () {
    Future<AppLocalizations> l10nFor(String code) =>
        AppLocalizations.delegate.load(Locale(code));

    test('groups whole so\'m without dividing or rounding', () async {
      final en = await l10nFor('en');
      expect(formatWalletAmount(en, 0, 'UZS'), "0 so'm");
      expect(formatWalletAmount(en, 8000, 'UZS'), "8,000 so'm");
      expect(formatWalletAmount(en, 1250000, 'UZS'), "1,250,000 so'm");
      expect(
        formatWalletAmount(en, WalletBalance.maxSafeMinor, 'UZS'),
        "9,007,199,254,740,991 so'm",
      );
    });

    test('uses the locale currency word', () async {
      final ru = await l10nFor('ru');
      final uz = await l10nFor('uz');
      expect(formatWalletAmount(ru, 1250000, 'UZS'), endsWith(' сум'));
      expect(formatWalletAmount(ru, 1250000, 'UZS').replaceAll(RegExp(r'\D'), ''), '1250000');
      expect(formatWalletAmount(uz, 1250000, 'UZS'), endsWith(' so‘m'));
      expect(formatWalletAmount(uz, 1250000, 'UZS').replaceAll(RegExp(r'\D'), ''), '1250000');
    });

    test('a non-UZS currency shows its code', () async {
      final en = await l10nFor('en');
      expect(formatWalletAmount(en, 500, 'USD'), '500 USD');
    });
  });
}

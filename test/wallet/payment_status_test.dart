import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/core/config/app_config.dart';
import 'package:qoshni/core/config/app_environment.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/logging/app_logger.dart';
import 'package:qoshni/core/network/api_client.dart';
import 'package:qoshni/features/wallet/application/payment_status_controller.dart';
import 'package:qoshni/features/wallet/data/payment_api_repository.dart';
import 'package:qoshni/features/wallet/domain/payment.dart';

const _paymentId = 'cccccccc-cccc-cccc-cccc-cccccccccccc';
const _orderId = 'dddddddd-dddd-dddd-dddd-dddddddddddd';

const _configured = AppConfig(
  environment: AppEnvironment.development,
  appName: 'test',
  apiBaseUrl: 'https://api.example.test',
  enableLogging: false,
  enableBusinessProfileSamples: true,
  enableBusinessOfferingSamples: true,
  enableRemoteSearchDiscovery: false,
);

PaymentRecord _record() {
  return PaymentRecord(
    paymentId: _paymentId,
    orderId: _orderId,
    amountMinor: 8000,
    currencyCode: 'UZS',
    status: 'held',
    holdId: 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee',
    createdAt: DateTime.utc(2026, 11, 6),
    idempotentReplay: false,
  );
}

class _FakePayments implements PaymentRepository {
  int reads = 0;

  @override
  Future<PaymentRecord> createWalletPayment({
    required String accessToken,
    required String idempotencyKey,
    required String orderId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<PaymentRecord> getPayment({
    required String accessToken,
    required String paymentId,
  }) async {
    reads += 1;
    return _record();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('payment read keeps the server amount and status', () async {
    final fake = _FakePayments();
    final controller = PaymentStatusController(fake);
    final loaded = await controller.load(
      accessToken: 'secret-token',
      paymentId: _paymentId,
    );
    final english = await AppLocalizations.delegate.load(const Locale('en'));
    expect(loaded, isTrue);
    expect(fake.reads, 1);
    expect(controller.payment?.amountMinor, 8000);
    expect(controller.payment?.status, 'held');
    expect(controller.statusLabel(english), contains('held'));
    expect(controller.failure, isNull);
    expect(controller.toString(), isNot(contains('secret-token')));
  });

  test('create request sends no amount', () async {
    late RequestOptions captured;
    final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test'));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          captured = options;
          handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 201,
              data: {
                'payment_id': _paymentId,
                'order_id': _orderId,
                'amount_minor': 8000,
                'currency_code': 'UZS',
                'status': 'held',
                'hold_id': 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee',
                'created_at': '2026-11-06T12:00:00Z',
                'idempotent_replay': false,
              },
            ),
          );
        },
      ),
    );
    final repository = PaymentApiRepository(
      apiClient: ApiClient(
        config: _configured,
        logger: AppLogger(_configured),
        dio: dio,
      ),
      config: _configured,
    );
    final created = await repository.createWalletPayment(
      accessToken: 'secret-token',
      idempotencyKey: 'pay-1',
      orderId: _orderId,
    );
    expect(created.amountMinor, 8000);
    expect(captured.method, 'POST');
    expect(captured.path, '/api/v1/payments');
    expect(captured.data, {
      'order_id': _orderId,
      'payment_method': 'wallet',
    });
    expect(captured.headers['Authorization'], 'Bearer secret-token');
    expect(captured.headers['Idempotency-Key'], 'pay-1');
    expect(captured.data.toString(), isNot(contains('amount')));
  });
}

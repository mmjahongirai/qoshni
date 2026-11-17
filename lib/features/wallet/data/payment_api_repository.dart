import 'package:dio/dio.dart';
import 'package:qoshni/core/config/app_config.dart';
import 'package:qoshni/core/network/api_client.dart';
import 'package:qoshni/features/wallet/domain/payment.dart';

/// Reads and opens a wallet hold. The request body never includes an amount.
class PaymentApiRepository implements PaymentRepository {
  PaymentApiRepository({
    required ApiClient apiClient,
    required this.config,
  }) : _dio = apiClient.dio;

  final Dio _dio;
  final AppConfig config;

  @override
  Future<PaymentRecord> createWalletPayment({
    required String accessToken,
    required String idempotencyKey,
    required String orderId,
  }) {
    return _send(
      accessToken: accessToken,
      idempotencyKey: idempotencyKey,
      method: 'POST',
      path: '/api/v1/payments',
      body: {
        'order_id': orderId,
        'payment_method': 'wallet',
      },
    );
  }

  @override
  Future<PaymentRecord> getPayment({
    required String accessToken,
    required String paymentId,
  }) {
    return _send(
      accessToken: accessToken,
      method: 'GET',
      path: '/api/v1/payments/$paymentId',
    );
  }

  Future<PaymentRecord> _send({
    required String accessToken,
    required String method,
    required String path,
    String? idempotencyKey,
    Map<String, dynamic>? body,
  }) async {
    if (!config.apiConfigured || accessToken.isEmpty) {
      throw const PaymentFailure('authentication_required');
    }
    try {
      final response = await _dio.request<Map<String, dynamic>>(
        path,
        data: body,
        options: Options(
          method: method,
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Idempotency-Key': ?idempotencyKey,
          },
        ),
      );
      final data = response.data;
      if (data == null) {
        throw const PaymentFailure('malformed_response');
      }
      return PaymentRecord.fromJson(data);
    } on PaymentFailure {
      rethrow;
    } on DioException catch (error) {
      throw PaymentFailure(_code(error));
    }
  }

  String _code(DioException error) {
    final data = error.response?.data;
    if (data is Map && data['detail'] is Map) {
      final code = (data['detail'] as Map)['code'];
      if (code is String && code.isNotEmpty) {
        return code;
      }
    }
    if (data is Map && data['error'] is Map) {
      final code = (data['error'] as Map)['code'];
      if (code is String && code.isNotEmpty) {
        return code;
      }
    }
    final status = error.response?.statusCode;
    return switch (status) {
      401 => 'authentication_required',
      404 => 'payment_not_found',
      409 => 'payment_conflict',
      422 => 'validation_failed',
      _ => 'network',
    };
  }
}

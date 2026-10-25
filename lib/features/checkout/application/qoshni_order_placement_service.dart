import 'package:dio/dio.dart';
import 'package:qoshni/core/config/app_config.dart';
import 'package:qoshni/core/network/api_client.dart';
import 'package:qoshni/features/checkout/application/qoshni_checkout_controller.dart';
import 'package:qoshni/features/checkout/data/checkout_quote_dtos.dart';
import 'package:qoshni/features/checkout/data/order_placement_dtos.dart';
import 'package:qoshni/features/checkout/domain/qoshni_checkout_fulfillment_type.dart';
import 'package:qoshni/features/checkout/domain/qoshni_checkout_session.dart';
import 'package:qoshni/features/checkout/domain/qoshni_order_placement_result.dart';
import 'package:qoshni/features/checkout/domain/qoshni_price_quote.dart';
import 'package:qoshni/features/checkout/domain/qoshni_server_checkout_quote.dart';

/// Remote server order placement — never falls back to demo orders.
class QoshniOrderPlacementService {
  QoshniOrderPlacementService({
    required AppConfig appConfig,
    required ApiClient apiClient,
    required this.accessTokenProvider,
  })  : _appConfig = appConfig,
        _dio = apiClient.dio;

  final AppConfig _appConfig;
  final Dio _dio;
  final Future<String?> Function() accessTokenProvider;

  bool get isRemoteConfigured =>
      _appConfig.apiConfigured && _appConfig.apiBaseUrl.isNotEmpty;

  Future<QoshniOrderPlacementResult> tryPlaceServerOrder({
    required QoshniCheckoutController checkoutController,
    required QoshniCheckoutSession session,
    required QoshniPriceQuote pricedCartSnapshot,
    required QoshniServerCheckoutQuote serverQuote,
    required String idempotencyKey,
  }) async {
    if (!isRemoteConfigured) {
      return const QoshniOrderPlacementResult(
        outcome: QoshniOrderPlacementOutcome.unavailableBackend,
        message: 'api_not_configured',
      );
    }
    final token = await accessTokenProvider();
    if (token == null || token.isEmpty) {
      return const QoshniOrderPlacementResult(
        outcome: QoshniOrderPlacementOutcome.unauthenticated,
      );
    }

    final lines = pricedCartSnapshot.lines
        .map(
          (line) => PlaceOrderLineRequestDto(
            businessStableId: line.businessStableId,
            catalogItemStableId: line.catalogItemStableId,
            quantity: line.quantity,
          ),
        )
        .toList(growable: false);

    final body = placeOrderRequestFromServerQuote(
      serverQuote: serverQuote,
      fulfillmentType: checkoutController.fulfillment.wireValue,
      checkoutCorrelationId: session.correlationReference,
      lines: lines,
      clientSubmittedTotalMinor: pricedCartSnapshot.totalSom,
    );

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/v1/orders',
        data: body.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Idempotency-Key': idempotencyKey,
          },
        ),
      );
      final data = response.data;
      if (data == null) {
        return const QoshniOrderPlacementResult(
          outcome: QoshniOrderPlacementOutcome.validationFailed,
        );
      }
      return QoshniOrderPlacementResult(
        outcome: QoshniOrderPlacementOutcome.success,
        serverOrderId: data['order_id']?.toString(),
        idempotentReplay: data['idempotent_replay'] == true,
      );
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final code = e.response?.data is Map
          ? (e.response!.data as Map)['code']?.toString()
          : null;
      if (status == 503 && code == 'authoritative_catalog_unavailable') {
        return QoshniOrderPlacementResult(
          outcome: QoshniOrderPlacementOutcome.catalogUnavailable,
          message: code,
        );
      }
      if (status == 409) {
        return QoshniOrderPlacementResult(
          outcome: QoshniOrderPlacementOutcome.idempotencyConflict,
          message: code,
        );
      }
      if (status == 400 && code == 'insufficient_stock') {
        return const QoshniOrderPlacementResult(
          outcome: QoshniOrderPlacementOutcome.outOfStock,
        );
      }
      if (status == 400 && code == 'stale_quote') {
        return const QoshniOrderPlacementResult(
          outcome: QoshniOrderPlacementOutcome.staleQuote,
        );
      }
      return QoshniOrderPlacementResult(
        outcome: QoshniOrderPlacementOutcome.validationFailed,
        message: code ?? 'http_$status',
      );
    }
  }
}

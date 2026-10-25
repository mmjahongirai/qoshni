import 'package:dio/dio.dart';
import 'package:qoshni/core/config/app_config.dart';
import 'package:qoshni/core/network/api_client.dart';
import 'package:qoshni/features/checkout/application/qoshni_checkout_controller.dart';
import 'package:qoshni/features/checkout/data/checkout_quote_dtos.dart';
import 'package:qoshni/features/checkout/data/order_placement_dtos.dart';
import 'package:qoshni/features/checkout/domain/qoshni_checkout_fulfillment_type.dart';
import 'package:qoshni/features/checkout/domain/qoshni_checkout_session.dart';
import 'package:qoshni/features/checkout/domain/qoshni_price_quote.dart';
import 'package:qoshni/features/checkout/domain/qoshni_server_checkout_quote.dart';

enum QoshniServerQuoteIssueOutcome {
  unavailableBackend,
  unauthenticated,
  catalogUnavailable,
  validationFailed,
  success,
}

class QoshniServerQuoteIssueResult {
  const QoshniServerQuoteIssueResult({
    required this.outcome,
    this.serverQuote,
    this.message,
  });

  final QoshniServerQuoteIssueOutcome outcome;
  final QoshniServerCheckoutQuote? serverQuote;
  final String? message;
}

/// Issues authoritative server checkout quotes — separate from demo pricing.
class QoshniCheckoutQuoteService {
  QoshniCheckoutQuoteService({
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

  Future<QoshniServerQuoteIssueResult> tryIssueServerQuote({
    required QoshniCheckoutController checkoutController,
    required QoshniCheckoutSession session,
    required QoshniPriceQuote demoPricedSnapshot,
  }) async {
    if (!isRemoteConfigured) {
      return const QoshniServerQuoteIssueResult(
        outcome: QoshniServerQuoteIssueOutcome.unavailableBackend,
        message: 'api_not_configured',
      );
    }
    final token = await accessTokenProvider();
    if (token == null || token.isEmpty) {
      return const QoshniServerQuoteIssueResult(
        outcome: QoshniServerQuoteIssueOutcome.unauthenticated,
      );
    }

    final lines = demoPricedSnapshot.lines
        .map(
          (line) => PlaceOrderLineRequestDto(
            businessStableId: line.businessStableId,
            catalogItemStableId: line.catalogItemStableId,
            quantity: line.quantity,
          ),
        )
        .toList(growable: false);

    final body = CheckoutQuoteIssueRequestDto(
      fulfillmentType: checkoutController.fulfillment.wireValue,
      lines: lines,
      cartRevision: session.cartRevision,
    );

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/v1/checkout/quotes',
        data: body.toJson(),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      final data = response.data;
      if (data == null) {
        return const QoshniServerQuoteIssueResult(
          outcome: QoshniServerQuoteIssueOutcome.validationFailed,
        );
      }
      final dto = CheckoutQuoteIssueResponseDto.fromJson(data);
      return QoshniServerQuoteIssueResult(
        outcome: QoshniServerQuoteIssueOutcome.success,
        serverQuote: dto.toServerCheckoutQuote(),
      );
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final code = e.response?.data is Map
          ? (e.response!.data as Map)['code']?.toString()
          : null;
      if (status == 503 && code == 'authoritative_catalog_unavailable') {
        return QoshniServerQuoteIssueResult(
          outcome: QoshniServerQuoteIssueOutcome.catalogUnavailable,
          message: code,
        );
      }
      return QoshniServerQuoteIssueResult(
        outcome: QoshniServerQuoteIssueOutcome.validationFailed,
        message: code ?? 'http_$status',
      );
    }
  }
}

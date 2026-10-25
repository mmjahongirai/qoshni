import 'package:qoshni/features/checkout/data/order_placement_dtos.dart';
import 'package:qoshni/features/checkout/domain/qoshni_server_checkout_quote.dart';

class CheckoutQuoteIssueRequestDto {
  const CheckoutQuoteIssueRequestDto({
    required this.fulfillmentType,
    required this.lines,
    this.cartRevision,
  });

  final String fulfillmentType;
  final List<PlaceOrderLineRequestDto> lines;
  final int? cartRevision;

  Map<String, dynamic> toJson() => {
        'fulfillment_type': fulfillmentType,
        'lines': lines.map((l) => l.toJson()).toList(),
        if (cartRevision != null) 'cart_revision': cartRevision,
      };
}

/// Matches backend `CheckoutQuoteIssueResponse`.
class CheckoutQuoteIssueResponseDto {
  const CheckoutQuoteIssueResponseDto({
    required this.quoteId,
    required this.pricingRevision,
    required this.expiresAt,
    required this.currencyCode,
    required this.totalMinor,
  });

  factory CheckoutQuoteIssueResponseDto.fromJson(Map<String, dynamic> json) {
    return CheckoutQuoteIssueResponseDto(
      quoteId: json['quote_id']?.toString() ?? '',
      pricingRevision: (json['pricing_revision'] as num?)?.toInt() ?? 0,
      expiresAt: DateTime.parse(json['expires_at'] as String),
      currencyCode: json['currency_code']?.toString() ?? '',
      totalMinor: (json['total_minor'] as num?)?.toInt() ?? 0,
    );
  }

  final String quoteId;
  final int pricingRevision;
  final DateTime expiresAt;
  final String currencyCode;
  final int totalMinor;

  QoshniServerCheckoutQuote toServerCheckoutQuote() {
    return QoshniServerCheckoutQuote(
      quoteId: quoteId,
      pricingRevision: pricingRevision,
    );
  }
}

/// Maps server quote credentials into the place-order wire contract.
PlaceOrderRequestDto placeOrderRequestFromServerQuote({
  required QoshniServerCheckoutQuote serverQuote,
  required String fulfillmentType,
  required String checkoutCorrelationId,
  required List<PlaceOrderLineRequestDto> lines,
  int? clientSubmittedTotalMinor,
}) {
  return PlaceOrderRequestDto(
    fulfillmentType: fulfillmentType,
    checkoutCorrelationId: checkoutCorrelationId,
    serverQuoteId: serverQuote.quoteId,
    serverQuoteRevision: serverQuote.pricingRevision,
    lines: lines,
    clientSubmittedTotalMinor: clientSubmittedTotalMinor,
  );
}

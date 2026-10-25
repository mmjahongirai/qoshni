import 'package:qoshni/features/checkout/domain/qoshni_checkout_fulfillment_type.dart';
import 'package:qoshni/features/checkout/domain/qoshni_price_quote.dart';

enum QoshniCheckoutSessionStatus {
  /// Session created but no successful quote yet.
  draft,

  /// Quote matches current cart revision.
  priced,

  /// Cart changed after quote; must recalculate before place-order (future WP).
  stale,

  /// Validation failed (empty cart, unsupported fulfillment, pricing error).
  invalid,
}

class QoshniCheckoutSession {
  const QoshniCheckoutSession({
    required this.sessionId,
    required this.correlationReference,
    required this.cartId,
    required this.cartRevision,
    required this.fulfillmentType,
    required this.status,
    required this.updatedAt,
    this.quote,
    this.validationMessage,
  });

  final String sessionId;
  final String correlationReference;
  final String cartId;
  final int cartRevision;
  final QoshniCheckoutFulfillmentType fulfillmentType;
  final QoshniCheckoutSessionStatus status;
  final DateTime updatedAt;
  final QoshniPriceQuote? quote;
  final String? validationMessage;

  bool get isReadyForDemoReview =>
      status == QoshniCheckoutSessionStatus.priced && quote != null;

  bool get impliesOrderPlaced => false;
}

import 'package:qoshni/features/checkout/domain/qoshni_checkout_limits.dart';

/// Immutable priced snapshot for checkout preparation (not an order record).
class QoshniPriceLineSnapshot {
  const QoshniPriceLineSnapshot({
    required this.businessStableId,
    required this.catalogItemStableId,
    required this.titleSnapshot,
    required this.businessTitleSnapshot,
    required this.quantity,
    required this.unitPriceSom,
    required this.lineSubtotalSom,
    required this.currencyCode,
    required this.isDemoPricing,
  });

  final String businessStableId;
  final String catalogItemStableId;
  final String titleSnapshot;
  final String businessTitleSnapshot;
  final int quantity;
  final int unitPriceSom;
  final int lineSubtotalSom;
  final String currencyCode;
  final bool isDemoPricing;
}

class QoshniPriceQuote {
  const QoshniPriceQuote({
    required this.quoteId,
    required this.cartRevision,
    required this.quotedAt,
    required this.currencyCode,
    required this.lines,
    required this.subtotalSom,
    required this.discountSom,
    required this.deliveryFeeSom,
    required this.taxSom,
    required this.totalSom,
    required this.isDemoPricing,
  });

  final String quoteId;
  final int cartRevision;
  final DateTime quotedAt;
  final String currencyCode;
  final List<QoshniPriceLineSnapshot> lines;
  final int subtotalSom;
  final int discountSom;
  final int deliveryFeeSom;
  final int taxSom;
  final int totalSom;
  final bool isDemoPricing;

  bool get isAuthoritativeBackend => !isDemoPricing;
}

int sumLineSubtotalsSom(List<QoshniPriceLineSnapshot> lines) {
  var total = 0;
  for (final line in lines) {
    final next = total + line.lineSubtotalSom;
    if (next > kQoshniCheckoutMaxCartTotalSom) {
      throw StateError('Cart subtotal overflow');
    }
    total = next;
  }
  return total;
}

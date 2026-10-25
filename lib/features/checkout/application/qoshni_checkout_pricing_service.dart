import 'package:flutter/material.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/features/checkout/application/qoshni_consumer_catalog_line.dart';
import 'package:qoshni/features/checkout/domain/qoshni_cart_item.dart';
import 'package:qoshni/features/checkout/domain/qoshni_checkout_limits.dart';
import 'package:qoshni/features/checkout/domain/qoshni_price_quote.dart';
import 'package:qoshni/features/checkout/domain/qoshni_universal_cart.dart';
import 'package:qoshni/features/home/presentation/data/business_catalog_mock_data.dart';

enum QoshniCheckoutPricingResultKind {
  success,
  emptyCart,
  staleCatalogLine,
  invalidClientTotalIgnored,
  subtotalOverflow,
  negativeUnitPrice,
}

class QoshniCheckoutPricingResult {
  const QoshniCheckoutPricingResult.success(this.quote)
      : kind = QoshniCheckoutPricingResultKind.success,
        clientTotalIgnored = null;

  const QoshniCheckoutPricingResult.failure(
    this.kind, {
    this.clientTotalIgnored,
  }) : quote = null;

  final QoshniCheckoutPricingResultKind kind;
  final QoshniPriceQuote? quote;
  final int? clientTotalIgnored;
}

/// Server-style pricing calculator for the consumer demo catalog (integer UZS som).
class QoshniCheckoutPricingService {
  QoshniCheckoutPricingResult quoteCart({
    required AppLocalizations l10n,
    required ColorScheme colorScheme,
    required QoshniUniversalCart cart,
    int? clientSubmittedTotalSom,
  }) {
    if (clientSubmittedTotalSom != null && clientSubmittedTotalSom < 0) {
      return const QoshniCheckoutPricingResult.failure(
        QoshniCheckoutPricingResultKind.invalidClientTotalIgnored,
      );
    }

    final linesInOrder = cart.linesInOrder;
    if (linesInOrder.isEmpty) {
      return const QoshniCheckoutPricingResult.failure(
        QoshniCheckoutPricingResultKind.emptyCart,
      );
    }

    final snapshots = <QoshniPriceLineSnapshot>[];
    for (final item in linesInOrder) {
      final resolved = resolveConsumerCatalogLine(
        l10n: l10n,
        colorScheme: colorScheme,
        businessId: item.reference.businessId,
        catalogItemId: item.reference.catalogItemId,
      );
      if (resolved.status != QoshniConsumerCatalogResolveStatus.found ||
          resolved.line == null) {
        return const QoshniCheckoutPricingResult.failure(
          QoshniCheckoutPricingResultKind.staleCatalogLine,
        );
      }
      final line = resolved.line!;
      if (line.unitPriceSom < 0) {
        return const QoshniCheckoutPricingResult.failure(
          QoshniCheckoutPricingResultKind.negativeUnitPrice,
        );
      }
      final subtotal = line.unitPriceSom * item.quantity;
      if (subtotal < 0 || subtotal > kQoshniCheckoutMaxLineSubtotalSom) {
        return const QoshniCheckoutPricingResult.failure(
          QoshniCheckoutPricingResultKind.subtotalOverflow,
        );
      }
      snapshots.add(
        QoshniPriceLineSnapshot(
          businessStableId: item.reference.businessStableId,
          catalogItemStableId: item.reference.catalogItemStableId,
          titleSnapshot: line.catalogItem.name,
          businessTitleSnapshot: line.businessName,
          quantity: item.quantity,
          unitPriceSom: line.unitPriceSom,
          lineSubtotalSom: subtotal,
          currencyCode: kQoshniCheckoutCurrencyUzs,
          isDemoPricing: true,
        ),
      );
    }

    final subtotalSom = sumLineSubtotalsSom(snapshots);
    const discountSom = 0;
    const deliveryFeeSom = 0;
    const taxSom = 0;
    final totalSom = subtotalSom - discountSom + deliveryFeeSom + taxSom;
    if (totalSom < 0 || totalSom > kQoshniCheckoutMaxCartTotalSom) {
      return const QoshniCheckoutPricingResult.failure(
        QoshniCheckoutPricingResultKind.subtotalOverflow,
      );
    }

    final quotedAt = DateTime.now().toUtc();
    final quote = QoshniPriceQuote(
      quoteId: 'quote-${quotedAt.microsecondsSinceEpoch}',
      cartRevision: cart.revision,
      quotedAt: quotedAt,
      currencyCode: kQoshniCheckoutCurrencyUzs,
      lines: List.unmodifiable(snapshots),
      subtotalSom: subtotalSom,
      discountSom: discountSom,
      deliveryFeeSom: deliveryFeeSom,
      taxSom: taxSom,
      totalSom: totalSom,
      isDemoPricing: true,
    );

    return QoshniCheckoutPricingResult.success(quote);
  }

  /// Demonstrates that client totals are never authoritative.
  bool clientTotalMatchesQuote({
    required int clientTotalSom,
    required QoshniPriceQuote quote,
  }) {
    return clientTotalSom == quote.totalSom;
  }
}

List<CatalogItemKind> catalogKindsForCartItems(
  List<QoshniCartItem> items,
  AppLocalizations l10n,
  ColorScheme colorScheme,
) {
  final kinds = <CatalogItemKind>[];
  for (final item in items) {
    final resolved = resolveConsumerCatalogLine(
      l10n: l10n,
      colorScheme: colorScheme,
      businessId: item.reference.businessId,
      catalogItemId: item.reference.catalogItemId,
    );
    if (resolved.line != null) {
      kinds.add(resolved.line!.catalogItem.kind);
    }
  }
  return kinds;
}

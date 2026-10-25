import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/features/checkout/application/qoshni_cart_service.dart';
import 'package:qoshni/features/checkout/application/qoshni_checkout_pricing_service.dart';
import 'package:qoshni/features/checkout/application/qoshni_consumer_catalog_line.dart';
import 'package:qoshni/features/checkout/domain/qoshni_cart_line_reference.dart';
import 'package:qoshni/features/checkout/domain/qoshni_price_quote.dart';
import 'package:qoshni/features/checkout/domain/qoshni_universal_cart.dart';
import 'package:qoshni/features/home/presentation/cart/cart_line_key.dart';
import 'package:qoshni/features/home/presentation/cart/demo_order_snapshot.dart';
import 'package:qoshni/features/home/presentation/data/business_catalog_mock_data.dart';
import 'package:qoshni/features/home/presentation/data/mock_business_id.dart';
import 'package:qoshni/features/home/presentation/data/mock_catalog_item_id.dart';

class ResolvedCartLine {
  const ResolvedCartLine({
    required this.key,
    required this.quantity,
    required this.catalogItem,
    required this.businessName,
    required this.unitPriceUzs,
  });

  final CartLineKey key;
  final int quantity;
  final BusinessCatalogItem catalogItem;
  final String businessName;
  final int unitPriceUzs;

  int get subtotalUzs => unitPriceUzs * quantity;
}

/// Facade over [QoshniCartService] for existing Home cart UI.
class CartController extends ChangeNotifier {
  CartController({
    required QoshniCartService cartService,
    required QoshniCheckoutPricingService pricingService,
  })  : _cartService = cartService,
        _pricingService = pricingService {
    _cartService.addListener(_forwardNotify);
  }

  final QoshniCartService _cartService;
  final QoshniCheckoutPricingService _pricingService;

  @override
  void dispose() {
    _cartService.removeListener(_forwardNotify);
    super.dispose();
  }

  void _forwardNotify() => notifyListeners();

  int get totalUnitCount => _cartService.cart.totalUnitCount;

  bool get isEmpty => _cartService.isEmpty;

  List<CartLineKey> get lineKeys => _cartService.lineOrder;

  int quantityFor(CartLineKey key) => _cartService.quantityFor(key);

  bool addCatalogItem({
    required AppLocalizations l10n,
    required MockBusinessId businessId,
    required MockCatalogItemId catalogItemId,
  }) {
    final probe = resolveConsumerCatalogLine(
      l10n: l10n,
      colorScheme: const ColorScheme.light(),
      businessId: businessId,
      catalogItemId: catalogItemId,
    );
    if (probe.status != QoshniConsumerCatalogResolveStatus.found) {
      return false;
    }

    final result = _cartService.addLine(
      businessId: businessId,
      catalogItemId: catalogItemId,
    );
    return result == QoshniCartMutationResult.success;
  }

  void incrementQuantity(CartLineKey key) {
    _cartService.incrementQuantity(key);
  }

  void decrementQuantity(CartLineKey key) {
    _cartService.decrementQuantity(key);
  }

  void removeLine(CartLineKey key) {
    _cartService.removeLine(key);
  }

  void clear() {
    _cartService.clear();
  }

  List<ResolvedCartLine> resolveLines(
    AppLocalizations l10n,
    ColorScheme colorScheme,
  ) {
    final lines = <ResolvedCartLine>[];
    final staleKeys = <QoshniCartLineReference>{};

    for (final item in _cartService.cart.linesInOrder) {
      final key = item.reference;
      final resolved = resolveConsumerCatalogLine(
        l10n: l10n,
        colorScheme: colorScheme,
        businessId: key.businessId,
        catalogItemId: key.catalogItemId,
      );
      if (resolved.status != QoshniConsumerCatalogResolveStatus.found ||
          resolved.line == null) {
        staleKeys.add(key);
        continue;
      }
      final line = resolved.line!;
      lines.add(
        ResolvedCartLine(
          key: key,
          quantity: item.quantity,
          catalogItem: line.catalogItem,
          businessName: line.businessName,
          unitPriceUzs: line.unitPriceSom,
        ),
      );
    }

    if (staleKeys.isNotEmpty) {
      _cartService.purgeInvalidReferences(staleKeys);
    }

    return lines;
  }

  int estimatedTotalUzs(AppLocalizations l10n, ColorScheme colorScheme) {
    final quote = _pricingService.quoteCart(
      l10n: l10n,
      colorScheme: colorScheme,
      cart: _cartService.cart,
    );
    return quote.quote?.totalSom ?? 0;
  }

  QoshniPriceQuote? priceQuote(AppLocalizations l10n, ColorScheme colorScheme) {
    final result = _pricingService.quoteCart(
      l10n: l10n,
      colorScheme: colorScheme,
      cart: _cartService.cart,
    );
    return result.quote;
  }

  DemoOrderSnapshot? buildDemoOrderSnapshot(
    AppLocalizations l10n,
    ColorScheme colorScheme, {
    QoshniPriceQuote? authoritativeQuote,
  }) {
    final quote = authoritativeQuote ??
        _pricingService
            .quoteCart(
              l10n: l10n,
              colorScheme: colorScheme,
              cart: _cartService.cart,
            )
            .quote;
    if (quote == null || quote.lines.isEmpty) {
      return null;
    }

    return DemoOrderSnapshot.fromPriceQuote(quote: quote);
  }
}

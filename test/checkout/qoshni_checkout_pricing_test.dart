import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/features/checkout/application/qoshni_cart_service.dart';
import 'package:qoshni/features/checkout/application/qoshni_checkout_pricing_service.dart';
import 'package:qoshni/features/checkout/domain/qoshni_checkout_limits.dart';
import 'package:qoshni/features/checkout/domain/qoshni_universal_cart.dart';
import 'package:qoshni/features/home/presentation/data/mock_business_id.dart';
import 'package:qoshni/features/home/presentation/data/mock_catalog_item_id.dart';
import 'package:qoshni/core/localization/generated/app_localizations_en.dart';

void main() {
  final l10n = AppLocalizationsEn();
  const scheme = ColorScheme.light();
  final pricing = QoshniCheckoutPricingService();
  final cartService = QoshniCartService();

  test('integer line subtotals and total in UZS som', () {
    cartService.addLine(
      businessId: MockBusinessId.barakaMarket,
      catalogItemId: MockCatalogItemId.barakaFreshBread,
    );
    cartService.setQuantity(
      cartService.lineOrder.single,
      3,
    );

    final result = pricing.quoteCart(
      l10n: l10n,
      colorScheme: scheme,
      cart: cartService.cart,
    );
    expect(result.quote, isNotNull);
    expect(result.quote!.currencyCode, kQoshniCheckoutCurrencyUzs);
    expect(result.quote!.lines.single.lineSubtotalSom, 8000 * 3);
    expect(result.quote!.totalSom, 8000 * 3);
    expect(result.quote!.discountSom, 0);
    expect(result.quote!.taxSom, 0);
    expect(result.quote!.deliveryFeeSom, 0);
  });

  test('client submitted total is not authoritative', () {
    cartService.clear();
    cartService.addLine(
      businessId: MockBusinessId.barakaMarket,
      catalogItemId: MockCatalogItemId.barakaFreshBread,
    );
    final result = pricing.quoteCart(
      l10n: l10n,
      colorScheme: scheme,
      cart: cartService.cart,
      clientSubmittedTotalSom: 1,
    );
    expect(result.quote!.totalSom, 8000);
    expect(
      pricing.clientTotalMatchesQuote(
        clientTotalSom: 1,
        quote: result.quote!,
      ),
      isFalse,
    );
  });

  test('rejects negative client total', () {
    final result = pricing.quoteCart(
      l10n: l10n,
      colorScheme: scheme,
      cart: QoshniUniversalCart.empty(),
      clientSubmittedTotalSom: -1,
    );
    expect(result.kind.name, 'invalidClientTotalIgnored');
  });

  test('snapshot stable when cart revision captured', () {
    cartService.clear();
    cartService.addLine(
      businessId: MockBusinessId.barakaMarket,
      catalogItemId: MockCatalogItemId.barakaFreshBread,
    );
    final first = pricing.quoteCart(
      l10n: l10n,
      colorScheme: scheme,
      cart: cartService.cart,
    ).quote!;
    cartService.incrementQuantity(cartService.lineOrder.single);
    final second = pricing.quoteCart(
      l10n: l10n,
      colorScheme: scheme,
      cart: cartService.cart,
    ).quote!;
    expect(first.cartRevision, isNot(second.cartRevision));
    expect(first.totalSom, 8000);
    expect(second.totalSom, 16000);
  });
}

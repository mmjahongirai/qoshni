import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/features/checkout/application/qoshni_cart_service.dart';
import 'package:qoshni/features/checkout/application/qoshni_checkout_pricing_service.dart';
import 'package:qoshni/features/checkout/application/qoshni_checkout_session_service.dart';
import 'package:qoshni/features/checkout/domain/qoshni_checkout_fulfillment_type.dart';
import 'package:qoshni/features/checkout/domain/qoshni_checkout_session.dart';
import 'package:qoshni/features/home/presentation/data/mock_business_id.dart';
import 'package:qoshni/features/home/presentation/data/mock_catalog_item_id.dart';
import 'package:qoshni/core/localization/generated/app_localizations_en.dart';

void main() {
  final l10n = AppLocalizationsEn();
  const scheme = ColorScheme.light();

  test('empty cart rejected', () {
    final sessionService = QoshniCheckoutSessionService(
      cartService: QoshniCartService(),
      pricingService: QoshniCheckoutPricingService(),
    );
    final session = sessionService.prepare(
      l10n: l10n,
      colorScheme: scheme,
      fulfillment: QoshniCheckoutFulfillmentType.pickup,
    );
    expect(session.status, QoshniCheckoutSessionStatus.invalid);
  });

  test('priced session becomes stale after cart change', () {
    final cart = QoshniCartService();
    cart.addLine(
      businessId: MockBusinessId.barakaMarket,
      catalogItemId: MockCatalogItemId.barakaFreshBread,
    );
    final sessionService = QoshniCheckoutSessionService(
      cartService: cart,
      pricingService: QoshniCheckoutPricingService(),
    );
    final priced = sessionService.prepare(
      l10n: l10n,
      colorScheme: scheme,
      fulfillment: QoshniCheckoutFulfillmentType.pickup,
    );
    expect(priced.status, QoshniCheckoutSessionStatus.priced);
    cart.incrementQuantity(cart.lineOrder.single);
    sessionService.invalidateIfCartChanged();
    expect(
      sessionService.activeSession!.status,
      QoshniCheckoutSessionStatus.stale,
    );
  });

  test('delivery rejected for service-only cart', () {
    final cart = QoshniCartService();
    cart.addLine(
      businessId: MockBusinessId.samplePipeFix,
      catalogItemId: MockCatalogItemId.pipeLeakVisit,
    );
    final sessionService = QoshniCheckoutSessionService(
      cartService: cart,
      pricingService: QoshniCheckoutPricingService(),
    );
    final session = sessionService.prepare(
      l10n: l10n,
      colorScheme: scheme,
      fulfillment: QoshniCheckoutFulfillmentType.delivery,
    );
    expect(session.status, QoshniCheckoutSessionStatus.invalid);
  });

  test('repeated prepare is deterministic for unchanged cart', () {
    final cart = QoshniCartService();
    cart.addLine(
      businessId: MockBusinessId.barakaMarket,
      catalogItemId: MockCatalogItemId.barakaFreshBread,
    );
    final sessionService = QoshniCheckoutSessionService(
      cartService: cart,
      pricingService: QoshniCheckoutPricingService(),
    );
    final first = sessionService.prepare(
      l10n: l10n,
      colorScheme: scheme,
      fulfillment: QoshniCheckoutFulfillmentType.pickup,
    );
    final second = sessionService.prepare(
      l10n: l10n,
      colorScheme: scheme,
      fulfillment: QoshniCheckoutFulfillmentType.pickup,
    );
    expect(first.totalUnits, second.totalUnits);
    expect(first.quote!.totalSom, second.quote!.totalSom);
  });
}

extension on QoshniCheckoutSession {
  int get totalUnits => quote?.lines.fold<int>(0, (s, l) => s + l.quantity) ?? 0;
}

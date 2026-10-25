import 'package:flutter/material.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/features/checkout/application/qoshni_cart_service.dart';
import 'package:qoshni/features/checkout/application/qoshni_checkout_fulfillment_validator.dart';
import 'package:qoshni/features/checkout/application/qoshni_checkout_pricing_service.dart';
import 'package:qoshni/features/checkout/domain/qoshni_checkout_fulfillment_type.dart';
import 'package:qoshni/features/checkout/domain/qoshni_checkout_session.dart';
import 'package:qoshni/features/checkout/domain/qoshni_universal_cart.dart';

/// Prepares priced checkout sessions; does not place orders or capture payment.
class QoshniCheckoutSessionService {
  QoshniCheckoutSessionService({
    required QoshniCartService cartService,
    required QoshniCheckoutPricingService pricingService,
  })  : _cartService = cartService,
        _pricingService = pricingService;

  final QoshniCartService _cartService;
  final QoshniCheckoutPricingService _pricingService;

  QoshniCheckoutSession? _activeSession;

  QoshniCheckoutSession? get activeSession => _activeSession;

  void invalidateIfCartChanged() {
    final session = _activeSession;
    if (session == null) {
      return;
    }
    if (session.cartRevision != _cartService.revision ||
        session.cartId != _cartService.cart.cartId) {
      _activeSession = QoshniCheckoutSession(
        sessionId: session.sessionId,
        correlationReference: session.correlationReference,
        cartId: _cartService.cart.cartId,
        cartRevision: _cartService.revision,
        fulfillmentType: session.fulfillmentType,
        status: QoshniCheckoutSessionStatus.stale,
        updatedAt: DateTime.now().toUtc(),
        quote: session.quote,
        validationMessage: 'cart_revision_changed',
      );
    }
  }

  QoshniCheckoutSession prepare({
    required AppLocalizations l10n,
    required ColorScheme colorScheme,
    required QoshniCheckoutFulfillmentType fulfillment,
    int? clientSubmittedTotalSom,
  }) {
    final cart = _cartService.cart;
    final correlation =
        'chk-${DateTime.now().toUtc().millisecondsSinceEpoch.toRadixString(36)}';
    final sessionId = _activeSession?.sessionId ??
        'session-${DateTime.now().toUtc().microsecondsSinceEpoch}';

    if (cart.isEmpty) {
      _activeSession = QoshniCheckoutSession(
        sessionId: sessionId,
        correlationReference: correlation,
        cartId: cart.cartId,
        cartRevision: cart.revision,
        fulfillmentType: fulfillment,
        status: QoshniCheckoutSessionStatus.invalid,
        updatedAt: DateTime.now().toUtc(),
        validationMessage: 'empty_cart',
      );
      return _activeSession!;
    }

    final kinds = catalogKindsForCartItems(
      cart.linesInOrder,
      l10n,
      colorScheme,
    );
    final fulfillmentValidation = validateCheckoutFulfillment(
      fulfillment: fulfillment,
      catalogItemKinds: kinds,
    );
    if (fulfillmentValidation != QoshniCheckoutFulfillmentValidation.supported) {
      _activeSession = QoshniCheckoutSession(
        sessionId: sessionId,
        correlationReference: correlation,
        cartId: cart.cartId,
        cartRevision: cart.revision,
        fulfillmentType: fulfillment,
        status: QoshniCheckoutSessionStatus.invalid,
        updatedAt: DateTime.now().toUtc(),
        validationMessage: fulfillmentValidation.name,
      );
      return _activeSession!;
    }

    final pricing = _pricingService.quoteCart(
      l10n: l10n,
      colorScheme: colorScheme,
      cart: cart,
      clientSubmittedTotalSom: clientSubmittedTotalSom,
    );

    if (pricing.kind != QoshniCheckoutPricingResultKind.success ||
        pricing.quote == null) {
      _activeSession = QoshniCheckoutSession(
        sessionId: sessionId,
        correlationReference: correlation,
        cartId: cart.cartId,
        cartRevision: cart.revision,
        fulfillmentType: fulfillment,
        status: QoshniCheckoutSessionStatus.invalid,
        updatedAt: DateTime.now().toUtc(),
        validationMessage: pricing.kind.name,
      );
      return _activeSession!;
    }

    _activeSession = QoshniCheckoutSession(
      sessionId: sessionId,
      correlationReference: correlation,
      cartId: cart.cartId,
      cartRevision: cart.revision,
      fulfillmentType: fulfillment,
      status: QoshniCheckoutSessionStatus.priced,
      updatedAt: DateTime.now().toUtc(),
      quote: pricing.quote,
    );
    return _activeSession!;
  }
}

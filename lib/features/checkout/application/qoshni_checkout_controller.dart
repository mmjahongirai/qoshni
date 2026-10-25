import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/features/checkout/application/qoshni_cart_service.dart';
import 'package:qoshni/features/checkout/application/qoshni_checkout_session_service.dart';
import 'package:qoshni/features/checkout/domain/qoshni_checkout_fulfillment_type.dart';
import 'package:qoshni/features/checkout/domain/qoshni_checkout_session.dart';

/// UI-facing checkout preparation state (distinct from demo order confirmation).
class QoshniCheckoutController extends ChangeNotifier {
  QoshniCheckoutController({
    required QoshniCartService cartService,
    required QoshniCheckoutSessionService sessionService,
  })  : _cartService = cartService,
        _sessionService = sessionService {
    _cartService.addListener(_onCartChanged);
  }

  final QoshniCartService _cartService;
  final QoshniCheckoutSessionService _sessionService;

  QoshniCheckoutFulfillmentType _fulfillment =
      QoshniCheckoutFulfillmentType.pickup;

  QoshniCheckoutFulfillmentType get fulfillment => _fulfillment;

  QoshniCheckoutSession? get session => _sessionService.activeSession;

  @override
  void dispose() {
    _cartService.removeListener(_onCartChanged);
    super.dispose();
  }

  void _onCartChanged() {
    _sessionService.invalidateIfCartChanged();
    notifyListeners();
  }

  void setFulfillment(QoshniCheckoutFulfillmentType value) {
    if (_fulfillment == value) {
      return;
    }
    _fulfillment = value;
    notifyListeners();
  }

  QoshniCheckoutSession preparePricing({
    required AppLocalizations l10n,
    required ColorScheme colorScheme,
    int? clientSubmittedTotalSom,
  }) {
    final result = _sessionService.prepare(
      l10n: l10n,
      colorScheme: colorScheme,
      fulfillment: _fulfillment,
      clientSubmittedTotalSom: clientSubmittedTotalSom,
    );
    notifyListeners();
    return result;
  }
}

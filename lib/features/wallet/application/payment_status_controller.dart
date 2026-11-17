import 'package:flutter/foundation.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/features/wallet/domain/payment.dart';

/// Loads one server payment. It does not calculate or submit an amount.
class PaymentStatusController extends ChangeNotifier {
  PaymentStatusController(this._repository);

  final PaymentRepository _repository;

  PaymentRecord? payment;
  PaymentFailure? failure;
  bool loading = false;

  Future<bool> load({
    required String accessToken,
    required String paymentId,
  }) async {
    loading = true;
    failure = null;
    notifyListeners();
    try {
      payment = await _repository.getPayment(
        accessToken: accessToken,
        paymentId: paymentId,
      );
      return true;
    } on PaymentFailure catch (error) {
      failure = error;
      payment = null;
      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  String? statusLabel(AppLocalizations l10n) {
    return switch (payment?.status) {
      'pending' => l10n.paymentStatusPending,
      'held' => l10n.paymentStatusHeld,
      'failed' => l10n.paymentStatusFailed,
      'released' => l10n.paymentStatusReleased,
      null => null,
      _ => l10n.paymentStatusUnknown,
    };
  }
}

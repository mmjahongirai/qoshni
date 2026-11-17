/// Server payment read model. Amounts stay integer minor units from the server.
class PaymentRecord {
  const PaymentRecord({
    required this.paymentId,
    required this.orderId,
    required this.amountMinor,
    required this.currencyCode,
    required this.status,
    required this.holdId,
    required this.createdAt,
    required this.idempotentReplay,
  });

  final String paymentId;
  final String orderId;
  final int amountMinor;
  final String currencyCode;
  final String status;
  final String holdId;
  final DateTime createdAt;
  final bool idempotentReplay;

  factory PaymentRecord.fromJson(Map<String, dynamic> json) {
    final amount = json['amount_minor'];
    if (amount is! int) {
      throw const PaymentFailure('malformed_response');
    }
    return PaymentRecord(
      paymentId: json['payment_id'].toString(),
      orderId: json['order_id'].toString(),
      amountMinor: amount,
      currencyCode: json['currency_code'].toString(),
      status: json['status'].toString(),
      holdId: json['hold_id'].toString(),
      createdAt: DateTime.parse(json['created_at'].toString()),
      idempotentReplay: json['idempotent_replay'] == true,
    );
  }
}

class PaymentFailure implements Exception {
  const PaymentFailure(this.code);

  final String code;

  @override
  String toString() => 'PaymentFailure($code)';
}

abstract class PaymentRepository {
  Future<PaymentRecord> createWalletPayment({
    required String accessToken,
    required String idempotencyKey,
    required String orderId,
  });

  Future<PaymentRecord> getPayment({
    required String accessToken,
    required String paymentId,
  });
}

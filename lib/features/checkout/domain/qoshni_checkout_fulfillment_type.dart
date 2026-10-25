/// Checkout fulfillment request (consumer path; distinct from Business Center config drafts).
enum QoshniCheckoutFulfillmentType {
  pickup,
  delivery,
  serviceAtLocation,
}

extension QoshniCheckoutFulfillmentTypeCodec on QoshniCheckoutFulfillmentType {
  String get wireValue {
    switch (this) {
      case QoshniCheckoutFulfillmentType.pickup:
        return 'pickup';
      case QoshniCheckoutFulfillmentType.delivery:
        return 'delivery';
      case QoshniCheckoutFulfillmentType.serviceAtLocation:
        return 'service_at_location';
    }
  }

  static QoshniCheckoutFulfillmentType? tryParse(String? raw) {
    if (raw == null || raw.isEmpty) {
      return null;
    }
    for (final value in QoshniCheckoutFulfillmentType.values) {
      if (value.wireValue == raw) {
        return value;
      }
    }
    return null;
  }
}

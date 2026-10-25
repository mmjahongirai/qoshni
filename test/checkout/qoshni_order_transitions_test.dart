import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/features/checkout/domain/qoshni_order_placement_result.dart';

void main() {
  test('demo order result is never server confirmed', () {
    const unavailable = QoshniOrderPlacementResult(
      outcome: QoshniOrderPlacementOutcome.catalogUnavailable,
    );
    expect(unavailable.isServerConfirmed, isFalse);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/features/checkout/domain/qoshni_order_placement_result.dart';

void main() {
  test('server confirmed requires success outcome and order id', () {
    const ok = QoshniOrderPlacementResult(
      outcome: QoshniOrderPlacementOutcome.success,
      serverOrderId: 'abc',
    );
    expect(ok.isServerConfirmed, isTrue);

    const demo = QoshniOrderPlacementResult(
      outcome: QoshniOrderPlacementOutcome.catalogUnavailable,
    );
    expect(demo.isServerConfirmed, isFalse);
  });
}

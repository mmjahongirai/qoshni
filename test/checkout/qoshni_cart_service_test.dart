import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/features/checkout/application/qoshni_cart_service.dart';
import 'package:qoshni/features/checkout/domain/qoshni_checkout_limits.dart';
import 'package:qoshni/features/checkout/domain/qoshni_universal_cart.dart';
import 'package:qoshni/features/home/presentation/data/mock_business_id.dart';
import 'package:qoshni/features/home/presentation/data/mock_catalog_item_id.dart';

void main() {
  late QoshniCartService cart;

  setUp(() {
    cart = QoshniCartService();
  });

  test('add update remove lines', () {
    final result = cart.addLine(
      businessId: MockBusinessId.barakaMarket,
      catalogItemId: MockCatalogItemId.barakaFreshBread,
    );
    expect(result, QoshniCartMutationResult.success);
    expect(cart.cart.totalUnitCount, 1);
    cart.incrementQuantity(cart.lineOrder.single);
    expect(cart.cart.totalUnitCount, 2);
    cart.decrementQuantity(cart.lineOrder.single);
    expect(cart.cart.totalUnitCount, 1);
    cart.removeLine(cart.lineOrder.single);
    expect(cart.isEmpty, isTrue);
  });

  test('rejects invalid quantity', () {
    cart.addLine(
      businessId: MockBusinessId.barakaMarket,
      catalogItemId: MockCatalogItemId.barakaFreshBread,
    );
    final key = cart.lineOrder.single;
    final result = cart.setQuantity(key, kQoshniCartMaxLineQuantity + 1);
    expect(result, QoshniCartMutationResult.invalidQuantity);
  });

  test('cart revision increments and is distinct from order state', () {
    expect(cart.cart.revision, 0);
    cart.addLine(
      businessId: MockBusinessId.barakaMarket,
      catalogItemId: MockCatalogItemId.barakaFreshBread,
    );
    expect(cart.revision, greaterThan(0));
  });
}

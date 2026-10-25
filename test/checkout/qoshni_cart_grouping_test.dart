import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/features/checkout/domain/qoshni_cart_business_group.dart';
import 'package:qoshni/features/checkout/domain/qoshni_cart_item.dart';
import 'package:qoshni/features/checkout/domain/qoshni_cart_line_reference.dart';
import 'package:qoshni/features/home/presentation/data/mock_business_id.dart';
import 'package:qoshni/features/home/presentation/data/mock_catalog_item_id.dart';

void main() {
  test('groups by stable business id deterministically', () {
    final lines = [
      QoshniCartItem(
        reference: QoshniCartLineReference(
          businessId: MockBusinessId.samarkandCafe,
          catalogItemId: MockCatalogItemId.samarkandPlov,
        ),
        quantity: 1,
      ),
      QoshniCartItem(
        reference: QoshniCartLineReference(
          businessId: MockBusinessId.barakaMarket,
          catalogItemId: MockCatalogItemId.barakaFreshBread,
        ),
        quantity: 2,
      ),
      QoshniCartItem(
        reference: QoshniCartLineReference(
          businessId: MockBusinessId.barakaMarket,
          catalogItemId: MockCatalogItemId.barakaDailyBasket,
        ),
        quantity: 1,
      ),
    ];

    final groups = groupCartItemsByBusiness(lines);
    expect(groups.map((g) => g.businessStableId).toList(), [
      'baraka-market',
      'samarkand-cafe',
    ]);
    expect(groups.first.items.length, 2);
    expect(groups.last.items.single.reference.catalogItemId,
        MockCatalogItemId.samarkandPlov);
  });

  test('does not merge identical names across businesses', () {
    final a = QoshniCartItem(
      reference: QoshniCartLineReference(
        businessId: MockBusinessId.barakaMarket,
        catalogItemId: MockCatalogItemId.barakaFreshBread,
      ),
      quantity: 1,
    );
    final b = QoshniCartItem(
      reference: QoshniCartLineReference(
        businessId: MockBusinessId.samarkandCafe,
        catalogItemId: MockCatalogItemId.samarkandGreenTea,
      ),
      quantity: 1,
    );
    final groups = groupCartItemsByBusiness([a, b]);
    expect(groups.length, 2);
  });
}

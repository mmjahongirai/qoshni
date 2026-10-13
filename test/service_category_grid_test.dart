import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/features/home/presentation/data/home_mock_data.dart';
import 'package:qoshni/features/home/presentation/data/service_category_id.dart';
import 'package:qoshni/features/home/presentation/widgets/service_category_grid.dart';

void main() {
  const categories = [
    HomeServiceCategoryItem(
      id: ServiceCategoryId.groceries,
      icon: Icons.shopping_basket_outlined,
      label: 'Groceries',
    ),
    HomeServiceCategoryItem(
      id: ServiceCategoryId.restaurants,
      icon: Icons.restaurant_outlined,
      label: 'Restaurants',
    ),
    HomeServiceCategoryItem(
      id: ServiceCategoryId.pharmacy,
      icon: Icons.local_pharmacy_outlined,
      label: 'Pharmacy',
    ),
    HomeServiceCategoryItem(
      id: ServiceCategoryId.shops,
      icon: Icons.storefront_outlined,
      label: 'Shops',
    ),
    HomeServiceCategoryItem(
      id: ServiceCategoryId.masters,
      icon: Icons.handyman_outlined,
      label: 'Masters',
    ),
    HomeServiceCategoryItem(
      id: ServiceCategoryId.rent,
      icon: Icons.key_outlined,
      label: 'Rent',
    ),
  ];

  test('serviceCategoryCrossAxisCount uses two columns on narrow widths', () {
    expect(serviceCategoryCrossAxisCount(400), 2);
    expect(serviceCategoryCrossAxisCount(519), 2);
    expect(serviceCategoryCrossAxisCount(520), 3);
    expect(serviceCategoryCrossAxisCount(760), 3);
  });

  testWidgets('ServiceCategoryGrid renders all six category labels', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(size: Size(390, 844)),
          child: Scaffold(
            body: ServiceCategoryGrid(
              categories: categories,
              onCategorySelected: (_) {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    for (final category in categories) {
      expect(find.text(category.label), findsOneWidget);
    }
  });

  testWidgets('ServiceCategoryGrid uses compact tile height on phone width', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(size: Size(390, 844)),
          child: Scaffold(
            body: ServiceCategoryGrid(
              categories: categories,
              onCategorySelected: (_) {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final firstTile = tester.getSize(find.text('Groceries'));
    expect(firstTile.height, lessThan(96));
  });
}

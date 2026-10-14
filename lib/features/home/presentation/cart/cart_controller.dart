import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/features/home/presentation/cart/cart_line_key.dart';
import 'package:qoshni/features/home/presentation/data/business_catalog_mock_data.dart';
import 'package:qoshni/features/home/presentation/data/home_mock_data.dart';
import 'package:qoshni/features/home/presentation/data/mock_business_id.dart';
import 'package:qoshni/features/home/presentation/cart/demo_order_snapshot.dart';
import 'package:qoshni/features/home/presentation/data/mock_catalog_item_id.dart';

class ResolvedCartLine {
  const ResolvedCartLine({
    required this.key,
    required this.quantity,
    required this.catalogItem,
    required this.businessName,
    required this.unitPriceUzs,
  });

  final CartLineKey key;
  final int quantity;
  final BusinessCatalogItem catalogItem;
  final String businessName;
  final int unitPriceUzs;

  int get subtotalUzs => unitPriceUzs * quantity;
}

/// In-memory shopping cart for the MVP (not persisted across restarts).
class CartController extends ChangeNotifier {
  final List<CartLineKey> _lineOrder = [];
  final Map<CartLineKey, int> _quantities = {};

  int get totalUnitCount {
    var total = 0;
    for (final quantity in _quantities.values) {
      total += quantity;
    }
    return total;
  }

  bool get isEmpty => _quantities.isEmpty;

  List<CartLineKey> get lineKeys => List<CartLineKey>.unmodifiable(_lineOrder);

  int quantityFor(CartLineKey key) => _quantities[key] ?? 0;

  bool addCatalogItem({
    required AppLocalizations l10n,
    required MockBusinessId businessId,
    required MockCatalogItemId catalogItemId,
  }) {
    final catalogItem = findCatalogItemForBusiness(
      l10n: l10n,
      businessId: businessId,
      catalogItemId: catalogItemId,
    );
    if (catalogItem == null || catalogItem.samplePriceUzs == null) {
      return false;
    }

    final key = CartLineKey(
      businessId: businessId,
      catalogItemId: catalogItemId,
    );
    if (!_quantities.containsKey(key)) {
      _lineOrder.add(key);
    }
    _quantities[key] = (_quantities[key] ?? 0) + 1;
    notifyListeners();
    return true;
  }

  void incrementQuantity(CartLineKey key) {
    if (!_quantities.containsKey(key)) {
      return;
    }
    _quantities[key] = _quantities[key]! + 1;
    notifyListeners();
  }

  void decrementQuantity(CartLineKey key) {
    final current = _quantities[key];
    if (current == null || current <= 1) {
      return;
    }
    _quantities[key] = current - 1;
    notifyListeners();
  }

  void removeLine(CartLineKey key) {
    if (_quantities.remove(key) != null) {
      _lineOrder.remove(key);
      notifyListeners();
    }
  }

  void clear() {
    if (_quantities.isEmpty) {
      return;
    }
    _quantities.clear();
    _lineOrder.clear();
    notifyListeners();
  }

  List<ResolvedCartLine> resolveLines(
    AppLocalizations l10n,
    ColorScheme colorScheme,
  ) {
    final lines = <ResolvedCartLine>[];
    final staleKeys = <CartLineKey>[];

    for (final key in _lineOrder) {
      final quantity = _quantities[key];
      if (quantity == null || quantity < 1) {
        staleKeys.add(key);
        continue;
      }

      final catalogItem = findCatalogItemForBusiness(
        l10n: l10n,
        businessId: key.businessId,
        catalogItemId: key.catalogItemId,
      );
      final business = findMockBusinessById(l10n, colorScheme, key.businessId);
      final price = catalogItem?.samplePriceUzs;

      if (catalogItem == null || business == null || price == null) {
        staleKeys.add(key);
        continue;
      }

      lines.add(
        ResolvedCartLine(
          key: key,
          quantity: quantity,
          catalogItem: catalogItem,
          businessName: business.name,
          unitPriceUzs: price,
        ),
      );
    }

    if (staleKeys.isNotEmpty) {
      for (final key in staleKeys) {
        _quantities.remove(key);
        _lineOrder.remove(key);
      }
      notifyListeners();
    }

    return lines;
  }

  int estimatedTotalUzs(AppLocalizations l10n, ColorScheme colorScheme) {
    return resolveLines(l10n, colorScheme)
        .fold<int>(0, (sum, line) => sum + line.subtotalUzs);
  }

  DemoOrderSnapshot? buildDemoOrderSnapshot(
    AppLocalizations l10n,
    ColorScheme colorScheme,
  ) {
    final lines = resolveLines(l10n, colorScheme);
    final total = estimatedTotalUzs(l10n, colorScheme);
    return DemoOrderSnapshot.fromResolvedCartLines(
      lines: lines,
      totalUzs: total,
    );
  }
}

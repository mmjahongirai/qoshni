import 'package:flutter/foundation.dart';
import 'package:qoshni/features/checkout/domain/qoshni_cart_item.dart';
import 'package:qoshni/features/checkout/domain/qoshni_cart_line_reference.dart';
import 'package:qoshni/features/checkout/domain/qoshni_checkout_limits.dart';
import 'package:qoshni/features/checkout/domain/qoshni_universal_cart.dart';
import 'package:qoshni/features/home/presentation/data/mock_business_id.dart';
import 'package:qoshni/features/home/presentation/data/mock_catalog_item_id.dart';

/// In-memory universal cart for the consumer demo plane.
class QoshniCartService extends ChangeNotifier {
  QoshniUniversalCart _cart = QoshniUniversalCart.empty();

  QoshniUniversalCart get cart => _cart;

  int get revision => _cart.revision;

  bool get isEmpty => _cart.isEmpty;

  List<QoshniCartLineReference> get lineOrder => _cart.lineOrder;

  int quantityFor(QoshniCartLineReference reference) =>
      _cart.itemsByReference[reference]?.quantity ?? 0;

  QoshniCartMutationResult addLine({
    required MockBusinessId businessId,
    required MockCatalogItemId catalogItemId,
    int quantityDelta = 1,
  }) {
    final reference = QoshniCartLineReference(
      businessId: businessId,
      catalogItemId: catalogItemId,
    );
    final current = _cart.itemsByReference[reference]?.quantity ?? 0;
    final nextQuantity = current + quantityDelta;
    final validation = validateQuantity(nextQuantity);
    if (validation != QoshniCartMutationResult.success) {
      return validation;
    }

    if (current == 0 && _cart.itemsByReference.length >= kQoshniCartMaxDistinctLines) {
      return QoshniCartMutationResult.cartCapacityExceeded;
    }

    final nextItems = Map<QoshniCartLineReference, QoshniCartItem>.from(
      _cart.itemsByReference,
    );
    final nextOrder = List<QoshniCartLineReference>.from(_cart.lineOrder);
    if (current == 0) {
      nextOrder.add(reference);
    }
    nextItems[reference] = QoshniCartItem(
      reference: reference,
      quantity: nextQuantity,
    );
    _cart = _cart.withNextRevision(
      lineOrder: nextOrder,
      itemsByReference: nextItems,
    );
    notifyListeners();
    return QoshniCartMutationResult.success;
  }

  QoshniCartMutationResult setQuantity(
    QoshniCartLineReference reference,
    int quantity,
  ) {
    if (!_cart.itemsByReference.containsKey(reference)) {
      return QoshniCartMutationResult.catalogUnavailable;
    }
    final validation = validateQuantity(quantity);
    if (validation != QoshniCartMutationResult.success) {
      return validation;
    }
    final nextItems = Map<QoshniCartLineReference, QoshniCartItem>.from(
      _cart.itemsByReference,
    );
    nextItems[reference] = QoshniCartItem(
      reference: reference,
      quantity: quantity,
    );
    _cart = _cart.withNextRevision(
      lineOrder: _cart.lineOrder,
      itemsByReference: nextItems,
    );
    notifyListeners();
    return QoshniCartMutationResult.success;
  }

  void incrementQuantity(QoshniCartLineReference reference) {
    final current = _cart.itemsByReference[reference]?.quantity;
    if (current == null) {
      return;
    }
    setQuantity(reference, current + 1);
  }

  void decrementQuantity(QoshniCartLineReference reference) {
    final current = _cart.itemsByReference[reference]?.quantity;
    if (current == null || current <= kQoshniCartMinLineQuantity) {
      return;
    }
    setQuantity(reference, current - 1);
  }

  void removeLine(QoshniCartLineReference reference) {
    if (!_cart.itemsByReference.containsKey(reference)) {
      return;
    }
    final nextItems = Map<QoshniCartLineReference, QoshniCartItem>.from(
      _cart.itemsByReference,
    )..remove(reference);
    final nextOrder = List<QoshniCartLineReference>.from(_cart.lineOrder)
      ..remove(reference);
    _cart = _cart.withNextRevision(
      lineOrder: nextOrder,
      itemsByReference: nextItems,
    );
    notifyListeners();
  }

  void clear() {
    if (_cart.isEmpty) {
      return;
    }
    _cart = QoshniUniversalCart.empty(cartId: _cart.cartId);
    notifyListeners();
  }

  void purgeInvalidReferences(Set<QoshniCartLineReference> stale) {
    if (stale.isEmpty) {
      return;
    }
    final nextItems = Map<QoshniCartLineReference, QoshniCartItem>.from(
      _cart.itemsByReference,
    )..removeWhere((key, _) => stale.contains(key));
    final nextOrder = List<QoshniCartLineReference>.from(_cart.lineOrder)
      ..removeWhere(stale.contains);
    if (nextItems.length == _cart.itemsByReference.length) {
      return;
    }
    _cart = _cart.withNextRevision(
      lineOrder: nextOrder,
      itemsByReference: nextItems,
    );
    notifyListeners();
  }
}

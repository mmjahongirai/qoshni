import 'package:qoshni/features/checkout/domain/qoshni_cart_item.dart';
import 'package:qoshni/features/checkout/domain/qoshni_cart_line_reference.dart';
import 'package:qoshni/features/checkout/domain/qoshni_checkout_limits.dart';

/// Transient in-session cart — not an order and not persisted across restarts.
class QoshniUniversalCart {
  QoshniUniversalCart._({
    required this.cartId,
    required this.revision,
    required this.lineOrder,
    required this.itemsByReference,
    required this.updatedAt,
  });

  factory QoshniUniversalCart.empty({String? cartId}) {
    final now = DateTime.now().toUtc();
    return QoshniUniversalCart._(
      cartId: cartId ?? 'cart-${now.microsecondsSinceEpoch}',
      revision: 0,
      lineOrder: const [],
      itemsByReference: const {},
      updatedAt: now,
    );
  }

  final String cartId;
  final int revision;
  final List<QoshniCartLineReference> lineOrder;
  final Map<QoshniCartLineReference, QoshniCartItem> itemsByReference;
  final DateTime updatedAt;

  bool get isEmpty => itemsByReference.isEmpty;

  int get totalUnitCount {
    var total = 0;
    for (final item in itemsByReference.values) {
      total += item.quantity;
    }
    return total;
  }

  List<QoshniCartItem> get linesInOrder {
    final lines = <QoshniCartItem>[];
    for (final reference in lineOrder) {
      final item = itemsByReference[reference];
      if (item != null) {
        lines.add(item);
      }
    }
    return lines;
  }

  QoshniUniversalCart withNextRevision({
    required List<QoshniCartLineReference> lineOrder,
    required Map<QoshniCartLineReference, QoshniCartItem> itemsByReference,
  }) {
    return QoshniUniversalCart._(
      cartId: cartId,
      revision: revision + 1,
      lineOrder: List<QoshniCartLineReference>.unmodifiable(lineOrder),
      itemsByReference: Map.unmodifiable(itemsByReference),
      updatedAt: DateTime.now().toUtc(),
    );
  }

  QoshniUniversalCart withResetRevision({
    required List<QoshniCartLineReference> lineOrder,
    required Map<QoshniCartLineReference, QoshniCartItem> itemsByReference,
  }) {
    return QoshniUniversalCart._(
      cartId: cartId,
      revision: revision + 1,
      lineOrder: List<QoshniCartLineReference>.unmodifiable(lineOrder),
      itemsByReference: Map.unmodifiable(itemsByReference),
      updatedAt: DateTime.now().toUtc(),
    );
  }
}

enum QoshniCartMutationResult {
  success,
  catalogUnavailable,
  invalidQuantity,
  cartCapacityExceeded,
}

QoshniCartMutationResult validateQuantity(int quantity) {
  if (quantity < kQoshniCartMinLineQuantity ||
      quantity > kQoshniCartMaxLineQuantity) {
    return QoshniCartMutationResult.invalidQuantity;
  }
  return QoshniCartMutationResult.success;
}

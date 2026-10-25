import 'package:qoshni/features/checkout/domain/qoshni_cart_line_reference.dart';
import 'package:qoshni/features/checkout/domain/qoshni_checkout_limits.dart';

class QoshniCartItem {
  const QoshniCartItem({
    required this.reference,
    required this.quantity,
  });

  final QoshniCartLineReference reference;
  final int quantity;

  bool get hasValidQuantity =>
      quantity >= kQoshniCartMinLineQuantity &&
      quantity <= kQoshniCartMaxLineQuantity;

  QoshniCartItem copyWith({int? quantity}) {
    return QoshniCartItem(
      reference: reference,
      quantity: quantity ?? this.quantity,
    );
  }
}

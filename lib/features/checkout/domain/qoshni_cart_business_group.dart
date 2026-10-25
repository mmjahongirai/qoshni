import 'package:qoshni/features/checkout/domain/qoshni_cart_item.dart';

/// Deterministic grouping of cart lines by stable business identifier.
class QoshniCartBusinessGroup {
  const QoshniCartBusinessGroup({
    required this.businessStableId,
    required this.items,
  });

  final String businessStableId;
  final List<QoshniCartItem> items;
}

List<QoshniCartBusinessGroup> groupCartItemsByBusiness(
  List<QoshniCartItem> linesInOrder,
) {
  final order = <String>[];
  final buckets = <String, List<QoshniCartItem>>{};

  for (final item in linesInOrder) {
    final businessId = item.reference.businessStableId;
    if (!buckets.containsKey(businessId)) {
      order.add(businessId);
      buckets[businessId] = [];
    }
    buckets[businessId]!.add(item);
  }

  final sortedBusinessIds = List<String>.from(order)
    ..sort((a, b) => a.compareTo(b));

  return [
    for (final businessId in sortedBusinessIds)
      QoshniCartBusinessGroup(
        businessStableId: businessId,
        items: List<QoshniCartItem>.unmodifiable(buckets[businessId]!),
      ),
  ];
}

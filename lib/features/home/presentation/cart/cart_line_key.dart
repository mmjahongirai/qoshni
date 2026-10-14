import 'package:qoshni/features/home/presentation/data/mock_business_id.dart';
import 'package:qoshni/features/home/presentation/data/mock_catalog_item_id.dart';

/// Composite identity for a catalog line in the cart.
class CartLineKey {
  const CartLineKey({
    required this.businessId,
    required this.catalogItemId,
  });

  final MockBusinessId businessId;
  final MockCatalogItemId catalogItemId;

  @override
  bool operator ==(Object other) {
    return other is CartLineKey &&
        other.businessId == businessId &&
        other.catalogItemId == catalogItemId;
  }

  @override
  int get hashCode => Object.hash(businessId, catalogItemId);
}

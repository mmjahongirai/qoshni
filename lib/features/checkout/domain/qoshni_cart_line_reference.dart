import 'package:qoshni/features/home/presentation/data/mock_business_id.dart';
import 'package:qoshni/features/home/presentation/data/mock_catalog_item_id.dart';

/// Stable composite identity for a consumer-catalog cart line (demo data plane).
class QoshniCartLineReference {
  const QoshniCartLineReference({
    required this.businessId,
    required this.catalogItemId,
  });

  final MockBusinessId businessId;
  final MockCatalogItemId catalogItemId;

  String get businessStableId => businessId.routeParam;
  String get catalogItemStableId => catalogItemId.routeParam;

  @override
  bool operator ==(Object other) {
    return other is QoshniCartLineReference &&
        other.businessId == businessId &&
        other.catalogItemId == catalogItemId;
  }

  @override
  int get hashCode => Object.hash(businessId, catalogItemId);
}

/// Aggregated catalog stats for business owner preview (computed from products/services).
class BusinessCatalogOverviewStats {
  const BusinessCatalogOverviewStats({
    required this.categoryCount,
    required this.productCount,
    required this.serviceCount,
    required this.activeItemCount,
    required this.draftItemCount,
    required this.archivedItemCount,
  });

  final int categoryCount;
  final int productCount;
  final int serviceCount;
  final int activeItemCount;
  final int draftItemCount;
  final int archivedItemCount;
}

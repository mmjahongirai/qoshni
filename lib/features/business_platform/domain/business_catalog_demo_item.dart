import 'package:qoshni/features/business_platform/domain/business_offering_kind.dart';

enum BusinessCatalogDemoItemStatus {
  active,
  draft,
}

enum BusinessCatalogDemoItemDataSource {
  demoSeed,
}

/// Session-scoped catalog line item for owner preview stats (not consumer catalog).
class BusinessCatalogDemoItem {
  const BusinessCatalogDemoItem({
    required this.itemId,
    required this.businessScopeId,
    required this.categoryId,
    required this.kind,
    required this.status,
    required this.dataSource,
  });

  final String itemId;
  final String businessScopeId;
  final String categoryId;
  final BusinessOfferingKind kind;
  final BusinessCatalogDemoItemStatus status;
  final BusinessCatalogDemoItemDataSource dataSource;

  bool get isProduct =>
      kind == BusinessOfferingKind.product || kind == BusinessOfferingKind.rental;

  bool get isService => kind == BusinessOfferingKind.service;
}

class BusinessCatalogOverviewStats {
  const BusinessCatalogOverviewStats({
    required this.categoryCount,
    required this.productCount,
    required this.serviceCount,
    required this.activeItemCount,
    required this.draftItemCount,
  });

  final int categoryCount;
  final int productCount;
  final int serviceCount;
  final int activeItemCount;
  final int draftItemCount;
}

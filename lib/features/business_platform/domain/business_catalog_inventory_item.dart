import 'package:qoshni/features/business_platform/domain/business_catalog_inventory_track_status.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_product.dart';

class BusinessCatalogInventoryItem {
  const BusinessCatalogInventoryItem({
    required this.inventoryItemId,
    required this.businessScopeId,
    required this.productId,
    this.variantId,
    required this.branchId,
    required this.dataSource,
    required this.onHandQuantity,
    required this.reservedQuantity,
    required this.lowStockThreshold,
    required this.trackStatus,
    required this.updatedAt,
  });

  final String inventoryItemId;
  final String businessScopeId;
  final String productId;
  final String? variantId;
  final String branchId;
  final BusinessCatalogProductDataSource dataSource;
  final int onHandQuantity;
  final int reservedQuantity;
  final int lowStockThreshold;
  final BusinessCatalogInventoryTrackStatus trackStatus;
  final DateTime updatedAt;

  bool get isDemoSeed => dataSource == BusinessCatalogProductDataSource.demoSeed;

  int get availableQuantity {
    if (trackStatus == BusinessCatalogInventoryTrackStatus.manuallyUnavailable) {
      return 0;
    }
    final raw = onHandQuantity - reservedQuantity;
    return raw < 0 ? 0 : raw;
  }

  BusinessCatalogInventoryItem copyWith({
    int? onHandQuantity,
    int? reservedQuantity,
    int? lowStockThreshold,
    BusinessCatalogInventoryTrackStatus? trackStatus,
    DateTime? updatedAt,
  }) {
    return BusinessCatalogInventoryItem(
      inventoryItemId: inventoryItemId,
      businessScopeId: businessScopeId,
      productId: productId,
      variantId: variantId,
      branchId: branchId,
      dataSource: dataSource,
      onHandQuantity: onHandQuantity ?? this.onHandQuantity,
      reservedQuantity: reservedQuantity ?? this.reservedQuantity,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      trackStatus: trackStatus ?? this.trackStatus,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class BusinessCatalogInventoryItemInput {
  const BusinessCatalogInventoryItemInput({
    required this.productId,
    this.variantId,
    required this.branchId,
    required this.onHandQuantity,
    required this.reservedQuantity,
    required this.lowStockThreshold,
    required this.trackStatus,
  });

  final String productId;
  final String? variantId;
  final String branchId;
  final int onHandQuantity;
  final int reservedQuantity;
  final int lowStockThreshold;
  final BusinessCatalogInventoryTrackStatus trackStatus;
}

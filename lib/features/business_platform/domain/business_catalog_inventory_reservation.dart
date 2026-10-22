import 'package:qoshni/features/business_platform/domain/business_catalog_inventory_reservation_status.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_product.dart';

class BusinessCatalogInventoryReservation {
  const BusinessCatalogInventoryReservation({
    required this.reservationId,
    required this.inventoryItemId,
    required this.productId,
    this.variantId,
    required this.businessScopeId,
    required this.branchId,
    required this.quantity,
    required this.status,
    required this.createdAt,
    required this.expiresAt,
    this.operationReference,
    required this.dataSource,
  });

  final String reservationId;
  final String inventoryItemId;
  final String productId;
  final String? variantId;
  final String businessScopeId;
  final String branchId;
  final int quantity;
  final BusinessCatalogInventoryReservationStatus status;
  final DateTime createdAt;
  final DateTime expiresAt;
  final String? operationReference;
  final BusinessCatalogProductDataSource dataSource;

  bool get isDemoSeed => dataSource == BusinessCatalogProductDataSource.demoSeed;

  BusinessCatalogInventoryReservation copyWith({
    BusinessCatalogInventoryReservationStatus? status,
  }) {
    return BusinessCatalogInventoryReservation(
      reservationId: reservationId,
      inventoryItemId: inventoryItemId,
      productId: productId,
      variantId: variantId,
      businessScopeId: businessScopeId,
      branchId: branchId,
      quantity: quantity,
      status: status ?? this.status,
      createdAt: createdAt,
      expiresAt: expiresAt,
      operationReference: operationReference,
      dataSource: dataSource,
    );
  }
}

class BusinessCatalogInventoryReservationInput {
  const BusinessCatalogInventoryReservationInput({
    required this.inventoryItemId,
    required this.quantity,
    required this.expiresAt,
    this.operationReference,
  });

  final String inventoryItemId;
  final int quantity;
  final DateTime expiresAt;
  final String? operationReference;
}

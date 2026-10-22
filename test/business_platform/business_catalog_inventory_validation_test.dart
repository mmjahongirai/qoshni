import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_inventory_adjustment.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_inventory_availability.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_inventory_item.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_inventory_track_status.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_product.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_inventory_validation.dart';

BusinessCatalogInventoryItem _item({
  int onHand = 10,
  int reserved = 2,
  int threshold = 3,
  BusinessCatalogInventoryTrackStatus track =
      BusinessCatalogInventoryTrackStatus.active,
}) {
  return BusinessCatalogInventoryItem(
    inventoryItemId: 'test-item',
    businessScopeId: 'scope',
    productId: 'product',
    branchId: 'branch',
    dataSource: BusinessCatalogProductDataSource.demoSeed,
    onHandQuantity: onHand,
    reservedQuantity: reserved,
    lowStockThreshold: threshold,
    trackStatus: track,
    updatedAt: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
  );
}

void main() {
  test('available quantity is onHand minus reserved when active', () {
    expect(_item(onHand: 10, reserved: 3).availableQuantity, 7);
  });

  test('available quantity is zero when manually unavailable', () {
    expect(
      _item(onHand: 50, reserved: 0, track: BusinessCatalogInventoryTrackStatus.manuallyUnavailable)
          .availableQuantity,
      0,
    );
  });

  test('available quantity never negative when reserved exceeds on hand in model', () {
    expect(
      catalogInventoryAvailableQuantity(
        onHandQuantity: 2,
        reservedQuantity: 5,
        trackStatus: BusinessCatalogInventoryTrackStatus.active,
      ),
      0,
    );
  });

  test('quantity validation rejects negative and reserved over on-hand', () {
    expect(
      catalogInventoryQuantitiesValid(
        onHandQuantity: -1,
        reservedQuantity: 0,
        lowStockThreshold: 0,
      ),
      isFalse,
    );
    expect(
      catalogInventoryQuantitiesValid(
        onHandQuantity: 5,
        reservedQuantity: 6,
        lowStockThreshold: 0,
      ),
      isFalse,
    );
  });

  test('availability distinguishes low stock out of stock and unavailable', () {
    expect(
      computeCatalogInventoryAvailability(_item(onHand: 20, reserved: 0, threshold: 5)),
      BusinessCatalogInventoryAvailability.inStock,
    );
    expect(
      computeCatalogInventoryAvailability(_item(onHand: 5, reserved: 0, threshold: 8)),
      BusinessCatalogInventoryAvailability.lowStock,
    );
    expect(
      computeCatalogInventoryAvailability(_item(onHand: 0, reserved: 0, threshold: 1)),
      BusinessCatalogInventoryAvailability.outOfStock,
    );
    expect(
      computeCatalogInventoryAvailability(
        _item(
          onHand: 100,
          track: BusinessCatalogInventoryTrackStatus.manuallyUnavailable,
        ),
      ),
      BusinessCatalogInventoryAvailability.unavailable,
    );
  });

  test('adjustment validation catches invalid deltas and empty reason', () {
    final item = _item(onHand: 10, reserved: 2);
    expect(
      catalogInventoryAdjustmentValidationError(
        item,
        const BusinessCatalogInventoryAdjustmentInput(
          kind: BusinessCatalogInventoryAdjustmentKind.onHandDelta,
          delta: 0,
          reason: 'restock',
        ),
      ),
      'delta_zero',
    );
    expect(
      catalogInventoryAdjustmentValidationError(
        item,
        const BusinessCatalogInventoryAdjustmentInput(
          kind: BusinessCatalogInventoryAdjustmentKind.onHandDelta,
          delta: 5,
          reason: '   ',
        ),
      ),
      'reason_required',
    );
    expect(
      catalogInventoryAdjustmentValidationError(
        item,
        const BusinessCatalogInventoryAdjustmentInput(
          kind: BusinessCatalogInventoryAdjustmentKind.onHandDelta,
          delta: -20,
          reason: 'damage',
        ),
      ),
      'on_hand_negative',
    );
  });
}

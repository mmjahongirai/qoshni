import 'package:qoshni/features/business_platform/data/business_catalog_inventory_demo_seed.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_inventory_adjustment.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_inventory_availability.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_inventory_item.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_inventory_track_status.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_product.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_branch_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_catalog_inventory_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_catalog_product_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_catalog_product_variant_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_owner_profile_repository.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_inventory_validation.dart';

class InMemoryBusinessCatalogInventoryRepository
    implements BusinessCatalogInventoryRepository {
  InMemoryBusinessCatalogInventoryRepository(
    this._ownerProfileRepository,
    this._productRepository,
    this._variantRepository,
    this._branchRepository,
  );

  final BusinessOwnerProfileRepository _ownerProfileRepository;
  final BusinessCatalogProductRepository _productRepository;
  final BusinessCatalogProductVariantRepository _variantRepository;
  final BusinessBranchRepository _branchRepository;

  final Map<String, List<BusinessCatalogInventoryItem>> _itemsByScope = {};
  final Map<String, Map<String, List<BusinessCatalogInventoryAdjustmentEvent>>>
      _historyByScope = {};

  int _userItemCounter = 0;
  int _eventCounter = 0;

  bool failNextSave = false;
  bool failNextList = false;

  @override
  String get businessScopeId =>
      _ownerProfileRepository.ensureSessionProfile().sessionProfileId;

  @override
  List<BusinessCatalogInventoryItem> listForCurrentScope({
    String? branchId,
    BusinessCatalogInventoryAvailability? availability,
  }) {
    if (failNextList) {
      failNextList = false;
      throw StateError('catalog_inventory_list_failed');
    }
    var items = List<BusinessCatalogInventoryItem>.from(_ensureScopeList());
    if (branchId != null && branchId.trim().isNotEmpty) {
      final id = branchId.trim();
      items = items.where((i) => i.branchId == id).toList();
    }
    if (availability != null) {
      items = items
          .where(
            (i) => computeCatalogInventoryAvailability(i) == availability,
          )
          .toList();
    }
    return List.unmodifiable(items);
  }

  @override
  BusinessCatalogInventoryItem? findById(String inventoryItemId) {
    try {
      return _ensureScopeList()
          .firstWhere((i) => i.inventoryItemId == inventoryItemId);
    } on StateError {
      return null;
    }
  }

  @override
  BusinessCatalogInventorySaveResult upsertInventory({
    String? inventoryItemId,
    required BusinessCatalogInventoryItemInput input,
  }) {
    if (failNextSave) {
      failNextSave = false;
      return BusinessCatalogInventorySaveResult.failure;
    }
    if (!catalogInventoryQuantitiesValid(
      onHandQuantity: input.onHandQuantity,
      reservedQuantity: input.reservedQuantity,
      lowStockThreshold: input.lowStockThreshold,
    )) {
      return BusinessCatalogInventorySaveResult.invalidQuantities;
    }
    final product = _productRepository.findById(input.productId.trim());
    if (product == null || product.businessScopeId != businessScopeId) {
      return BusinessCatalogInventorySaveResult.invalidProduct;
    }
    final branch = _branchRepository.findById(input.branchId.trim());
    if (branch == null || branch.businessScopeId != businessScopeId) {
      return BusinessCatalogInventorySaveResult.invalidBranch;
    }
    final variantId = input.variantId?.trim();
    if (variantId != null && variantId.isNotEmpty) {
      final variant = _variantRepository.findById(variantId);
      if (variant == null ||
          variant.businessScopeId != businessScopeId ||
          variant.productId != product.productId) {
        return BusinessCatalogInventorySaveResult.invalidVariant;
      }
    }

    final list = _ensureScopeList();
    final locationKey = _locationKey(
      productId: product.productId,
      variantId: variantId,
      branchId: branch.branchId,
    );

    if (inventoryItemId != null && inventoryItemId.trim().isNotEmpty) {
      final index =
          list.indexWhere((i) => i.inventoryItemId == inventoryItemId);
      if (index < 0) {
        return BusinessCatalogInventorySaveResult.notFound;
      }
      final existing = list[index];
      final otherAtLocation = list.where(
        (i) =>
            i.inventoryItemId != existing.inventoryItemId &&
            _locationKey(
                  productId: i.productId,
                  variantId: i.variantId,
                  branchId: i.branchId,
                ) ==
                locationKey,
      );
      if (otherAtLocation.isNotEmpty) {
        return BusinessCatalogInventorySaveResult.duplicateLocation;
      }
      list[index] = BusinessCatalogInventoryItem(
        inventoryItemId: existing.inventoryItemId,
        businessScopeId: existing.businessScopeId,
        productId: product.productId,
        variantId: variantId?.isEmpty ?? true ? null : variantId,
        branchId: branch.branchId,
        dataSource: existing.dataSource,
        onHandQuantity: input.onHandQuantity,
        reservedQuantity: input.reservedQuantity,
        lowStockThreshold: input.lowStockThreshold,
        trackStatus: input.trackStatus,
        updatedAt: DateTime.now(),
      );
      return BusinessCatalogInventorySaveResult.success;
    }

    if (list.any(
      (i) =>
          _locationKey(
            productId: i.productId,
            variantId: i.variantId,
            branchId: i.branchId,
          ) ==
          locationKey,
    )) {
      return BusinessCatalogInventorySaveResult.duplicateLocation;
    }

    _userItemCounter++;
    list.add(
      BusinessCatalogInventoryItem(
        inventoryItemId: 'session-catalog-inventory-$_userItemCounter',
        businessScopeId: businessScopeId,
        productId: product.productId,
        variantId: variantId?.isEmpty ?? true ? null : variantId,
        branchId: branch.branchId,
        dataSource: BusinessCatalogProductDataSource.userSession,
        onHandQuantity: input.onHandQuantity,
        reservedQuantity: input.reservedQuantity,
        lowStockThreshold: input.lowStockThreshold,
        trackStatus: input.trackStatus,
        updatedAt: DateTime.now(),
      ),
    );
    return BusinessCatalogInventorySaveResult.success;
  }

  @override
  BusinessCatalogInventorySaveResult setTrackStatus({
    required String inventoryItemId,
    required BusinessCatalogInventoryTrackStatus trackStatus,
  }) {
    final list = _ensureScopeList();
    final index = list.indexWhere((i) => i.inventoryItemId == inventoryItemId);
    if (index < 0) {
      return BusinessCatalogInventorySaveResult.notFound;
    }
    list[index] = list[index].copyWith(
      trackStatus: trackStatus,
      updatedAt: DateTime.now(),
    );
    return BusinessCatalogInventorySaveResult.success;
  }

  @override
  BusinessCatalogInventoryAdjustmentResult applyAdjustment({
    required String inventoryItemId,
    required BusinessCatalogInventoryAdjustmentInput input,
  }) {
    if (failNextSave) {
      failNextSave = false;
      return BusinessCatalogInventoryAdjustmentResult.failure;
    }
    final list = _ensureScopeList();
    final index = list.indexWhere((i) => i.inventoryItemId == inventoryItemId);
    if (index < 0) {
      return BusinessCatalogInventoryAdjustmentResult.notFound;
    }
    final item = list[index];
    final validationError =
        catalogInventoryAdjustmentValidationError(item, input);
    if (validationError == 'reason_required') {
      return BusinessCatalogInventoryAdjustmentResult.invalidReason;
    }
    if (validationError == 'delta_zero') {
      return BusinessCatalogInventoryAdjustmentResult.invalidDelta;
    }
    if (validationError != null) {
      return BusinessCatalogInventoryAdjustmentResult.invalidQuantities;
    }

    final onHandBefore = item.onHandQuantity;
    final reservedBefore = item.reservedQuantity;
    late int onHandAfter;
    late int reservedAfter;

    switch (input.kind) {
      case BusinessCatalogInventoryAdjustmentKind.onHandDelta:
        onHandAfter = onHandBefore + input.delta;
        reservedAfter = reservedBefore;
      case BusinessCatalogInventoryAdjustmentKind.reservedDelta:
        onHandAfter = onHandBefore;
        reservedAfter = reservedBefore + input.delta;
    }

    list[index] = item.copyWith(
      onHandQuantity: onHandAfter,
      reservedQuantity: reservedAfter,
      updatedAt: DateTime.now(),
    );

    _appendHistory(
      BusinessCatalogInventoryAdjustmentEvent(
        eventId: _nextEventId(),
        inventoryItemId: inventoryItemId,
        kind: input.kind,
        delta: input.delta,
        onHandBefore: onHandBefore,
        onHandAfter: onHandAfter,
        reservedBefore: reservedBefore,
        reservedAfter: reservedAfter,
        reason: input.reason.trim(),
        recordedAt: DateTime.now(),
      ),
    );

    return BusinessCatalogInventoryAdjustmentResult.success;
  }

  @override
  List<BusinessCatalogInventoryAdjustmentEvent> adjustmentHistory(
    String inventoryItemId,
  ) {
    if (findById(inventoryItemId) == null) {
      return const [];
    }
    final scopeHistory = _ensureScopeHistory();
    return List.unmodifiable(scopeHistory[inventoryItemId] ?? const []);
  }

  void _appendHistory(BusinessCatalogInventoryAdjustmentEvent event) {
    final scopeHistory = _ensureScopeHistory();
    scopeHistory.putIfAbsent(event.inventoryItemId, () => []).add(event);
  }

  String _nextEventId() {
    _eventCounter++;
    return 'session-catalog-inventory-event-$_eventCounter';
  }

  String _locationKey({
    required String productId,
    required String? variantId,
    required String branchId,
  }) {
    return '$productId|${variantId ?? ''}|$branchId';
  }

  List<BusinessCatalogInventoryItem> _ensureScopeList() {
    return _itemsByScope.putIfAbsent(
      businessScopeId,
      () => buildDemoCatalogInventory(businessScopeId: businessScopeId),
    );
  }

  Map<String, List<BusinessCatalogInventoryAdjustmentEvent>>
      _ensureScopeHistory() {
    return _historyByScope.putIfAbsent(businessScopeId, () => {});
  }
}

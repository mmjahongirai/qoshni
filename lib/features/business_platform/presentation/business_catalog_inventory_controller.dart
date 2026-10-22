import 'package:flutter/foundation.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_inventory_adjustment.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_inventory_availability.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_inventory_item.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_inventory_track_status.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_catalog_inventory_repository.dart';

class BusinessCatalogInventoryController extends ChangeNotifier {
  BusinessCatalogInventoryController(this._repository);

  final BusinessCatalogInventoryRepository _repository;

  bool _listLoading = true;
  String? _listError;
  bool _adjustBusy = false;

  bool get listLoading => _listLoading;
  String? get listError => _listError;
  bool get adjustBusy => _adjustBusy;

  List<BusinessCatalogInventoryItem> items({
    String? branchId,
    BusinessCatalogInventoryAvailability? availability,
  }) {
    try {
      return _repository.listForCurrentScope(
        branchId: branchId,
        availability: availability,
      );
    } on StateError {
      return const [];
    }
  }

  BusinessCatalogInventoryItem? itemById(String inventoryItemId) =>
      _repository.findById(inventoryItemId);

  List<BusinessCatalogInventoryAdjustmentEvent> historyFor(
    String inventoryItemId,
  ) =>
      _repository.adjustmentHistory(inventoryItemId);

  Future<void> refreshList() async {
    _listLoading = true;
    _listError = null;
    notifyListeners();
    await Future<void>.delayed(Duration.zero);
    try {
      _repository.listForCurrentScope();
      _listError = null;
    } on StateError {
      _listError = 'load_failed';
    }
    _listLoading = false;
    notifyListeners();
  }

  Future<BusinessCatalogInventoryAdjustmentResult> applyAdjustment({
    required String inventoryItemId,
    required BusinessCatalogInventoryAdjustmentInput input,
  }) async {
    if (_adjustBusy) {
      return BusinessCatalogInventoryAdjustmentResult.failure;
    }
    _adjustBusy = true;
    notifyListeners();
    await Future<void>.delayed(Duration.zero);
    final result = _repository.applyAdjustment(
      inventoryItemId: inventoryItemId,
      input: input,
    );
    _adjustBusy = false;
    notifyListeners();
    return result;
  }

  Future<BusinessCatalogInventorySaveResult> setTrackStatus({
    required String inventoryItemId,
    required BusinessCatalogInventoryTrackStatus trackStatus,
  }) async {
    await Future<void>.delayed(Duration.zero);
    final result = _repository.setTrackStatus(
      inventoryItemId: inventoryItemId,
      trackStatus: trackStatus,
    );
    notifyListeners();
    return result;
  }
}

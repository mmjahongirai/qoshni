import 'package:flutter/foundation.dart';
import 'package:qoshni/features/business_platform/application/business_catalog_integration_controller.dart';
import 'package:qoshni/features/business_platform/domain/authoritative_catalog/authoritative_catalog.dart';

/// Matches the owner inventory reason limit. The owner cannot send reserved
/// quantity; that value stays on the server balance.
const int liveInventoryReasonMaxLength = 256;

const String liveInventoryNotOpenCode = 'inventory_not_open';

enum LiveInventoryInputIssue {
  none,
  openQuantity,
  replenishQuantity,
  countQuantity,
  reason,
}

/// Live stock for one catalog item. Displayed quantities come from the server
/// balance, including [AuthoritativeInventoryBalance.availableQuantity].
class BusinessLiveInventoryController extends ChangeNotifier {
  BusinessLiveInventoryController({
    required this.integration,
    required this.catalogItemId,
  });

  final BusinessCatalogIntegrationController integration;
  final String catalogItemId;

  bool loading = false;
  bool saving = false;
  bool notOpen = false;
  bool confirmed = false;
  AuthoritativeInventoryBalance? balance;
  List<AuthoritativeInventoryEvent> events = const [];
  AuthoritativeCatalogFailure? failure;
  AuthoritativeCatalogFailure? eventsFailure;
  LiveInventoryInputIssue inputIssue = LiveInventoryInputIssue.none;

  Future<void> load() async {
    loading = true;
    failure = null;
    inputIssue = LiveInventoryInputIssue.none;
    notifyListeners();
    await _refreshFromServer();
    loading = false;
    notifyListeners();
  }

  Future<bool> openStock({
    required int quantityOnHand,
    required String reason,
  }) {
    final cleaned = reason.trim();
    if (quantityOnHand < 0) {
      return _reject(LiveInventoryInputIssue.openQuantity);
    }
    if (cleaned.isEmpty || cleaned.length > liveInventoryReasonMaxLength) {
      return _reject(LiveInventoryInputIssue.reason);
    }
    return _write(
      () => integration.openInventory(
        catalogItemId: catalogItemId,
        quantityOnHand: quantityOnHand,
        reason: cleaned,
      ),
    );
  }

  Future<bool> replenish({required int quantity, required String reason}) {
    final cleaned = reason.trim();
    if (quantity < 1) {
      return _reject(LiveInventoryInputIssue.replenishQuantity);
    }
    if (cleaned.isEmpty || cleaned.length > liveInventoryReasonMaxLength) {
      return _reject(LiveInventoryInputIssue.reason);
    }
    return _write(
      () => integration.replenishInventory(
        catalogItemId: catalogItemId,
        quantity: quantity,
        reason: cleaned,
      ),
    );
  }

  Future<bool> recordCount({
    required int quantityOnHand,
    required String reason,
  }) {
    final cleaned = reason.trim();
    if (quantityOnHand < 0) {
      return _reject(LiveInventoryInputIssue.countQuantity);
    }
    if (cleaned.isEmpty || cleaned.length > liveInventoryReasonMaxLength) {
      return _reject(LiveInventoryInputIssue.reason);
    }
    return _write(
      () => integration.correctInventoryCount(
        catalogItemId: catalogItemId,
        quantityOnHand: quantityOnHand,
        reason: cleaned,
      ),
    );
  }

  Future<bool> _reject(LiveInventoryInputIssue issue) async {
    inputIssue = issue;
    confirmed = false;
    notifyListeners();
    return false;
  }

  Future<bool> _write(
    Future<AuthoritativeInventoryBalance?> Function() action,
  ) async {
    if (saving || !integration.isLiveCatalogReady) {
      return false;
    }
    saving = true;
    confirmed = false;
    failure = null;
    inputIssue = LiveInventoryInputIssue.none;
    notifyListeners();
    final saved = await action();
    if (saved == null) {
      saving = false;
      failure = integration.lastFailure;
      notifyListeners();
      return false;
    }
    await _refreshFromServer();
    saving = false;
    confirmed = failure == null && balance != null;
    notifyListeners();
    return confirmed;
  }

  Future<void> _refreshFromServer() async {
    final result = await integration.getInventory(catalogItemId: catalogItemId);
    if (result != null) {
      balance = result;
      notOpen = false;
      failure = null;
      await _loadEvents();
      return;
    }
    final error = integration.lastFailure;
    if (_isNotOpen(error) && balance == null) {
      notOpen = true;
      failure = null;
      await _loadEvents();
      return;
    }
    failure = error;
    if (balance == null) {
      notOpen = false;
      events = const [];
      eventsFailure = null;
    }
  }

  Future<void> _loadEvents() async {
    final listed = await integration.listInventoryEvents(
      catalogItemId: catalogItemId,
    );
    if (listed == null) {
      eventsFailure = integration.lastFailure;
      return;
    }
    events = listed;
    eventsFailure = null;
  }

  bool _isNotOpen(AuthoritativeCatalogFailure? error) {
    return error?.code == AuthoritativeCatalogErrorCode.conflict &&
        error?.serverCode == liveInventoryNotOpenCode;
  }
}

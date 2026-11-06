import 'package:flutter/foundation.dart';
import 'package:qoshni/features/business_platform/application/business_catalog_integration_controller.dart';
import 'package:qoshni/features/business_platform/domain/authoritative_catalog/authoritative_catalog.dart';

/// Highest integer UZS price accepted by the owner catalog API.
const int liveCatalogMaxUnitPriceMinor = 1000000000;

const int liveCatalogStableIdMaxLength = 128;

const int liveCatalogTitleMaxLength = 256;

/// Live catalog list and edits. Values shown after a write come from the
/// server response. Sample offerings are never inserted here.
class BusinessLiveCatalogController extends ChangeNotifier {
  BusinessLiveCatalogController(this.integration);

  final BusinessCatalogIntegrationController integration;

  bool loading = false;
  bool saving = false;
  bool listFailed = false;
  List<AuthoritativeCatalogItem> items = const [];
  AuthoritativeCatalogFailure? failure;

  Future<void> open() async {
    await integration.refresh();
    await load();
  }

  Future<void> load() async {
    loading = true;
    listFailed = false;
    failure = null;
    notifyListeners();

    final applicationId = integration.applicationId;
    if (applicationId != null &&
        !authoritativeApplicationIdPattern.hasMatch(applicationId)) {
      items = const [];
      loading = false;
      listFailed = true;
      failure = const AuthoritativeCatalogFailure(
        code: AuthoritativeCatalogErrorCode.invalidApplicationId,
        message: 'A verified onboarding application id is required.',
      );
      notifyListeners();
      return;
    }
    if (!integration.isLiveCatalogReady) {
      items = const [];
      loading = false;
      notifyListeners();
      return;
    }

    final listed = await integration.listItems();
    loading = false;
    if (listed == null) {
      items = const [];
      listFailed = true;
      failure = integration.lastFailure;
    } else {
      items = listed;
      listFailed = false;
      failure = null;
    }
    notifyListeners();
  }

  Future<bool> createItem({
    required String catalogItemStableId,
    required AuthoritativeOfferingKind offeringKind,
    required String title,
    required int unitPriceMinor,
  }) {
    final stableId = catalogItemStableId.trim();
    final trimmedTitle = title.trim();
    if (!_priceAllowed(unitPriceMinor) ||
        stableId.isEmpty ||
        stableId.length > liveCatalogStableIdMaxLength ||
        trimmedTitle.isEmpty ||
        trimmedTitle.length > liveCatalogTitleMaxLength) {
      return _rejectInput();
    }
    return _write(() {
      return integration.createItem(
        catalogItemStableId: stableId,
        offeringKind: offeringKind,
        title: trimmedTitle,
        unitPriceMinor: unitPriceMinor,
      );
    });
  }

  Future<bool> updatePrice({
    required String catalogItemId,
    required int unitPriceMinor,
  }) {
    if (!_priceAllowed(unitPriceMinor)) {
      return _rejectInput();
    }
    return _write(() {
      return integration.updatePrice(
        catalogItemId: catalogItemId,
        unitPriceMinor: unitPriceMinor,
      );
    });
  }

  Future<bool> updateStatus({
    required String catalogItemId,
    required AuthoritativeCatalogItemStatus status,
  }) {
    return _write(() {
      return integration.updateStatus(
        catalogItemId: catalogItemId,
        status: status,
      );
    });
  }

  bool _priceAllowed(int unitPriceMinor) {
    return unitPriceMinor >= 0 &&
        unitPriceMinor <= liveCatalogMaxUnitPriceMinor;
  }

  Future<bool> _rejectInput() async {
    failure = const AuthoritativeCatalogFailure(
      code: AuthoritativeCatalogErrorCode.validationFailed,
      message: 'Catalog input was rejected before a request was sent.',
    );
    notifyListeners();
    return false;
  }

  Future<bool> _write(
    Future<AuthoritativeCatalogItem?> Function() action,
  ) async {
    if (!integration.isLiveCatalogReady || saving) {
      return false;
    }
    saving = true;
    failure = null;
    notifyListeners();
    final saved = await action();
    saving = false;
    if (saved == null) {
      failure = integration.lastFailure;
      notifyListeners();
      return false;
    }
    items = [
      for (final item in items)
        if (item.catalogItemId != saved.catalogItemId) item,
      saved,
    ];
    failure = null;
    listFailed = false;
    notifyListeners();
    return true;
  }
}

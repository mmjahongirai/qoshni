import 'package:flutter/foundation.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_listing_kind.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_price.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_price_history_event.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_price_status.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_catalog_pricing_repository.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_pricing_resolver.dart';

class BusinessCatalogPricingController extends ChangeNotifier {
  BusinessCatalogPricingController(this._repository);

  final BusinessCatalogPricingRepository _repository;

  bool _listLoading = true;
  bool _saveBusy = false;

  bool get listLoading => _listLoading;
  bool get saveBusy => _saveBusy;

  List<BusinessCatalogPrice> prices({
    String? branchId,
    BusinessCatalogListingKind? listingKind,
    BusinessCatalogPriceStatus? status,
  }) =>
      _repository.listForCurrentScope(
        branchId: branchId,
        listingKind: listingKind,
        status: status,
      );

  List<BusinessCatalogPrice> allPricesIncludingArchived() =>
      _repository.listForCurrentScope(includeArchived: true);

  BusinessCatalogPrice? priceById(String priceId) => _repository.findById(priceId);

  List<BusinessCatalogPriceHistoryEvent> historyFor(String priceId) =>
      _repository.priceHistory(priceId);

  CatalogPriceResolution resolveEffectivePrice({
    required BusinessCatalogListingKind listingKind,
    required String listingId,
    required String branchId,
    String? variantId,
    required DateTime asOf,
  }) {
    return resolveCatalogPrice(
      prices: allPricesIncludingArchived(),
      listingKind: listingKind,
      listingId: listingId,
      branchId: branchId,
      variantId: variantId,
      asOf: asOf,
    );
  }

  Future<void> refreshList() async {
    _listLoading = true;
    notifyListeners();
    await Future<void>.delayed(Duration.zero);
    _repository.listForCurrentScope();
    _listLoading = false;
    notifyListeners();
  }

  Future<BusinessCatalogPricingSaveResult> createDraft(
    BusinessCatalogPriceInput input,
  ) async {
    return _save(() => _repository.createDraft(input));
  }

  Future<BusinessCatalogPricingSaveResult> updateDraft({
    required String priceId,
    required BusinessCatalogPriceInput input,
  }) async {
    return _save(() => _repository.updateDraft(priceId: priceId, input: input));
  }

  Future<BusinessCatalogPricingSaveResult> createRevision({
    required String sourcePriceId,
    required BusinessCatalogPriceInput input,
  }) async {
    return _save(
      () => _repository.createRevisionFromPrice(
        sourcePriceId: sourcePriceId,
        input: input,
      ),
    );
  }

  Future<BusinessCatalogPricingStatusChangeResult> activatePrice(
    String priceId,
  ) async {
    await Future<void>.delayed(Duration.zero);
    final result = _repository.activatePrice(priceId);
    notifyListeners();
    return result;
  }

  Future<BusinessCatalogPricingStatusChangeResult> archivePrice(
    String priceId,
  ) async {
    await Future<void>.delayed(Duration.zero);
    final result = _repository.archivePrice(priceId);
    notifyListeners();
    return result;
  }

  Future<BusinessCatalogPricingSaveResult> _save(
    BusinessCatalogPricingSaveResult Function() action,
  ) async {
    if (_saveBusy) {
      return BusinessCatalogPricingSaveResult.failure;
    }
    _saveBusy = true;
    notifyListeners();
    await Future<void>.delayed(Duration.zero);
    final result = action();
    _saveBusy = false;
    notifyListeners();
    return result;
  }
}

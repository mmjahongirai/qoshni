import 'package:flutter/foundation.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_listing_attribute.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_listing_kind.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_catalog_listing_attribute_repository.dart';

class BusinessCatalogListingAttributeController extends ChangeNotifier {
  BusinessCatalogListingAttributeController(this._repository);

  final BusinessCatalogListingAttributeRepository _repository;

  bool _saveBusy = false;

  bool get saveBusy => _saveBusy;

  List<BusinessCatalogListingAttribute> attributesForListing({
    required BusinessCatalogListingKind listingKind,
    required String listingId,
  }) =>
      _repository.attributesForListing(
        listingKind: listingKind,
        listingId: listingId,
      );

  void refresh() => notifyListeners();

  Future<BusinessCatalogListingAttributeSaveResult> createAttribute({
    required BusinessCatalogListingKind listingKind,
    required String listingId,
    required BusinessCatalogListingAttributeInput input,
  }) async {
    return _save(
      () => _repository.createAttribute(
        listingKind: listingKind,
        listingId: listingId,
        input: input,
      ),
    );
  }

  Future<BusinessCatalogListingAttributeSaveResult> updateAttribute({
    required String attributeId,
    required BusinessCatalogListingAttributeInput input,
  }) async {
    return _save(
      () => _repository.updateAttribute(attributeId: attributeId, input: input),
    );
  }

  Future<BusinessCatalogListingAttributeDeleteResult> deleteAttribute(
    String attributeId,
  ) async {
    if (_saveBusy) {
      return BusinessCatalogListingAttributeDeleteResult.failure;
    }
    _saveBusy = true;
    notifyListeners();
    await Future<void>.delayed(Duration.zero);
    final result = _repository.deleteAttribute(attributeId);
    _saveBusy = false;
    notifyListeners();
    return result;
  }

  Future<BusinessCatalogListingAttributeSaveResult> _save(
    BusinessCatalogListingAttributeSaveResult Function() action,
  ) async {
    if (_saveBusy) {
      return BusinessCatalogListingAttributeSaveResult.failure;
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

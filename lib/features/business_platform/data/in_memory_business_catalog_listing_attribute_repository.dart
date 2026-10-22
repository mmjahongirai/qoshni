import 'package:qoshni/features/business_platform/data/business_catalog_listing_attribute_demo_seed.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_attribute_value_kind.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_listing_attribute.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_listing_kind.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_product.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_catalog_listing_attribute_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_catalog_product_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_catalog_service_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_owner_profile_repository.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_listing_attribute_validation.dart';

class InMemoryBusinessCatalogListingAttributeRepository
    implements BusinessCatalogListingAttributeRepository {
  InMemoryBusinessCatalogListingAttributeRepository(
    this._ownerProfileRepository,
    this._productRepository,
    this._serviceRepository,
  );

  final BusinessOwnerProfileRepository _ownerProfileRepository;
  final BusinessCatalogProductRepository _productRepository;
  final BusinessCatalogServiceRepository _serviceRepository;

  final Map<String, List<BusinessCatalogListingAttribute>> _attributesByScope = {};
  int _userAttributeCounter = 0;

  bool failNextSave = false;

  @override
  String get businessScopeId =>
      _ownerProfileRepository.ensureSessionProfile().sessionProfileId;

  @override
  List<BusinessCatalogListingAttribute> attributesForListing({
    required BusinessCatalogListingKind listingKind,
    required String listingId,
  }) {
    if (!_listingInScope(listingKind, listingId)) {
      return const [];
    }
    return _ensureScopeList()
        .where(
          (a) => a.listingKind == listingKind && a.listingId == listingId.trim(),
        )
        .toList(growable: false);
  }

  @override
  BusinessCatalogListingAttribute? findById(String attributeId) {
    try {
      return _ensureScopeList().firstWhere((a) => a.attributeId == attributeId);
    } on StateError {
      return null;
    }
  }

  @override
  BusinessCatalogListingAttributeSaveResult createAttribute({
    required BusinessCatalogListingKind listingKind,
    required String listingId,
    required BusinessCatalogListingAttributeInput input,
  }) {
    if (failNextSave) {
      failNextSave = false;
      return BusinessCatalogListingAttributeSaveResult.failure;
    }
    final id = listingId.trim();
    if (!_listingInScope(listingKind, id)) {
      return BusinessCatalogListingAttributeSaveResult.invalidListing;
    }
    if (validateCatalogListingAttributeInput(input) !=
        CatalogListingAttributeValidationIssue.none) {
      return BusinessCatalogListingAttributeSaveResult.invalidInput;
    }
    final key = input.key.trim();
    if (_keyTaken(listingKind, id, key)) {
      return BusinessCatalogListingAttributeSaveResult.duplicateKey;
    }
    final now = DateTime.now();
    _userAttributeCounter++;
    _ensureScopeList().add(
      BusinessCatalogListingAttribute(
        attributeId: 'session-catalog-attr-$_userAttributeCounter',
        listingKind: listingKind,
        listingId: id,
        businessScopeId: businessScopeId,
        dataSource: BusinessCatalogProductDataSource.userSession,
        key: key,
        label: input.label.trimmed(),
        valueKind: input.valueKind,
        textValue: input.textValue.trim(),
        numberValue: input.numberValue,
        choiceValue: input.choiceValue.trim(),
        createdAt: now,
        updatedAt: now,
      ),
    );
    return BusinessCatalogListingAttributeSaveResult.success;
  }

  @override
  BusinessCatalogListingAttributeSaveResult updateAttribute({
    required String attributeId,
    required BusinessCatalogListingAttributeInput input,
  }) {
    if (failNextSave) {
      failNextSave = false;
      return BusinessCatalogListingAttributeSaveResult.failure;
    }
    final list = _ensureScopeList();
    final index = list.indexWhere((a) => a.attributeId == attributeId);
    if (index < 0) {
      return BusinessCatalogListingAttributeSaveResult.notFound;
    }
    if (validateCatalogListingAttributeInput(input) !=
        CatalogListingAttributeValidationIssue.none) {
      return BusinessCatalogListingAttributeSaveResult.invalidInput;
    }
    final existing = list[index];
    final key = input.key.trim();
    if (_keyTaken(
      existing.listingKind,
      existing.listingId,
      key,
      exceptAttributeId: attributeId,
    )) {
      return BusinessCatalogListingAttributeSaveResult.duplicateKey;
    }
    list[index] = existing.copyWith(
      key: key,
      label: input.label.trimmed(),
      valueKind: input.valueKind,
      textValue: input.textValue.trim(),
      numberValue: input.valueKind == BusinessCatalogAttributeValueKind.number
          ? input.numberValue
          : null,
      clearNumber: input.valueKind != BusinessCatalogAttributeValueKind.number,
      choiceValue: input.choiceValue.trim(),
      updatedAt: DateTime.now(),
    );
    return BusinessCatalogListingAttributeSaveResult.success;
  }

  @override
  BusinessCatalogListingAttributeDeleteResult deleteAttribute(String attributeId) {
    final list = _ensureScopeList();
    final index = list.indexWhere((a) => a.attributeId == attributeId);
    if (index < 0) {
      return BusinessCatalogListingAttributeDeleteResult.notFound;
    }
    list.removeAt(index);
    return BusinessCatalogListingAttributeDeleteResult.success;
  }

  bool _listingInScope(BusinessCatalogListingKind kind, String listingId) {
    switch (kind) {
      case BusinessCatalogListingKind.product:
        final product = _productRepository.findById(listingId);
        return product != null && product.businessScopeId == businessScopeId;
      case BusinessCatalogListingKind.service:
        final service = _serviceRepository.findById(listingId);
        return service != null && service.businessScopeId == businessScopeId;
    }
  }

  bool _keyTaken(
    BusinessCatalogListingKind kind,
    String listingId,
    String key, {
    String? exceptAttributeId,
  }) {
    final normalized = key.toLowerCase();
    for (final attribute in _ensureScopeList()) {
      if (attribute.listingKind != kind || attribute.listingId != listingId) {
        continue;
      }
      if (exceptAttributeId != null && attribute.attributeId == exceptAttributeId) {
        continue;
      }
      if (attribute.key.toLowerCase() == normalized) {
        return true;
      }
    }
    return false;
  }

  List<BusinessCatalogListingAttribute> _ensureScopeList() {
    final scope = businessScopeId;
    return _attributesByScope.putIfAbsent(
      scope,
      () => buildDemoCatalogListingAttributes(businessScopeId: scope),
    );
  }
}

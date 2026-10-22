import 'package:qoshni/features/business_platform/data/business_catalog_product_option_demo_seed.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_listing_status.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_option.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_option_group.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_product.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_catalog_product_option_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_catalog_product_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_owner_profile_repository.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_option_validation.dart';

class InMemoryBusinessCatalogProductOptionRepository
    implements BusinessCatalogProductOptionRepository {
  InMemoryBusinessCatalogProductOptionRepository(
    this._ownerProfileRepository,
    this._productRepository,
  );

  final BusinessOwnerProfileRepository _ownerProfileRepository;
  final BusinessCatalogProductRepository _productRepository;

  final Map<String, List<BusinessCatalogOptionGroup>> _groupsByScope = {};
  int _userGroupCounter = 0;
  int _userOptionCounter = 0;

  bool failNextSave = false;

  @override
  String get businessScopeId =>
      _ownerProfileRepository.ensureSessionProfile().sessionProfileId;

  @override
  List<BusinessCatalogOptionGroup> groupsForProduct(
    String productId, {
    bool includeArchived = false,
  }) {
    if (!_productInScope(productId)) {
      return const [];
    }
    return _ensureScopeList()
        .where((g) => g.productId == productId)
        .where((g) => includeArchived || g.status != BusinessCatalogListingStatus.archived)
        .map(_cloneGroup)
        .toList(growable: false);
  }

  @override
  BusinessCatalogOptionGroup? findGroupById(String groupId) {
    try {
      return _cloneGroup(
        _ensureScopeList().firstWhere((g) => g.groupId == groupId),
      );
    } on StateError {
      return null;
    }
  }

  @override
  BusinessCatalogOption? findOptionById(String optionId) {
    for (final group in _ensureScopeList()) {
      for (final option in group.options) {
        if (option.optionId == optionId) {
          return option;
        }
      }
    }
    return null;
  }

  @override
  BusinessCatalogOptionGroupSaveResult createGroup({
    required String productId,
    required BusinessCatalogOptionGroupInput input,
  }) {
    if (failNextSave) {
      failNextSave = false;
      return BusinessCatalogOptionGroupSaveResult.failure;
    }
    if (!_productInScope(productId)) {
      return BusinessCatalogOptionGroupSaveResult.invalidProduct;
    }
    if (validateCatalogOptionGroupInput(input) !=
        CatalogOptionGroupValidationIssue.none) {
      return BusinessCatalogOptionGroupSaveResult.invalidInput;
    }
    final now = DateTime.now();
    _userGroupCounter++;
    _ensureScopeList().add(
      BusinessCatalogOptionGroup(
        groupId: 'session-catalog-option-group-$_userGroupCounter',
        productId: productId.trim(),
        businessScopeId: businessScopeId,
        dataSource: BusinessCatalogProductDataSource.userSession,
        status: input.status,
        localized: input.localized.trimmed(),
        description: input.description.trimmed(),
        selectionMode: input.selectionMode,
        required: input.required,
        minSelections: input.minSelections,
        maxSelections: input.maxSelections,
        options: const [],
        createdAt: now,
        updatedAt: now,
      ),
    );
    return BusinessCatalogOptionGroupSaveResult.success;
  }

  @override
  BusinessCatalogOptionGroupSaveResult updateGroup({
    required String groupId,
    required BusinessCatalogOptionGroupInput input,
  }) {
    if (failNextSave) {
      failNextSave = false;
      return BusinessCatalogOptionGroupSaveResult.failure;
    }
    final list = _ensureScopeList();
    final index = list.indexWhere((g) => g.groupId == groupId);
    if (index < 0) {
      return BusinessCatalogOptionGroupSaveResult.notFound;
    }
    if (validateCatalogOptionGroupInput(input) !=
        CatalogOptionGroupValidationIssue.none) {
      return BusinessCatalogOptionGroupSaveResult.invalidInput;
    }
    final existing = list[index];
    list[index] = existing.copyWith(
      status: input.status,
      localized: input.localized.trimmed(),
      description: input.description.trimmed(),
      selectionMode: input.selectionMode,
      required: input.required,
      minSelections: input.minSelections,
      maxSelections: input.maxSelections,
      updatedAt: DateTime.now(),
    );
    return BusinessCatalogOptionGroupSaveResult.success;
  }

  @override
  BusinessCatalogOptionGroupArchiveResult archiveGroup(String groupId) {
    final list = _ensureScopeList();
    final index = list.indexWhere((g) => g.groupId == groupId);
    if (index < 0) {
      return BusinessCatalogOptionGroupArchiveResult.notFound;
    }
    list[index] = list[index].copyWith(
      status: BusinessCatalogListingStatus.archived,
      updatedAt: DateTime.now(),
    );
    return BusinessCatalogOptionGroupArchiveResult.success;
  }

  @override
  BusinessCatalogOptionSaveResult createOption({
    required String groupId,
    required BusinessCatalogOptionInput input,
  }) {
    if (failNextSave) {
      failNextSave = false;
      return BusinessCatalogOptionSaveResult.failure;
    }
    final list = _ensureScopeList();
    final index = list.indexWhere((g) => g.groupId == groupId);
    if (index < 0) {
      return BusinessCatalogOptionSaveResult.invalidGroup;
    }
    if (validateCatalogOptionInput(input.localized) !=
        CatalogOptionValidationIssue.none) {
      return BusinessCatalogOptionSaveResult.invalidInput;
    }
    final group = list[index];
    if (!_productInScope(group.productId)) {
      return BusinessCatalogOptionSaveResult.invalidProduct;
    }
    final now = DateTime.now();
    _userOptionCounter++;
    final option = BusinessCatalogOption(
      optionId: 'session-catalog-option-$_userOptionCounter',
      groupId: group.groupId,
      productId: group.productId,
      businessScopeId: businessScopeId,
      dataSource: BusinessCatalogProductDataSource.userSession,
      localized: input.localized.trimmed(),
      isActive: input.isActive,
      createdAt: now,
      updatedAt: now,
    );
    list[index] = group.copyWith(
      options: [...group.options, option],
      updatedAt: now,
    );
    return BusinessCatalogOptionSaveResult.success;
  }

  @override
  BusinessCatalogOptionSaveResult updateOption({
    required String optionId,
    required BusinessCatalogOptionInput input,
  }) {
    if (failNextSave) {
      failNextSave = false;
      return BusinessCatalogOptionSaveResult.failure;
    }
    if (validateCatalogOptionInput(input.localized) !=
        CatalogOptionValidationIssue.none) {
      return BusinessCatalogOptionSaveResult.invalidInput;
    }
    final list = _ensureScopeList();
    for (var gi = 0; gi < list.length; gi++) {
      final group = list[gi];
      final oi = group.options.indexWhere((o) => o.optionId == optionId);
      if (oi < 0) {
        continue;
      }
      if (!_productInScope(group.productId)) {
        return BusinessCatalogOptionSaveResult.invalidProduct;
      }
      final updated = group.options[oi].copyWith(
        localized: input.localized.trimmed(),
        isActive: input.isActive,
        updatedAt: DateTime.now(),
      );
      final options = [...group.options];
      options[oi] = updated;
      list[gi] = group.copyWith(
        options: options,
        updatedAt: DateTime.now(),
      );
      return BusinessCatalogOptionSaveResult.success;
    }
    return BusinessCatalogOptionSaveResult.notFound;
  }

  @override
  BusinessCatalogOptionSaveResult setOptionActive({
    required String optionId,
    required bool isActive,
  }) {
    final option = findOptionById(optionId);
    if (option == null) {
      return BusinessCatalogOptionSaveResult.notFound;
    }
    return updateOption(
      optionId: optionId,
      input: BusinessCatalogOptionInput(
        localized: option.localized,
        isActive: isActive,
      ),
    );
  }

  bool _productInScope(String productId) {
    final product = _productRepository.findById(productId.trim());
    return product != null && product.businessScopeId == businessScopeId;
  }

  List<BusinessCatalogOptionGroup> _ensureScopeList() {
    final scope = businessScopeId;
    return _groupsByScope.putIfAbsent(
      scope,
      () => buildDemoCatalogOptionGroups(businessScopeId: scope),
    );
  }

  BusinessCatalogOptionGroup _cloneGroup(BusinessCatalogOptionGroup group) {
    return group.copyWith(options: List.unmodifiable(group.options));
  }
}

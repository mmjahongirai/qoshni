import 'package:flutter/foundation.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_option.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_option_group.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_catalog_product_option_repository.dart';

class BusinessCatalogProductOptionController extends ChangeNotifier {
  BusinessCatalogProductOptionController(this._repository);

  final BusinessCatalogProductOptionRepository _repository;

  bool _saveBusy = false;

  bool get saveBusy => _saveBusy;

  List<BusinessCatalogOptionGroup> groupsForProduct(
    String productId, {
    bool includeArchived = false,
  }) =>
      _repository.groupsForProduct(
        productId,
        includeArchived: includeArchived,
      );

  BusinessCatalogOptionGroup? groupById(String groupId) =>
      _repository.findGroupById(groupId);

  void refresh() => notifyListeners();

  Future<BusinessCatalogOptionGroupSaveResult> createGroup({
    required String productId,
    required BusinessCatalogOptionGroupInput input,
  }) async {
    return _saveGroup(() => _repository.createGroup(productId: productId, input: input));
  }

  Future<BusinessCatalogOptionGroupSaveResult> updateGroup({
    required String groupId,
    required BusinessCatalogOptionGroupInput input,
  }) async {
    return _saveGroup(() => _repository.updateGroup(groupId: groupId, input: input));
  }

  Future<BusinessCatalogOptionGroupArchiveResult> archiveGroup(String groupId) async {
    if (_saveBusy) {
      return BusinessCatalogOptionGroupArchiveResult.failure;
    }
    _saveBusy = true;
    notifyListeners();
    await Future<void>.delayed(Duration.zero);
    final result = _repository.archiveGroup(groupId);
    _saveBusy = false;
    notifyListeners();
    return result;
  }

  Future<BusinessCatalogOptionSaveResult> createOption({
    required String groupId,
    required BusinessCatalogOptionInput input,
  }) async {
    return _saveOption(() => _repository.createOption(groupId: groupId, input: input));
  }

  Future<BusinessCatalogOptionSaveResult> updateOption({
    required String optionId,
    required BusinessCatalogOptionInput input,
  }) async {
    return _saveOption(() => _repository.updateOption(optionId: optionId, input: input));
  }

  Future<BusinessCatalogOptionSaveResult> setOptionActive({
    required String optionId,
    required bool isActive,
  }) async {
    return _saveOption(
      () => _repository.setOptionActive(optionId: optionId, isActive: isActive),
    );
  }

  Future<BusinessCatalogOptionGroupSaveResult> _saveGroup(
    BusinessCatalogOptionGroupSaveResult Function() action,
  ) async {
    if (_saveBusy) {
      return BusinessCatalogOptionGroupSaveResult.failure;
    }
    _saveBusy = true;
    notifyListeners();
    await Future<void>.delayed(Duration.zero);
    final result = action();
    _saveBusy = false;
    notifyListeners();
    return result;
  }

  Future<BusinessCatalogOptionSaveResult> _saveOption(
    BusinessCatalogOptionSaveResult Function() action,
  ) async {
    if (_saveBusy) {
      return BusinessCatalogOptionSaveResult.failure;
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

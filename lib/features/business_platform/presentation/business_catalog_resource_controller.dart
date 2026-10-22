import 'package:flutter/foundation.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_resource.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_resource_capacity_event.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_resource_status.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_resource_type.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_catalog_resource_repository.dart';

class BusinessCatalogResourceController extends ChangeNotifier {
  BusinessCatalogResourceController(this._repository);

  final BusinessCatalogResourceRepository _repository;

  bool _listLoading = true;
  bool _saveBusy = false;

  bool get listLoading => _listLoading;
  bool get saveBusy => _saveBusy;

  List<BusinessCatalogResource> resources({
    String? branchId,
    BusinessCatalogResourceType? type,
    BusinessCatalogResourceStatus? status,
  }) =>
      _repository.listForCurrentScope(
        branchId: branchId,
        type: type,
        status: status,
      );

  BusinessCatalogResource? resourceById(String resourceId) =>
      _repository.findById(resourceId);

  List<BusinessCatalogResourceCapacityEvent> capacityHistory(String resourceId) =>
      _repository.capacityHistory(resourceId);

  Future<void> refreshList() async {
    _listLoading = true;
    notifyListeners();
    await Future<void>.delayed(Duration.zero);
    _repository.listForCurrentScope();
    _listLoading = false;
    notifyListeners();
  }

  Future<BusinessCatalogResourceSaveResult> createResource(
    BusinessCatalogResourceInput input,
  ) async {
    return _save(() => _repository.createResource(input));
  }

  Future<BusinessCatalogResourceSaveResult> updateResource(
    String resourceId,
    BusinessCatalogResourceInput input,
  ) async {
    return _save(() => _repository.updateResource(resourceId, input));
  }

  Future<BusinessCatalogResourceSaveResult> setStatus({
    required String resourceId,
    required BusinessCatalogResourceStatus status,
  }) async {
    await Future<void>.delayed(Duration.zero);
    final result = _repository.setStatus(
      resourceId: resourceId,
      status: status,
    );
    notifyListeners();
    return result;
  }

  Future<BusinessCatalogResourceCapacityChangeResult> changeTotalCapacity({
    required String resourceId,
    required BusinessCatalogResourceCapacityChangeInput input,
  }) async {
    if (_saveBusy) {
      return BusinessCatalogResourceCapacityChangeResult.failure;
    }
    _saveBusy = true;
    notifyListeners();
    await Future<void>.delayed(Duration.zero);
    final result = _repository.changeTotalCapacity(
      resourceId: resourceId,
      input: input,
    );
    _saveBusy = false;
    notifyListeners();
    return result;
  }

  Future<BusinessCatalogResourceSaveResult> archiveResource(
    String resourceId,
  ) async {
    return setStatus(
      resourceId: resourceId,
      status: BusinessCatalogResourceStatus.archived,
    );
  }

  Future<BusinessCatalogResourceSaveResult> _save(
    BusinessCatalogResourceSaveResult Function() action,
  ) async {
    if (_saveBusy) {
      return BusinessCatalogResourceSaveResult.failure;
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

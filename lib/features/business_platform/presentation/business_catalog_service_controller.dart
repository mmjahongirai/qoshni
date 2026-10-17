import 'package:flutter/foundation.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_service.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_catalog_service_repository.dart';

class BusinessCatalogServiceController extends ChangeNotifier {
  BusinessCatalogServiceController(this._repository);

  final BusinessCatalogServiceRepository _repository;

  bool _saveBusy = false;

  bool get saveBusy => _saveBusy;

  List<BusinessCatalogService> get services => _repository.listForCurrentScope();

  BusinessCatalogService? serviceById(String serviceId) =>
      _repository.findById(serviceId);

  void refresh() => notifyListeners();

  Future<BusinessCatalogServiceSaveResult> createService(
    BusinessCatalogServiceInput input,
  ) async {
    return _save(() => _repository.createService(input));
  }

  Future<BusinessCatalogServiceSaveResult> updateService(
    String serviceId,
    BusinessCatalogServiceInput input,
  ) async {
    return _save(() => _repository.updateService(serviceId, input));
  }

  Future<BusinessCatalogServiceSaveResult> _save(
    BusinessCatalogServiceSaveResult Function() action,
  ) async {
    if (_saveBusy) {
      return BusinessCatalogServiceSaveResult.failure;
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

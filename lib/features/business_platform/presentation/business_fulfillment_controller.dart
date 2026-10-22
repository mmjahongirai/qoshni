import 'package:flutter/foundation.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_price_status.dart';
import 'package:qoshni/features/business_platform/domain/business_fulfillment_configuration.dart';
import 'package:qoshni/features/business_platform/domain/business_fulfillment_history_event.dart';
import 'package:qoshni/features/business_platform/domain/business_fulfillment_type.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_fulfillment_repository.dart';

class BusinessFulfillmentController extends ChangeNotifier {
  BusinessFulfillmentController(this._repository);

  final BusinessFulfillmentRepository _repository;

  bool _listLoading = true;
  bool _saveBusy = false;

  bool get listLoading => _listLoading;
  bool get saveBusy => _saveBusy;

  List<BusinessFulfillmentConfiguration> configurations({
    String? branchId,
    BusinessFulfillmentType? fulfillmentType,
    BusinessCatalogPriceStatus? status,
  }) =>
      _repository.listForCurrentScope(
        branchId: branchId,
        fulfillmentType: fulfillmentType,
        status: status,
      );

  BusinessFulfillmentConfiguration? configurationById(String configurationId) =>
      _repository.findById(configurationId);

  List<BusinessFulfillmentHistoryEvent> historyFor(String configurationId) =>
      _repository.configurationHistory(configurationId);

  Future<void> refreshList() async {
    _listLoading = true;
    notifyListeners();
    await Future<void>.delayed(Duration.zero);
    _repository.listForCurrentScope();
    _listLoading = false;
    notifyListeners();
  }

  Future<BusinessFulfillmentSaveResult> createDraft(
    BusinessFulfillmentConfigurationInput input,
  ) async {
    return _save(() => _repository.createDraft(input));
  }

  Future<BusinessFulfillmentSaveResult> updateDraft({
    required String configurationId,
    required BusinessFulfillmentConfigurationInput input,
  }) async {
    return _save(
      () => _repository.updateDraft(
        configurationId: configurationId,
        input: input,
      ),
    );
  }

  Future<BusinessFulfillmentStatusChangeResult> activateConfiguration(
    String configurationId,
  ) async {
    await Future<void>.delayed(Duration.zero);
    final result = _repository.activateConfiguration(configurationId);
    notifyListeners();
    return result;
  }

  Future<BusinessFulfillmentStatusChangeResult> archiveConfiguration(
    String configurationId,
  ) async {
    await Future<void>.delayed(Duration.zero);
    final result = _repository.archiveConfiguration(configurationId);
    notifyListeners();
    return result;
  }

  Future<BusinessFulfillmentSaveResult> _save(
    BusinessFulfillmentSaveResult Function() action,
  ) async {
    if (_saveBusy) {
      return BusinessFulfillmentSaveResult.failure;
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

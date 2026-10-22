import 'package:flutter/foundation.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_commercial_fee_history_event.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_commercial_fee_rule.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_commercial_fee_type.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_price_status.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_catalog_commercial_fee_repository.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_commercial_fee_preview.dart';

class BusinessCatalogCommercialFeeController extends ChangeNotifier {
  BusinessCatalogCommercialFeeController(this._repository);

  final BusinessCatalogCommercialFeeRepository _repository;

  bool _listLoading = true;
  bool _saveBusy = false;

  bool get listLoading => _listLoading;
  bool get saveBusy => _saveBusy;

  String get businessScopeId => _repository.businessScopeId;

  List<BusinessCatalogCommercialFeeRule> rules({
    String? branchId,
    BusinessCatalogCommercialFeeType? feeType,
    BusinessCatalogPriceStatus? status,
  }) =>
      _repository.listForCurrentScope(
        branchId: branchId,
        feeType: feeType,
        status: status,
      );

  List<BusinessCatalogCommercialFeeRule> allRulesIncludingArchived() =>
      _repository.listForCurrentScope(includeArchived: true);

  BusinessCatalogCommercialFeeRule? ruleById(String feeRuleId) =>
      _repository.findById(feeRuleId);

  List<BusinessCatalogCommercialFeeHistoryEvent> historyFor(String feeRuleId) =>
      _repository.ruleHistory(feeRuleId);

  CommercialFeesPreviewResult previewFees({
    required String branchId,
    required DateTime asOf,
    int? listingBaseAmountSom,
    int? serviceAmountSom,
    int? deliveryBasisAmountSom,
    int? commissionBasisAmountSom,
  }) {
    return calculateCommercialFeesPreview(
      businessScopeId: businessScopeId,
      branchId: branchId,
      asOf: asOf,
      listingBaseAmountSom: listingBaseAmountSom,
      serviceAmountSom: serviceAmountSom,
      deliveryBasisAmountSom: deliveryBasisAmountSom,
      commissionBasisAmountSom: commissionBasisAmountSom,
      rules: allRulesIncludingArchived(),
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

  Future<BusinessCatalogCommercialFeeSaveResult> createDraft(
    BusinessCatalogCommercialFeeRuleInput input,
  ) async {
    return _save(() => _repository.createDraft(input));
  }

  Future<BusinessCatalogCommercialFeeSaveResult> updateDraft({
    required String feeRuleId,
    required BusinessCatalogCommercialFeeRuleInput input,
  }) async {
    return _save(
      () => _repository.updateDraft(feeRuleId: feeRuleId, input: input),
    );
  }

  Future<BusinessCatalogCommercialFeeStatusChangeResult> activateRule(
    String feeRuleId,
  ) async {
    await Future<void>.delayed(Duration.zero);
    final result = _repository.activateRule(feeRuleId);
    notifyListeners();
    return result;
  }

  Future<BusinessCatalogCommercialFeeStatusChangeResult> archiveRule(
    String feeRuleId,
  ) async {
    await Future<void>.delayed(Duration.zero);
    final result = _repository.archiveRule(feeRuleId);
    notifyListeners();
    return result;
  }

  Future<BusinessCatalogCommercialFeeSaveResult> _save(
    BusinessCatalogCommercialFeeSaveResult Function() action,
  ) async {
    if (_saveBusy) {
      return BusinessCatalogCommercialFeeSaveResult.failure;
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

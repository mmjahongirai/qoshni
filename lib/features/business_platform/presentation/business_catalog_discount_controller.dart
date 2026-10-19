import 'package:flutter/foundation.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_discount_rule.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_discount_target_scope.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_discount_history_event.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_listing_kind.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_price_status.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_catalog_discount_repository.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_discount_resolver.dart';

class BusinessCatalogDiscountController extends ChangeNotifier {
  BusinessCatalogDiscountController(this._repository);

  final BusinessCatalogDiscountRepository _repository;

  bool _listLoading = true;
  bool _saveBusy = false;

  bool get listLoading => _listLoading;
  bool get saveBusy => _saveBusy;

  List<BusinessCatalogDiscountRule> rules({
    String? branchId,
    BusinessCatalogDiscountTargetScope? targetScope,
    BusinessCatalogPriceStatus? status,
  }) =>
      _repository.listForCurrentScope(
        branchId: branchId,
        targetScope: targetScope,
        status: status,
      );

  List<BusinessCatalogDiscountRule> allRulesIncludingArchived() =>
      _repository.listForCurrentScope(includeArchived: true);

  BusinessCatalogDiscountRule? ruleById(String discountRuleId) =>
      _repository.findById(discountRuleId);

  List<BusinessCatalogDiscountHistoryEvent> historyFor(String discountRuleId) =>
      _repository.ruleHistory(discountRuleId);

  CatalogDiscountResolution resolveDiscount({
    required BusinessCatalogListingKind listingKind,
    required String listingId,
    required String branchId,
    String? variantId,
    required int basePriceAmountSom,
    int? qualifyingSubtotalAmountSom,
    required DateTime asOf,
  }) {
    return resolveCatalogDiscount(
      rules: allRulesIncludingArchived(),
      listingKind: listingKind,
      listingId: listingId,
      branchId: branchId,
      variantId: variantId,
      basePriceAmountSom: basePriceAmountSom,
      qualifyingSubtotalAmountSom: qualifyingSubtotalAmountSom,
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

  Future<BusinessCatalogDiscountSaveResult> createDraft(
    BusinessCatalogDiscountRuleInput input,
  ) async {
    return _save(() => _repository.createDraft(input));
  }

  Future<BusinessCatalogDiscountSaveResult> updateDraft({
    required String discountRuleId,
    required BusinessCatalogDiscountRuleInput input,
  }) async {
    return _save(
      () => _repository.updateDraft(
        discountRuleId: discountRuleId,
        input: input,
      ),
    );
  }

  Future<BusinessCatalogDiscountSaveResult> createRevision({
    required String sourceRuleId,
    required BusinessCatalogDiscountRuleInput input,
  }) async {
    return _save(
      () => _repository.createRevisionFromRule(
        sourceRuleId: sourceRuleId,
        input: input,
      ),
    );
  }

  Future<BusinessCatalogDiscountStatusChangeResult> activateRule(
    String discountRuleId,
  ) async {
    await Future<void>.delayed(Duration.zero);
    final result = _repository.activateRule(discountRuleId);
    notifyListeners();
    return result;
  }

  Future<BusinessCatalogDiscountStatusChangeResult> archiveRule(
    String discountRuleId,
  ) async {
    await Future<void>.delayed(Duration.zero);
    final result = _repository.archiveRule(discountRuleId);
    notifyListeners();
    return result;
  }

  Future<BusinessCatalogDiscountSaveResult> _save(
    BusinessCatalogDiscountSaveResult Function() action,
  ) async {
    if (_saveBusy) {
      return BusinessCatalogDiscountSaveResult.failure;
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

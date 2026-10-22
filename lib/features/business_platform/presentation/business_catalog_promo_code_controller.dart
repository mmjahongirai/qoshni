import 'package:flutter/foundation.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_discount_rule.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_listing_kind.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_price_status.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_promo_code.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_promo_code_history_event.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_promo_code_usage_record.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_catalog_discount_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_catalog_promo_code_repository.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_promo_eligibility.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_promo_code_validation.dart';

class BusinessCatalogPromoCodeController extends ChangeNotifier {
  BusinessCatalogPromoCodeController(
    this._promoRepository,
    this._discountRepository,
  );

  final BusinessCatalogPromoCodeRepository _promoRepository;
  final BusinessCatalogDiscountRepository _discountRepository;

  bool _listLoading = true;
  bool _saveBusy = false;

  bool get listLoading => _listLoading;
  bool get saveBusy => _saveBusy;

  List<BusinessCatalogPromoCode> promoCodes({
    String? branchId,
    BusinessCatalogPriceStatus? status,
  }) =>
      _promoRepository.listForCurrentScope(
        branchId: branchId,
        status: status,
      );

  BusinessCatalogPromoCode? promoById(String promoCodeId) =>
      _promoRepository.findById(promoCodeId);

  List<BusinessCatalogPromoCodeHistoryEvent> historyFor(String promoCodeId) =>
      _promoRepository.promoHistory(promoCodeId);

  List<BusinessCatalogPromoCodeUsageRecord> usageFor(String promoCodeId) =>
      _promoRepository.usageRecords(promoCodeId);

  CatalogPromoUsageSnapshot usageSnapshot({
    required String promoCodeId,
    String? demoCustomerReference,
  }) =>
      _promoRepository.usageSnapshot(
        promoCodeId: promoCodeId,
        demoCustomerReference: demoCustomerReference,
      );

  CatalogPromoCodeEligibilityResult evaluateEligibility({
    required String enteredCode,
    required String branchId,
    required BusinessCatalogListingKind listingKind,
    required String listingId,
    String? variantId,
    required DateTime asOf,
    int? basePriceAmountSom,
    int? qualifyingSubtotalAmountSom,
    String? demoCustomerReference,
  }) {
    final normalized = catalogPromoCodeNormalize(enteredCode);
    final promo = normalized == null
        ? null
        : _promoRepository.findByNormalizedCode(normalized);
    BusinessCatalogDiscountRule? discount;
    if (promo != null) {
      discount = _discountRepository.findById(promo.discountRuleId);
    }
    final snapshot = promo == null
        ? null
        : _promoRepository.usageSnapshot(
            promoCodeId: promo.promoCodeId,
            demoCustomerReference: demoCustomerReference,
          );
    return evaluateCatalogPromoCodeEligibility(
      enteredCode: enteredCode,
      businessScopeId: _promoRepository.businessScopeId,
      branchId: branchId,
      listingKind: listingKind,
      listingId: listingId,
      variantId: variantId,
      asOf: asOf,
      basePriceAmountSom: basePriceAmountSom,
      qualifyingSubtotalAmountSom: qualifyingSubtotalAmountSom,
      demoCustomerReference: demoCustomerReference,
      promo: promo,
      linkedDiscount: discount,
      usageSnapshot: snapshot,
    );
  }

  Future<void> refreshList() async {
    _listLoading = true;
    notifyListeners();
    await Future<void>.delayed(Duration.zero);
    _promoRepository.listForCurrentScope();
    _listLoading = false;
    notifyListeners();
  }

  Future<BusinessCatalogPromoCodeSaveResult> createDraft(
    BusinessCatalogPromoCodeInput input,
  ) async {
    return _save(() => _promoRepository.createDraft(input));
  }

  Future<BusinessCatalogPromoCodeSaveResult> updateDraft({
    required String promoCodeId,
    required BusinessCatalogPromoCodeInput input,
  }) async {
    return _save(
      () => _promoRepository.updateDraft(
        promoCodeId: promoCodeId,
        input: input,
      ),
    );
  }

  Future<BusinessCatalogPromoCodeStatusChangeResult> activatePromo(
    String promoCodeId,
  ) async {
    await Future<void>.delayed(Duration.zero);
    final result = _promoRepository.activatePromoCode(promoCodeId);
    notifyListeners();
    return result;
  }

  Future<BusinessCatalogPromoCodeStatusChangeResult> archivePromo(
    String promoCodeId,
  ) async {
    await Future<void>.delayed(Duration.zero);
    final result = _promoRepository.archivePromoCode(promoCodeId);
    notifyListeners();
    return result;
  }

  Future<BusinessCatalogPromoCodeSaveResult> _save(
    BusinessCatalogPromoCodeSaveResult Function() action,
  ) async {
    if (_saveBusy) {
      return BusinessCatalogPromoCodeSaveResult.failure;
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

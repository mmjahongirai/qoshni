import 'package:qoshni/features/business_platform/domain/business_catalog_price_status.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_product.dart';

class BusinessCatalogPromoCode {
  const BusinessCatalogPromoCode({
    required this.promoCodeId,
    required this.businessScopeId,
    this.branchId,
    required this.code,
    required this.normalizedCode,
    required this.discountRuleId,
    required this.status,
    required this.effectiveFrom,
    this.effectiveUntil,
    this.minimumBasketAmountSom,
    this.maxTotalUses,
    this.maxUsesPerCustomer,
    required this.revision,
    required this.dataSource,
    required this.createdAt,
    required this.updatedAt,
  });

  final String promoCodeId;
  final String businessScopeId;
  final String? branchId;
  final String code;
  final String normalizedCode;
  final String discountRuleId;
  final BusinessCatalogPriceStatus status;
  final DateTime effectiveFrom;
  final DateTime? effectiveUntil;
  final int? minimumBasketAmountSom;
  final int? maxTotalUses;
  final int? maxUsesPerCustomer;
  final int revision;
  final BusinessCatalogProductDataSource dataSource;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isDemoSeed => dataSource == BusinessCatalogProductDataSource.demoSeed;

  BusinessCatalogPromoCode copyWith({
    String? branchId,
    bool clearBranchId = false,
    String? code,
    String? normalizedCode,
    String? discountRuleId,
    BusinessCatalogPriceStatus? status,
    DateTime? effectiveFrom,
    DateTime? effectiveUntil,
    bool clearEffectiveUntil = false,
    int? minimumBasketAmountSom,
    bool clearMinimumBasketAmountSom = false,
    int? maxTotalUses,
    bool clearMaxTotalUses = false,
    int? maxUsesPerCustomer,
    bool clearMaxUsesPerCustomer = false,
    int? revision,
    DateTime? updatedAt,
  }) {
    return BusinessCatalogPromoCode(
      promoCodeId: promoCodeId,
      businessScopeId: businessScopeId,
      branchId: clearBranchId ? null : (branchId ?? this.branchId),
      code: code ?? this.code,
      normalizedCode: normalizedCode ?? this.normalizedCode,
      discountRuleId: discountRuleId ?? this.discountRuleId,
      status: status ?? this.status,
      effectiveFrom: effectiveFrom ?? this.effectiveFrom,
      effectiveUntil:
          clearEffectiveUntil ? null : (effectiveUntil ?? this.effectiveUntil),
      minimumBasketAmountSom: clearMinimumBasketAmountSom
          ? null
          : (minimumBasketAmountSom ?? this.minimumBasketAmountSom),
      maxTotalUses:
          clearMaxTotalUses ? null : (maxTotalUses ?? this.maxTotalUses),
      maxUsesPerCustomer: clearMaxUsesPerCustomer
          ? null
          : (maxUsesPerCustomer ?? this.maxUsesPerCustomer),
      revision: revision ?? this.revision,
      dataSource: dataSource,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class BusinessCatalogPromoCodeInput {
  const BusinessCatalogPromoCodeInput({
    this.branchId,
    required this.code,
    required this.discountRuleId,
    required this.effectiveFrom,
    this.effectiveUntil,
    this.minimumBasketAmountSom,
    this.maxTotalUses,
    this.maxUsesPerCustomer,
  });

  final String? branchId;
  final String code;
  final String discountRuleId;
  final DateTime effectiveFrom;
  final DateTime? effectiveUntil;
  final int? minimumBasketAmountSom;
  final int? maxTotalUses;
  final int? maxUsesPerCustomer;
}

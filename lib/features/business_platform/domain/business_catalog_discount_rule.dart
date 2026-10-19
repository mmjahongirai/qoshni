import 'package:qoshni/features/business_platform/domain/business_catalog_discount_target_scope.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_discount_type.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_product.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_price_status.dart';

class BusinessCatalogDiscountRule {
  const BusinessCatalogDiscountRule({
    required this.discountRuleId,
    required this.businessScopeId,
    required this.branchId,
    required this.targetScope,
    this.listingId,
    this.variantId,
    required this.discountType,
    this.percentBasisPoints,
    this.fixedAmountSom,
    this.minimumBasketAmountSom,
    required this.status,
    required this.effectiveFrom,
    this.effectiveUntil,
    required this.priority,
    required this.revision,
    required this.dataSource,
    required this.createdAt,
    required this.updatedAt,
  });

  final String discountRuleId;
  final String businessScopeId;
  final String branchId;
  final BusinessCatalogDiscountTargetScope targetScope;
  final String? listingId;
  final String? variantId;
  final BusinessCatalogDiscountType discountType;
  final int? percentBasisPoints;
  final int? fixedAmountSom;
  final int? minimumBasketAmountSom;
  final BusinessCatalogPriceStatus status;
  final DateTime effectiveFrom;
  final DateTime? effectiveUntil;
  final int priority;
  final int revision;
  final BusinessCatalogProductDataSource dataSource;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isDemoSeed => dataSource == BusinessCatalogProductDataSource.demoSeed;

  BusinessCatalogDiscountRule copyWith({
    String? branchId,
    BusinessCatalogDiscountTargetScope? targetScope,
    String? listingId,
    String? variantId,
    bool clearListingId = false,
    bool clearVariantId = false,
    BusinessCatalogDiscountType? discountType,
    int? percentBasisPoints,
    bool clearPercentBasisPoints = false,
    int? fixedAmountSom,
    bool clearFixedAmountSom = false,
    int? minimumBasketAmountSom,
    bool clearMinimumBasketAmountSom = false,
    BusinessCatalogPriceStatus? status,
    DateTime? effectiveFrom,
    DateTime? effectiveUntil,
    bool clearEffectiveUntil = false,
    int? priority,
    int? revision,
    DateTime? updatedAt,
  }) {
    return BusinessCatalogDiscountRule(
      discountRuleId: discountRuleId,
      businessScopeId: businessScopeId,
      branchId: branchId ?? this.branchId,
      targetScope: targetScope ?? this.targetScope,
      listingId: clearListingId ? null : (listingId ?? this.listingId),
      variantId: clearVariantId ? null : (variantId ?? this.variantId),
      discountType: discountType ?? this.discountType,
      percentBasisPoints: clearPercentBasisPoints
          ? null
          : (percentBasisPoints ?? this.percentBasisPoints),
      fixedAmountSom:
          clearFixedAmountSom ? null : (fixedAmountSom ?? this.fixedAmountSom),
      minimumBasketAmountSom: clearMinimumBasketAmountSom
          ? null
          : (minimumBasketAmountSom ?? this.minimumBasketAmountSom),
      status: status ?? this.status,
      effectiveFrom: effectiveFrom ?? this.effectiveFrom,
      effectiveUntil:
          clearEffectiveUntil ? null : (effectiveUntil ?? this.effectiveUntil),
      priority: priority ?? this.priority,
      revision: revision ?? this.revision,
      dataSource: dataSource,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class BusinessCatalogDiscountRuleInput {
  const BusinessCatalogDiscountRuleInput({
    required this.branchId,
    required this.targetScope,
    this.listingId,
    this.variantId,
    required this.discountType,
    this.percentBasisPoints,
    this.fixedAmountSom,
    this.minimumBasketAmountSom,
    required this.effectiveFrom,
    this.effectiveUntil,
    required this.priority,
  });

  final String branchId;
  final BusinessCatalogDiscountTargetScope targetScope;
  final String? listingId;
  final String? variantId;
  final BusinessCatalogDiscountType discountType;
  final int? percentBasisPoints;
  final int? fixedAmountSom;
  final int? minimumBasketAmountSom;
  final DateTime effectiveFrom;
  final DateTime? effectiveUntil;
  final int priority;
}

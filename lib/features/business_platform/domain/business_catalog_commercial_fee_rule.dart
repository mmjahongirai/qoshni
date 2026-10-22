import 'package:qoshni/features/business_platform/domain/business_catalog_commercial_fee_application_basis.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_commercial_fee_calculation_type.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_commercial_fee_charge_bearer.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_commercial_fee_type.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_price_status.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_product.dart';

class BusinessCatalogCommercialFeeRule {
  const BusinessCatalogCommercialFeeRule({
    required this.feeRuleId,
    required this.businessScopeId,
    this.branchId,
    required this.feeType,
    required this.chargeBearer,
    required this.calculationType,
    this.fixedAmountSom,
    this.percentBasisPoints,
    required this.applicationBasis,
    required this.status,
    required this.effectiveFrom,
    this.effectiveUntil,
    required this.priority,
    required this.revision,
    required this.dataSource,
    required this.createdAt,
    required this.updatedAt,
  });

  final String feeRuleId;
  final String businessScopeId;
  final String? branchId;
  final BusinessCatalogCommercialFeeType feeType;
  final BusinessCatalogCommercialFeeChargeBearer chargeBearer;
  final BusinessCatalogCommercialFeeCalculationType calculationType;
  final int? fixedAmountSom;
  final int? percentBasisPoints;
  final BusinessCatalogCommercialFeeApplicationBasis applicationBasis;
  final BusinessCatalogPriceStatus status;
  final DateTime effectiveFrom;
  final DateTime? effectiveUntil;
  final int priority;
  final int revision;
  final BusinessCatalogProductDataSource dataSource;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isDemoSeed => dataSource == BusinessCatalogProductDataSource.demoSeed;

  BusinessCatalogCommercialFeeRule copyWith({
    String? branchId,
    bool clearBranchId = false,
    BusinessCatalogCommercialFeeType? feeType,
    BusinessCatalogCommercialFeeChargeBearer? chargeBearer,
    BusinessCatalogCommercialFeeCalculationType? calculationType,
    int? fixedAmountSom,
    bool clearFixedAmountSom = false,
    int? percentBasisPoints,
    bool clearPercentBasisPoints = false,
    BusinessCatalogCommercialFeeApplicationBasis? applicationBasis,
    BusinessCatalogPriceStatus? status,
    DateTime? effectiveFrom,
    DateTime? effectiveUntil,
    bool clearEffectiveUntil = false,
    int? priority,
    int? revision,
    DateTime? updatedAt,
  }) {
    return BusinessCatalogCommercialFeeRule(
      feeRuleId: feeRuleId,
      businessScopeId: businessScopeId,
      branchId: clearBranchId ? null : (branchId ?? this.branchId),
      feeType: feeType ?? this.feeType,
      chargeBearer: chargeBearer ?? this.chargeBearer,
      calculationType: calculationType ?? this.calculationType,
      fixedAmountSom:
          clearFixedAmountSom ? null : (fixedAmountSom ?? this.fixedAmountSom),
      percentBasisPoints: clearPercentBasisPoints
          ? null
          : (percentBasisPoints ?? this.percentBasisPoints),
      applicationBasis: applicationBasis ?? this.applicationBasis,
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

class BusinessCatalogCommercialFeeRuleInput {
  const BusinessCatalogCommercialFeeRuleInput({
    this.branchId,
    required this.feeType,
    required this.chargeBearer,
    required this.calculationType,
    this.fixedAmountSom,
    this.percentBasisPoints,
    required this.applicationBasis,
    required this.effectiveFrom,
    this.effectiveUntil,
    required this.priority,
  });

  final String? branchId;
  final BusinessCatalogCommercialFeeType feeType;
  final BusinessCatalogCommercialFeeChargeBearer chargeBearer;
  final BusinessCatalogCommercialFeeCalculationType calculationType;
  final int? fixedAmountSom;
  final int? percentBasisPoints;
  final BusinessCatalogCommercialFeeApplicationBasis applicationBasis;
  final DateTime effectiveFrom;
  final DateTime? effectiveUntil;
  final int priority;
}

import 'package:qoshni/features/business_platform/domain/business_catalog_commercial_fee_application_basis.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_commercial_fee_calculation_type.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_commercial_fee_charge_bearer.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_commercial_fee_rule.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_commercial_fee_type.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_price_status.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_commercial_fee_validation.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_pricing_validation.dart';

enum CommercialFeeLineStatus {
  computed,
  basisMissing,
  notApplicableRule,
}

enum CommercialFeesPreviewStatus {
  success,
  ambiguous,
}

class CommercialFeeLinePreview {
  const CommercialFeeLinePreview({
    required this.status,
    required this.feeRuleId,
    required this.feeType,
    required this.chargeBearer,
    required this.applicationBasis,
    this.basisAmountSom,
    required this.calculationType,
    this.fixedAmountSom,
    this.percentBasisPoints,
    this.computedFeeSom,
  });

  const CommercialFeeLinePreview.basisMissing({
    required String feeRuleId,
    required BusinessCatalogCommercialFeeType feeType,
    required BusinessCatalogCommercialFeeChargeBearer chargeBearer,
    required BusinessCatalogCommercialFeeApplicationBasis applicationBasis,
    required BusinessCatalogCommercialFeeCalculationType calculationType,
    int? fixedAmountSom,
    int? percentBasisPoints,
  }) : this(
          status: CommercialFeeLineStatus.basisMissing,
          feeRuleId: feeRuleId,
          feeType: feeType,
          chargeBearer: chargeBearer,
          applicationBasis: applicationBasis,
          calculationType: calculationType,
          fixedAmountSom: fixedAmountSom,
          percentBasisPoints: percentBasisPoints,
        );

  const CommercialFeeLinePreview.computed({
    required String feeRuleId,
    required BusinessCatalogCommercialFeeType feeType,
    required BusinessCatalogCommercialFeeChargeBearer chargeBearer,
    required BusinessCatalogCommercialFeeApplicationBasis applicationBasis,
    required int basisAmountSom,
    required BusinessCatalogCommercialFeeCalculationType calculationType,
    int? fixedAmountSom,
    int? percentBasisPoints,
    required int computedFeeSom,
  }) : this(
          status: CommercialFeeLineStatus.computed,
          feeRuleId: feeRuleId,
          feeType: feeType,
          chargeBearer: chargeBearer,
          applicationBasis: applicationBasis,
          basisAmountSom: basisAmountSom,
          calculationType: calculationType,
          fixedAmountSom: fixedAmountSom,
          percentBasisPoints: percentBasisPoints,
          computedFeeSom: computedFeeSom,
        );

  final CommercialFeeLineStatus status;
  final String feeRuleId;
  final BusinessCatalogCommercialFeeType feeType;
  final BusinessCatalogCommercialFeeChargeBearer chargeBearer;
  final BusinessCatalogCommercialFeeApplicationBasis applicationBasis;
  final int? basisAmountSom;
  final BusinessCatalogCommercialFeeCalculationType calculationType;
  final int? fixedAmountSom;
  final int? percentBasisPoints;
  final int? computedFeeSom;
}

class CommercialFeesPreviewResult {
  const CommercialFeesPreviewResult({
    required this.status,
    required this.lines,
    this.ambiguousFeeTypes = const [],
  });

  final CommercialFeesPreviewStatus status;
  final List<CommercialFeeLinePreview> lines;
  final List<BusinessCatalogCommercialFeeType> ambiguousFeeTypes;

  int get totalComputedFeeSom => lines
      .where((l) => l.status == CommercialFeeLineStatus.computed)
      .fold(0, (sum, l) => sum + (l.computedFeeSom ?? 0));
}

int? _basisAmountFor(
  BusinessCatalogCommercialFeeApplicationBasis basis, {
  int? listingBaseAmountSom,
  int? serviceAmountSom,
  int? deliveryBasisAmountSom,
  int? commissionBasisAmountSom,
}) {
  switch (basis) {
    case BusinessCatalogCommercialFeeApplicationBasis.listingBase:
      return listingBaseAmountSom;
    case BusinessCatalogCommercialFeeApplicationBasis.serviceAmount:
      return serviceAmountSom;
    case BusinessCatalogCommercialFeeApplicationBasis.deliveryBasis:
      return deliveryBasisAmountSom;
    case BusinessCatalogCommercialFeeApplicationBasis.commissionBasis:
      return commissionBasisAmountSom;
  }
}

CommercialFeesPreviewResult calculateCommercialFeesPreview({
  required String businessScopeId,
  required String branchId,
  required DateTime asOf,
  int? listingBaseAmountSom,
  int? serviceAmountSom,
  int? deliveryBasisAmountSom,
  int? commissionBasisAmountSom,
  required List<BusinessCatalogCommercialFeeRule> rules,
}) {
  final applicable = rules.where((r) {
    if (r.businessScopeId != businessScopeId) {
      return false;
    }
    if (r.status != BusinessCatalogPriceStatus.active) {
      return false;
    }
    if (!catalogCommercialFeeBranchMatchesRule(
      branchId: branchId,
      ruleBranchId: r.branchId,
    )) {
      return false;
    }
    return catalogPriceEffectiveAt(
      effectiveFrom: r.effectiveFrom,
      effectiveUntil: r.effectiveUntil,
      asOf: asOf,
    );
  }).toList();

  final lines = <CommercialFeeLinePreview>[];
  final ambiguousFeeTypes = <BusinessCatalogCommercialFeeType>[];

  for (final feeType in BusinessCatalogCommercialFeeType.values) {
    final ofType = applicable.where((r) => r.feeType == feeType).toList();
    if (ofType.isEmpty) {
      continue;
    }

    final groups = <String, List<BusinessCatalogCommercialFeeRule>>{};
    for (final rule in ofType) {
      final key = catalogCommercialFeeScopeKey(
        branchId: rule.branchId,
        feeType: rule.feeType,
        chargeBearer: rule.chargeBearer,
        applicationBasis: rule.applicationBasis,
      );
      groups.putIfAbsent(key, () => []).add(rule);
    }

    for (final groupRules in groups.values) {
      groupRules.sort((a, b) => b.priority.compareTo(a.priority));
      final topPriority = groupRules.first.priority;
      final top = groupRules.where((r) => r.priority == topPriority).toList();
      if (top.length > 1) {
        if (!ambiguousFeeTypes.contains(feeType)) {
          ambiguousFeeTypes.add(feeType);
        }
        continue;
      }
      final rule = top.first;
      final basis = _basisAmountFor(
        rule.applicationBasis,
        listingBaseAmountSom: listingBaseAmountSom,
        serviceAmountSom: serviceAmountSom,
        deliveryBasisAmountSom: deliveryBasisAmountSom,
        commissionBasisAmountSom: commissionBasisAmountSom,
      );
      if (basis == null) {
        lines.add(
          CommercialFeeLinePreview.basisMissing(
            feeRuleId: rule.feeRuleId,
            feeType: rule.feeType,
            chargeBearer: rule.chargeBearer,
            applicationBasis: rule.applicationBasis,
            calculationType: rule.calculationType,
            fixedAmountSom: rule.fixedAmountSom,
            percentBasisPoints: rule.percentBasisPoints,
          ),
        );
        continue;
      }
      final feeSom = catalogCommercialFeeComputeAmount(
        rule: rule,
        basisAmountSom: basis,
      );
      lines.add(
        CommercialFeeLinePreview.computed(
          feeRuleId: rule.feeRuleId,
          feeType: rule.feeType,
          chargeBearer: rule.chargeBearer,
          applicationBasis: rule.applicationBasis,
          basisAmountSom: basis,
          calculationType: rule.calculationType,
          fixedAmountSom: rule.fixedAmountSom,
          percentBasisPoints: rule.percentBasisPoints,
          computedFeeSom: feeSom,
        ),
      );
    }
  }

  return CommercialFeesPreviewResult(
    status: ambiguousFeeTypes.isEmpty
        ? CommercialFeesPreviewStatus.success
        : CommercialFeesPreviewStatus.ambiguous,
    lines: lines,
    ambiguousFeeTypes: ambiguousFeeTypes,
  );
}

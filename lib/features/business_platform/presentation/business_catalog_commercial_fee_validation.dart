import 'package:qoshni/features/business_platform/domain/business_catalog_commercial_fee_application_basis.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_commercial_fee_calculation_type.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_commercial_fee_charge_bearer.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_commercial_fee_rule.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_commercial_fee_type.dart';

bool catalogCommercialFeePercentBasisPointsValid(int basisPoints) {
  return basisPoints > 0 &&
      basisPoints <= kBusinessCatalogCommercialFeeBasisPointsMax;
}

bool catalogCommercialFeeFixedAmountValid(int amountSom) => amountSom >= 0;

String? catalogCommercialFeeInputValidationError(
  BusinessCatalogCommercialFeeRuleInput input,
) {
  switch (input.calculationType) {
    case BusinessCatalogCommercialFeeCalculationType.percentage:
      final bp = input.percentBasisPoints;
      if (bp == null || !catalogCommercialFeePercentBasisPointsValid(bp)) {
        return 'invalid_fee_value';
      }
    case BusinessCatalogCommercialFeeCalculationType.fixedAmount:
      final fixed = input.fixedAmountSom;
      if (fixed == null || !catalogCommercialFeeFixedAmountValid(fixed)) {
        return 'invalid_fee_value';
      }
  }
  if (input.priority < 0) {
    return 'invalid_fee_value';
  }
  return null;
}

String catalogCommercialFeeScopeKey({
  String? branchId,
  required BusinessCatalogCommercialFeeType feeType,
  required BusinessCatalogCommercialFeeChargeBearer chargeBearer,
  required BusinessCatalogCommercialFeeApplicationBasis applicationBasis,
}) {
  final branch = branchId?.trim() ?? '';
  return '$branch|${feeType.name}|${chargeBearer.name}|${applicationBasis.name}';
}

bool catalogCommercialFeeBranchMatchesRule({
  required String branchId,
  required String? ruleBranchId,
}) {
  final ruleBranch = ruleBranchId?.trim();
  if (ruleBranch == null || ruleBranch.isEmpty) {
    return true;
  }
  return ruleBranch == branchId.trim();
}

/// Half-up rounding to whole UZS som: `(basis * basisPoints + 5000) ~/ 10000`.
int catalogCommercialFeeAmountFromPercent({
  required int basisAmountSom,
  required int percentBasisPoints,
}) {
  return (basisAmountSom * percentBasisPoints + 5000) ~/ 10000;
}

int catalogCommercialFeeComputeAmount({
  required BusinessCatalogCommercialFeeRule rule,
  required int basisAmountSom,
}) {
  switch (rule.calculationType) {
    case BusinessCatalogCommercialFeeCalculationType.fixedAmount:
      return rule.fixedAmountSom ?? 0;
    case BusinessCatalogCommercialFeeCalculationType.percentage:
      final bp = rule.percentBasisPoints ?? 0;
      return catalogCommercialFeeAmountFromPercent(
        basisAmountSom: basisAmountSom,
        percentBasisPoints: bp,
      );
  }
}

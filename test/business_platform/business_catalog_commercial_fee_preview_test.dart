import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/features/business_platform/data/business_catalog_commercial_fee_demo_seed.dart';
import 'package:qoshni/features/business_platform/data/business_catalog_inventory_demo_seed.dart';
import 'package:qoshni/features/business_platform/data/business_catalog_pricing_demo_seed.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_commercial_fee_application_basis.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_commercial_fee_calculation_type.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_commercial_fee_charge_bearer.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_commercial_fee_rule.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_commercial_fee_type.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_price_status.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_product.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_commercial_fee_preview.dart';

void main() {
  const scope = 'demo-scope';

  test('demo seed preview computes multiple fee types', () {
    final rules = buildDemoCatalogCommercialFeeRules(businessScopeId: scope);
    final result = calculateCommercialFeesPreview(
      businessScopeId: scope,
      branchId: kDemoBranchTashkentCenterId,
      asOf: kDemoCatalogPricingEpoch,
      listingBaseAmountSom: 8000,
      serviceAmountSom: 5000,
      deliveryBasisAmountSom: 12000,
      commissionBasisAmountSom: 8000,
      rules: rules,
    );
    expect(result.status, CommercialFeesPreviewStatus.success);
    final computed = result.lines
        .where((l) => l.status == CommercialFeeLineStatus.computed)
        .toList();
    expect(computed.length, greaterThanOrEqualTo(4));
    final platformCustomer = computed.firstWhere(
      (l) =>
          l.feeRuleId == kDemoCatalogFeePlatformFixedId &&
          l.chargeBearer ==
              BusinessCatalogCommercialFeeChargeBearer.customer,
    );
    expect(platformCustomer.computedFeeSom, 500);
    final commission = computed.firstWhere(
      (l) => l.feeRuleId == kDemoCatalogFeeCommissionPercentId,
    );
    expect(commission.computedFeeSom, 400);
    final delivery = computed.firstWhere(
      (l) => l.feeRuleId == kDemoCatalogFeeDeliveryPercentId,
    );
    expect(delivery.computedFeeSom, 360);
  });

  test('draft rule excluded from preview', () {
    final rules = buildDemoCatalogCommercialFeeRules(businessScopeId: scope);
    final result = calculateCommercialFeesPreview(
      businessScopeId: scope,
      branchId: kDemoBranchTashkentCenterId,
      asOf: kDemoCatalogPricingEpoch,
      listingBaseAmountSom: 8000,
      rules: rules,
    );
    expect(
      result.lines.any((l) => l.feeRuleId == kDemoCatalogFeeDraftId),
      isFalse,
    );
  });

  test('missing basis yields basisMissing line', () {
    final rules = buildDemoCatalogCommercialFeeRules(businessScopeId: scope);
    final result = calculateCommercialFeesPreview(
      businessScopeId: scope,
      branchId: kDemoBranchTashkentCenterId,
      asOf: kDemoCatalogPricingEpoch,
      listingBaseAmountSom: 8000,
      rules: rules,
    );
    expect(
      result.lines.any((l) => l.status == CommercialFeeLineStatus.basisMissing),
      isTrue,
    );
  });

  test('ambiguous when same priority ties within scope group', () {
    final ruleA = BusinessCatalogCommercialFeeRule(
      feeRuleId: 'a',
      businessScopeId: scope,
      branchId: kDemoBranchTashkentCenterId,
      feeType: BusinessCatalogCommercialFeeType.platformFee,
      chargeBearer: BusinessCatalogCommercialFeeChargeBearer.customer,
      calculationType: BusinessCatalogCommercialFeeCalculationType.fixedAmount,
      fixedAmountSom: 100,
      applicationBasis: BusinessCatalogCommercialFeeApplicationBasis.listingBase,
      status: BusinessCatalogPriceStatus.active,
      effectiveFrom: kDemoCatalogPricingEpoch,
      priority: 100,
      revision: 1,
      dataSource: BusinessCatalogProductDataSource.demoSeed,
      createdAt: kDemoCatalogPricingEpoch,
      updatedAt: kDemoCatalogPricingEpoch,
    );
    final ruleB = BusinessCatalogCommercialFeeRule(
      feeRuleId: 'b',
      businessScopeId: ruleA.businessScopeId,
      branchId: ruleA.branchId,
      feeType: ruleA.feeType,
      chargeBearer: ruleA.chargeBearer,
      calculationType: ruleA.calculationType,
      fixedAmountSom: 200,
      applicationBasis: ruleA.applicationBasis,
      status: ruleA.status,
      effectiveFrom: ruleA.effectiveFrom,
      effectiveUntil: ruleA.effectiveUntil,
      priority: ruleA.priority,
      revision: ruleA.revision,
      dataSource: ruleA.dataSource,
      createdAt: ruleA.createdAt,
      updatedAt: ruleA.updatedAt,
    );
    final result = calculateCommercialFeesPreview(
      businessScopeId: scope,
      branchId: kDemoBranchTashkentCenterId,
      asOf: kDemoCatalogPricingEpoch,
      listingBaseAmountSom: 8000,
      rules: [ruleA, ruleB],
    );
    expect(result.status, CommercialFeesPreviewStatus.ambiguous);
    expect(result.ambiguousFeeTypes, contains(BusinessCatalogCommercialFeeType.platformFee));
  });
}

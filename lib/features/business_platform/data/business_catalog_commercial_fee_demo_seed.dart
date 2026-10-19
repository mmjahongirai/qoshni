import 'package:qoshni/features/business_platform/data/business_catalog_inventory_demo_seed.dart';
import 'package:qoshni/features/business_platform/data/business_catalog_pricing_demo_seed.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_commercial_fee_application_basis.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_commercial_fee_calculation_type.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_commercial_fee_charge_bearer.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_commercial_fee_rule.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_commercial_fee_type.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_price_status.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_product.dart';

const String kDemoCatalogFeePlatformFixedId =
    'demo-catalog-fee-platform-fixed';
const String kDemoCatalogFeeCommissionPercentId =
    'demo-catalog-fee-commission-percent';
const String kDemoCatalogFeeServiceFixedId = 'demo-catalog-fee-service-fixed';
const String kDemoCatalogFeeDeliveryPercentId =
    'demo-catalog-fee-delivery-percent';
const String kDemoCatalogFeeDraftId = 'demo-catalog-fee-draft';
const String kDemoCatalogFeeFutureId = 'demo-catalog-fee-future';
const String kDemoCatalogFeePlatformLowPriorityId =
    'demo-catalog-fee-platform-low-priority';

final DateTime kDemoCatalogCommercialFeeFutureFrom =
    DateTime.utc(2026, 6, 1, 0, 0, 0);

List<BusinessCatalogCommercialFeeRule> buildDemoCatalogCommercialFeeRules({
  required String businessScopeId,
}) {
  return [
    BusinessCatalogCommercialFeeRule(
      feeRuleId: kDemoCatalogFeePlatformFixedId,
      businessScopeId: businessScopeId,
      branchId: kDemoBranchTashkentCenterId,
      feeType: BusinessCatalogCommercialFeeType.platformFee,
      chargeBearer: BusinessCatalogCommercialFeeChargeBearer.customer,
      calculationType: BusinessCatalogCommercialFeeCalculationType.fixedAmount,
      fixedAmountSom: 500,
      applicationBasis: BusinessCatalogCommercialFeeApplicationBasis.listingBase,
      status: BusinessCatalogPriceStatus.active,
      effectiveFrom: kDemoCatalogPricingEpoch,
      priority: 100,
      revision: 1,
      dataSource: BusinessCatalogProductDataSource.demoSeed,
      createdAt: kDemoCatalogPricingEpoch,
      updatedAt: kDemoCatalogPricingEpoch,
    ),
    BusinessCatalogCommercialFeeRule(
      feeRuleId: kDemoCatalogFeeCommissionPercentId,
      businessScopeId: businessScopeId,
      branchId: kDemoBranchTashkentCenterId,
      feeType: BusinessCatalogCommercialFeeType.commission,
      chargeBearer: BusinessCatalogCommercialFeeChargeBearer.business,
      calculationType: BusinessCatalogCommercialFeeCalculationType.percentage,
      percentBasisPoints: 500,
      applicationBasis:
          BusinessCatalogCommercialFeeApplicationBasis.commissionBasis,
      status: BusinessCatalogPriceStatus.active,
      effectiveFrom: kDemoCatalogPricingEpoch,
      priority: 100,
      revision: 1,
      dataSource: BusinessCatalogProductDataSource.demoSeed,
      createdAt: kDemoCatalogPricingEpoch,
      updatedAt: kDemoCatalogPricingEpoch,
    ),
    BusinessCatalogCommercialFeeRule(
      feeRuleId: kDemoCatalogFeeServiceFixedId,
      businessScopeId: businessScopeId,
      branchId: kDemoBranchTashkentCenterId,
      feeType: BusinessCatalogCommercialFeeType.serviceFee,
      chargeBearer: BusinessCatalogCommercialFeeChargeBearer.customer,
      calculationType: BusinessCatalogCommercialFeeCalculationType.fixedAmount,
      fixedAmountSom: 1000,
      applicationBasis:
          BusinessCatalogCommercialFeeApplicationBasis.serviceAmount,
      status: BusinessCatalogPriceStatus.active,
      effectiveFrom: kDemoCatalogPricingEpoch,
      priority: 100,
      revision: 1,
      dataSource: BusinessCatalogProductDataSource.demoSeed,
      createdAt: kDemoCatalogPricingEpoch,
      updatedAt: kDemoCatalogPricingEpoch,
    ),
    BusinessCatalogCommercialFeeRule(
      feeRuleId: kDemoCatalogFeeDeliveryPercentId,
      businessScopeId: businessScopeId,
      branchId: kDemoBranchTashkentCenterId,
      feeType: BusinessCatalogCommercialFeeType.deliveryFee,
      chargeBearer: BusinessCatalogCommercialFeeChargeBearer.customer,
      calculationType: BusinessCatalogCommercialFeeCalculationType.percentage,
      percentBasisPoints: 300,
      applicationBasis:
          BusinessCatalogCommercialFeeApplicationBasis.deliveryBasis,
      status: BusinessCatalogPriceStatus.active,
      effectiveFrom: kDemoCatalogPricingEpoch,
      priority: 100,
      revision: 1,
      dataSource: BusinessCatalogProductDataSource.demoSeed,
      createdAt: kDemoCatalogPricingEpoch,
      updatedAt: kDemoCatalogPricingEpoch,
    ),
    BusinessCatalogCommercialFeeRule(
      feeRuleId: kDemoCatalogFeeDraftId,
      businessScopeId: businessScopeId,
      branchId: kDemoBranchTashkentCenterId,
      feeType: BusinessCatalogCommercialFeeType.platformFee,
      chargeBearer: BusinessCatalogCommercialFeeChargeBearer.customer,
      calculationType: BusinessCatalogCommercialFeeCalculationType.fixedAmount,
      fixedAmountSom: 999,
      applicationBasis: BusinessCatalogCommercialFeeApplicationBasis.listingBase,
      status: BusinessCatalogPriceStatus.draft,
      effectiveFrom: kDemoCatalogPricingEpoch,
      priority: 50,
      revision: 1,
      dataSource: BusinessCatalogProductDataSource.demoSeed,
      createdAt: kDemoCatalogPricingEpoch,
      updatedAt: kDemoCatalogPricingEpoch,
    ),
    BusinessCatalogCommercialFeeRule(
      feeRuleId: kDemoCatalogFeeFutureId,
      businessScopeId: businessScopeId,
      branchId: kDemoBranchTashkentCenterId,
      feeType: BusinessCatalogCommercialFeeType.serviceFee,
      chargeBearer: BusinessCatalogCommercialFeeChargeBearer.customer,
      calculationType: BusinessCatalogCommercialFeeCalculationType.fixedAmount,
      fixedAmountSom: 2000,
      applicationBasis:
          BusinessCatalogCommercialFeeApplicationBasis.serviceAmount,
      status: BusinessCatalogPriceStatus.active,
      effectiveFrom: kDemoCatalogCommercialFeeFutureFrom,
      priority: 100,
      revision: 1,
      dataSource: BusinessCatalogProductDataSource.demoSeed,
      createdAt: kDemoCatalogCommercialFeeFutureFrom,
      updatedAt: kDemoCatalogCommercialFeeFutureFrom,
    ),
    BusinessCatalogCommercialFeeRule(
      feeRuleId: kDemoCatalogFeePlatformLowPriorityId,
      businessScopeId: businessScopeId,
      branchId: kDemoBranchTashkentCenterId,
      feeType: BusinessCatalogCommercialFeeType.platformFee,
      chargeBearer: BusinessCatalogCommercialFeeChargeBearer.platformAccounting,
      calculationType: BusinessCatalogCommercialFeeCalculationType.fixedAmount,
      fixedAmountSom: 100,
      applicationBasis: BusinessCatalogCommercialFeeApplicationBasis.listingBase,
      status: BusinessCatalogPriceStatus.active,
      effectiveFrom: kDemoCatalogPricingEpoch,
      priority: 50,
      revision: 1,
      dataSource: BusinessCatalogProductDataSource.demoSeed,
      createdAt: kDemoCatalogPricingEpoch,
      updatedAt: kDemoCatalogPricingEpoch,
    ),
  ];
}

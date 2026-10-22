import 'package:qoshni/features/business_platform/data/business_catalog_inventory_demo_seed.dart';
import 'package:qoshni/features/business_platform/data/business_catalog_pricing_demo_seed.dart';
import 'package:qoshni/features/business_platform/data/business_catalog_product_demo_seed.dart';
import 'package:qoshni/features/business_platform/data/business_catalog_service_demo_seed.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_discount_rule.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_discount_target_scope.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_discount_type.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_price_status.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_product.dart';

const String kDemoCatalogDiscountBreadPercentId =
    'demo-catalog-discount-bread-percent';
const String kDemoCatalogDiscountPackingFixedId =
    'demo-catalog-discount-packing-fixed';
const String kDemoCatalogDiscountMinBasketWideId =
    'demo-catalog-discount-min-basket-wide';
const String kDemoCatalogDiscountPlovDraftId =
    'demo-catalog-discount-plov-draft';
const String kDemoCatalogDiscountBreadFutureId =
    'demo-catalog-discount-bread-future';
const String kDemoCatalogDiscountBreadExpiredId =
    'demo-catalog-discount-bread-expired';

final DateTime kDemoCatalogDiscountFutureFrom =
    DateTime.utc(2026, 1, 1, 0, 0, 0);
final DateTime kDemoCatalogDiscountExpiredUntil =
    DateTime.utc(2024, 12, 31, 23, 59, 59);

List<BusinessCatalogDiscountRule> buildDemoCatalogDiscountRules({
  required String businessScopeId,
}) {
  return [
    BusinessCatalogDiscountRule(
      discountRuleId: kDemoCatalogDiscountBreadPercentId,
      businessScopeId: businessScopeId,
      branchId: kDemoBranchTashkentCenterId,
      targetScope: BusinessCatalogDiscountTargetScope.product,
      listingId: kDemoCatalogProductBreadId,
      discountType: BusinessCatalogDiscountType.percentage,
      percentBasisPoints: 1000,
      status: BusinessCatalogPriceStatus.active,
      effectiveFrom: kDemoCatalogPricingEpoch,
      priority: 100,
      revision: 1,
      dataSource: BusinessCatalogProductDataSource.demoSeed,
      createdAt: kDemoCatalogPricingEpoch,
      updatedAt: kDemoCatalogPricingEpoch,
    ),
    BusinessCatalogDiscountRule(
      discountRuleId: kDemoCatalogDiscountPackingFixedId,
      businessScopeId: businessScopeId,
      branchId: kDemoBranchTashkentCenterId,
      targetScope: BusinessCatalogDiscountTargetScope.service,
      listingId: kDemoCatalogServicePackingId,
      discountType: BusinessCatalogDiscountType.fixedAmount,
      fixedAmountSom: 5000,
      status: BusinessCatalogPriceStatus.active,
      effectiveFrom: kDemoCatalogPricingEpoch,
      priority: 50,
      revision: 1,
      dataSource: BusinessCatalogProductDataSource.demoSeed,
      createdAt: kDemoCatalogPricingEpoch,
      updatedAt: kDemoCatalogPricingEpoch,
    ),
    BusinessCatalogDiscountRule(
      discountRuleId: kDemoCatalogDiscountMinBasketWideId,
      businessScopeId: businessScopeId,
      branchId: kDemoBranchTashkentCenterId,
      targetScope: BusinessCatalogDiscountTargetScope.businessWide,
      discountType: BusinessCatalogDiscountType.percentage,
      percentBasisPoints: 500,
      minimumBasketAmountSom: 100000,
      status: BusinessCatalogPriceStatus.active,
      effectiveFrom: kDemoCatalogPricingEpoch,
      priority: 200,
      revision: 1,
      dataSource: BusinessCatalogProductDataSource.demoSeed,
      createdAt: kDemoCatalogPricingEpoch,
      updatedAt: kDemoCatalogPricingEpoch,
    ),
    BusinessCatalogDiscountRule(
      discountRuleId: kDemoCatalogDiscountPlovDraftId,
      businessScopeId: businessScopeId,
      branchId: kDemoBranchTashkentCenterId,
      targetScope: BusinessCatalogDiscountTargetScope.product,
      listingId: kDemoCatalogProductPlovId,
      discountType: BusinessCatalogDiscountType.fixedAmount,
      fixedAmountSom: 3000,
      status: BusinessCatalogPriceStatus.draft,
      effectiveFrom: kDemoCatalogPricingEpoch,
      priority: 10,
      revision: 1,
      dataSource: BusinessCatalogProductDataSource.demoSeed,
      createdAt: kDemoCatalogPricingEpoch,
      updatedAt: kDemoCatalogPricingEpoch,
    ),
    BusinessCatalogDiscountRule(
      discountRuleId: kDemoCatalogDiscountBreadFutureId,
      businessScopeId: businessScopeId,
      branchId: kDemoBranchTashkentCenterId,
      targetScope: BusinessCatalogDiscountTargetScope.product,
      listingId: kDemoCatalogProductBreadId,
      discountType: BusinessCatalogDiscountType.percentage,
      percentBasisPoints: 1500,
      status: BusinessCatalogPriceStatus.active,
      effectiveFrom: kDemoCatalogDiscountFutureFrom,
      priority: 300,
      revision: 1,
      dataSource: BusinessCatalogProductDataSource.demoSeed,
      createdAt: kDemoCatalogDiscountFutureFrom,
      updatedAt: kDemoCatalogDiscountFutureFrom,
    ),
    BusinessCatalogDiscountRule(
      discountRuleId: kDemoCatalogDiscountBreadExpiredId,
      businessScopeId: businessScopeId,
      branchId: kDemoBranchTashkentCenterId,
      targetScope: BusinessCatalogDiscountTargetScope.product,
      listingId: kDemoCatalogProductBreadId,
      discountType: BusinessCatalogDiscountType.fixedAmount,
      fixedAmountSom: 1000,
      status: BusinessCatalogPriceStatus.active,
      effectiveFrom: DateTime.utc(2024, 1, 1),
      effectiveUntil: kDemoCatalogDiscountExpiredUntil,
      priority: 400,
      revision: 1,
      dataSource: BusinessCatalogProductDataSource.demoSeed,
      createdAt: DateTime.utc(2024, 1, 1),
      updatedAt: DateTime.utc(2024, 1, 1),
    ),
  ];
}

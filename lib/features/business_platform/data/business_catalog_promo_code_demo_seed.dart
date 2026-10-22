import 'package:qoshni/features/business_platform/data/business_catalog_discount_demo_seed.dart';
import 'package:qoshni/features/business_platform/data/business_catalog_inventory_demo_seed.dart';
import 'package:qoshni/features/business_platform/data/business_catalog_pricing_demo_seed.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_price_status.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_product.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_promo_code.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_promo_code_usage_record.dart';

const String kDemoCatalogPromoNon10Id = 'demo-catalog-promo-non10';
const String kDemoCatalogPromoMinBasketId = 'demo-catalog-promo-min-basket';
const String kDemoCatalogPromoFutureId = 'demo-catalog-promo-future';
const String kDemoCatalogPromoExpiredId = 'demo-catalog-promo-expired';
const String kDemoCatalogPromoDraftId = 'demo-catalog-promo-draft';
const String kDemoCatalogPromoArchivedId = 'demo-catalog-promo-archived';
const String kDemoCatalogPromoTotalLimitId = 'demo-catalog-promo-total-limit';
const String kDemoCatalogPromoCustomerLimitId =
    'demo-catalog-promo-customer-limit';

const String kDemoPromoCustomerAlice = 'demo-customer-ref-alice';
const String kDemoPromoCustomerBob = 'demo-customer-ref-bob';

final DateTime kDemoCatalogPromoFutureFrom =
    DateTime.utc(2026, 6, 1, 0, 0, 0);
final DateTime kDemoCatalogPromoExpiredUntil =
    DateTime.utc(2024, 6, 1, 0, 0, 0);

List<BusinessCatalogPromoCode> buildDemoCatalogPromoCodes({
  required String businessScopeId,
}) {
  return [
    BusinessCatalogPromoCode(
      promoCodeId: kDemoCatalogPromoNon10Id,
      businessScopeId: businessScopeId,
      branchId: kDemoBranchTashkentCenterId,
      code: 'NON10',
      normalizedCode: 'NON10',
      discountRuleId: kDemoCatalogDiscountBreadPercentId,
      status: BusinessCatalogPriceStatus.active,
      effectiveFrom: kDemoCatalogPricingEpoch,
      revision: 1,
      dataSource: BusinessCatalogProductDataSource.demoSeed,
      createdAt: kDemoCatalogPricingEpoch,
      updatedAt: kDemoCatalogPricingEpoch,
    ),
    BusinessCatalogPromoCode(
      promoCodeId: kDemoCatalogPromoMinBasketId,
      businessScopeId: businessScopeId,
      branchId: kDemoBranchTashkentCenterId,
      code: 'WIDE5',
      normalizedCode: 'WIDE5',
      discountRuleId: kDemoCatalogDiscountMinBasketWideId,
      status: BusinessCatalogPriceStatus.active,
      effectiveFrom: kDemoCatalogPricingEpoch,
      minimumBasketAmountSom: 120000,
      revision: 1,
      dataSource: BusinessCatalogProductDataSource.demoSeed,
      createdAt: kDemoCatalogPricingEpoch,
      updatedAt: kDemoCatalogPricingEpoch,
    ),
    BusinessCatalogPromoCode(
      promoCodeId: kDemoCatalogPromoFutureId,
      businessScopeId: businessScopeId,
      branchId: kDemoBranchTashkentCenterId,
      code: 'LATER',
      normalizedCode: 'LATER',
      discountRuleId: kDemoCatalogDiscountBreadPercentId,
      status: BusinessCatalogPriceStatus.active,
      effectiveFrom: kDemoCatalogPromoFutureFrom,
      revision: 1,
      dataSource: BusinessCatalogProductDataSource.demoSeed,
      createdAt: kDemoCatalogPromoFutureFrom,
      updatedAt: kDemoCatalogPromoFutureFrom,
    ),
    BusinessCatalogPromoCode(
      promoCodeId: kDemoCatalogPromoExpiredId,
      businessScopeId: businessScopeId,
      branchId: kDemoBranchTashkentCenterId,
      code: 'OLD',
      normalizedCode: 'OLD',
      discountRuleId: kDemoCatalogDiscountBreadPercentId,
      status: BusinessCatalogPriceStatus.active,
      effectiveFrom: DateTime.utc(2024, 1, 1),
      effectiveUntil: kDemoCatalogPromoExpiredUntil,
      revision: 1,
      dataSource: BusinessCatalogProductDataSource.demoSeed,
      createdAt: DateTime.utc(2024, 1, 1),
      updatedAt: DateTime.utc(2024, 1, 1),
    ),
    BusinessCatalogPromoCode(
      promoCodeId: kDemoCatalogPromoDraftId,
      businessScopeId: businessScopeId,
      branchId: kDemoBranchTashkentCenterId,
      code: 'DRAFT1',
      normalizedCode: 'DRAFT1',
      discountRuleId: kDemoCatalogDiscountBreadPercentId,
      status: BusinessCatalogPriceStatus.draft,
      effectiveFrom: kDemoCatalogPricingEpoch,
      revision: 1,
      dataSource: BusinessCatalogProductDataSource.demoSeed,
      createdAt: kDemoCatalogPricingEpoch,
      updatedAt: kDemoCatalogPricingEpoch,
    ),
    BusinessCatalogPromoCode(
      promoCodeId: kDemoCatalogPromoArchivedId,
      businessScopeId: businessScopeId,
      branchId: kDemoBranchTashkentCenterId,
      code: 'RETIRED',
      normalizedCode: 'RETIRED',
      discountRuleId: kDemoCatalogDiscountBreadPercentId,
      status: BusinessCatalogPriceStatus.archived,
      effectiveFrom: kDemoCatalogPricingEpoch,
      revision: 1,
      dataSource: BusinessCatalogProductDataSource.demoSeed,
      createdAt: kDemoCatalogPricingEpoch,
      updatedAt: kDemoCatalogPricingEpoch,
    ),
    BusinessCatalogPromoCode(
      promoCodeId: kDemoCatalogPromoTotalLimitId,
      businessScopeId: businessScopeId,
      branchId: kDemoBranchTashkentCenterId,
      code: 'MAXED',
      normalizedCode: 'MAXED',
      discountRuleId: kDemoCatalogDiscountBreadPercentId,
      status: BusinessCatalogPriceStatus.active,
      effectiveFrom: kDemoCatalogPricingEpoch,
      maxTotalUses: 2,
      revision: 1,
      dataSource: BusinessCatalogProductDataSource.demoSeed,
      createdAt: kDemoCatalogPricingEpoch,
      updatedAt: kDemoCatalogPricingEpoch,
    ),
    BusinessCatalogPromoCode(
      promoCodeId: kDemoCatalogPromoCustomerLimitId,
      businessScopeId: businessScopeId,
      branchId: kDemoBranchTashkentCenterId,
      code: 'ALICE1',
      normalizedCode: 'ALICE1',
      discountRuleId: kDemoCatalogDiscountBreadPercentId,
      status: BusinessCatalogPriceStatus.active,
      effectiveFrom: kDemoCatalogPricingEpoch,
      maxUsesPerCustomer: 1,
      revision: 1,
      dataSource: BusinessCatalogProductDataSource.demoSeed,
      createdAt: kDemoCatalogPricingEpoch,
      updatedAt: kDemoCatalogPricingEpoch,
    ),
  ];
}

List<BusinessCatalogPromoCodeUsageRecord> buildDemoCatalogPromoUsageRecords() {
  final recordedAt = kDemoCatalogPricingEpoch;
  return [
    BusinessCatalogPromoCodeUsageRecord(
      usageRecordId: 'demo-promo-usage-total-1',
      promoCodeId: kDemoCatalogPromoTotalLimitId,
      demoCustomerReference: kDemoPromoCustomerAlice,
      demoRedemptionReference: 'demo-redemption-total-1',
      status: BusinessCatalogPromoCodeUsageStatus.demoRedemption,
      recordedAt: recordedAt,
    ),
    BusinessCatalogPromoCodeUsageRecord(
      usageRecordId: 'demo-promo-usage-total-2',
      promoCodeId: kDemoCatalogPromoTotalLimitId,
      demoCustomerReference: kDemoPromoCustomerBob,
      demoRedemptionReference: 'demo-redemption-total-2',
      status: BusinessCatalogPromoCodeUsageStatus.demoRedemption,
      recordedAt: recordedAt,
    ),
    BusinessCatalogPromoCodeUsageRecord(
      usageRecordId: 'demo-promo-usage-alice-1',
      promoCodeId: kDemoCatalogPromoCustomerLimitId,
      demoCustomerReference: kDemoPromoCustomerAlice,
      demoRedemptionReference: 'demo-redemption-alice-1',
      status: BusinessCatalogPromoCodeUsageStatus.demoRedemption,
      recordedAt: recordedAt,
    ),
  ];
}

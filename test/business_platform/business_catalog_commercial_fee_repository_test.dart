import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/features/business_platform/data/business_catalog_inventory_demo_seed.dart';
import 'package:qoshni/features/business_platform/data/business_catalog_pricing_demo_seed.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_branch_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_catalog_commercial_fee_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_owner_profile_repository.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_commercial_fee_application_basis.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_commercial_fee_calculation_type.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_commercial_fee_charge_bearer.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_commercial_fee_rule.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_commercial_fee_type.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_catalog_commercial_fee_repository.dart';

void main() {
  late InMemoryBusinessOwnerProfileRepository ownerRepo;
  late InMemoryBusinessBranchRepository branchRepo;
  late InMemoryBusinessCatalogCommercialFeeRepository feeRepo;

  setUp(() {
    ownerRepo = InMemoryBusinessOwnerProfileRepository();
    branchRepo = InMemoryBusinessBranchRepository(ownerRepo);
    feeRepo = InMemoryBusinessCatalogCommercialFeeRepository(
      ownerRepo,
      branchRepo,
    );
  });

  test('activate overlap rejected', () {
    final draft = feeRepo.createDraft(
      BusinessCatalogCommercialFeeRuleInput(
        branchId: kDemoBranchTashkentCenterId,
        feeType: BusinessCatalogCommercialFeeType.platformFee,
        chargeBearer: BusinessCatalogCommercialFeeChargeBearer.customer,
        calculationType: BusinessCatalogCommercialFeeCalculationType.fixedAmount,
        fixedAmountSom: 777,
        applicationBasis: BusinessCatalogCommercialFeeApplicationBasis.listingBase,
        effectiveFrom: kDemoCatalogPricingEpoch,
        priority: 100,
      ),
    );
    expect(draft, BusinessCatalogCommercialFeeSaveResult.success);
    final created = feeRepo
        .listForCurrentScope(status: null)
        .lastWhere((r) => r.fixedAmountSom == 777);
    final activate = feeRepo.activateRule(created.feeRuleId);
    expect(activate, BusinessCatalogCommercialFeeStatusChangeResult.activeIntervalOverlap);
  });

  test('failNextSave leaves list unchanged', () {
    feeRepo.failNextSave = true;
    final before = feeRepo.listForCurrentScope().length;
    final result = feeRepo.createDraft(
      BusinessCatalogCommercialFeeRuleInput(
        branchId: kDemoBranchTashkentCenterId,
        feeType: BusinessCatalogCommercialFeeType.serviceFee,
        chargeBearer: BusinessCatalogCommercialFeeChargeBearer.customer,
        calculationType: BusinessCatalogCommercialFeeCalculationType.fixedAmount,
        fixedAmountSom: 321,
        applicationBasis: BusinessCatalogCommercialFeeApplicationBasis.serviceAmount,
        effectiveFrom: kDemoCatalogPricingEpoch,
        priority: 10,
      ),
    );
    expect(result, BusinessCatalogCommercialFeeSaveResult.failure);
    expect(feeRepo.listForCurrentScope().length, before);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/features/business_platform/data/business_catalog_discount_demo_seed.dart';
import 'package:qoshni/features/business_platform/data/business_catalog_inventory_demo_seed.dart';
import 'package:qoshni/features/business_platform/data/business_catalog_pricing_demo_seed.dart';
import 'package:qoshni/features/business_platform/data/business_catalog_product_demo_seed.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_branch_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_catalog_category_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_catalog_discount_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_catalog_product_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_catalog_product_variant_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_catalog_service_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_owner_profile_repository.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_discount_rule.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_discount_target_scope.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_discount_type.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_price_status.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_catalog_discount_repository.dart';

void main() {
  late InMemoryBusinessOwnerProfileRepository ownerRepo;
  late InMemoryBusinessCatalogCategoryRepository categoryRepo;
  late InMemoryBusinessCatalogProductRepository productRepo;
  late InMemoryBusinessCatalogServiceRepository serviceRepo;
  late InMemoryBusinessCatalogProductVariantRepository variantRepo;
  late InMemoryBusinessBranchRepository branchRepo;
  late InMemoryBusinessCatalogDiscountRepository discountRepo;

  setUp(() {
    ownerRepo = InMemoryBusinessOwnerProfileRepository();
    categoryRepo = InMemoryBusinessCatalogCategoryRepository(ownerRepo);
    productRepo = InMemoryBusinessCatalogProductRepository(
      ownerRepo,
      categoryRepo,
    );
    serviceRepo = InMemoryBusinessCatalogServiceRepository(
      ownerRepo,
      categoryRepo,
    );
    categoryRepo.attachListingRepositories(
      productRepository: productRepo,
      serviceRepository: serviceRepo,
    );
    variantRepo = InMemoryBusinessCatalogProductVariantRepository(
      ownerRepo,
      productRepo,
    );
    branchRepo = InMemoryBusinessBranchRepository(ownerRepo);
    discountRepo = InMemoryBusinessCatalogDiscountRepository(
      ownerRepo,
      productRepo,
      serviceRepo,
      variantRepo,
      branchRepo,
    );
    ownerRepo.ensureSessionProfile();
  });

  BusinessCatalogDiscountRuleInput breadPercentInput() {
    return BusinessCatalogDiscountRuleInput(
      branchId: kDemoBranchTashkentCenterId,
      targetScope: BusinessCatalogDiscountTargetScope.product,
      listingId: kDemoCatalogProductBreadId,
      discountType: BusinessCatalogDiscountType.percentage,
      percentBasisPoints: 1500,
      effectiveFrom: kDemoCatalogPricingEpoch,
      priority: 100,
    );
  }

  test('demo seed count and stable ids', () {
    expect(
      discountRepo.listForCurrentScope(includeArchived: true).length,
      6,
    );
  });

  test('active rule cannot be updated silently', () {
    final active = discountRepo.findById(kDemoCatalogDiscountBreadPercentId)!;
    final result = discountRepo.updateDraft(
      discountRuleId: active.discountRuleId,
      input: breadPercentInput(),
    );
    expect(result, BusinessCatalogDiscountSaveResult.activeImmutable);
  });

  test('activate overlap rejected without history change', () {
    const draftId = kDemoCatalogDiscountPlovDraftId;
    final update = discountRepo.updateDraft(
      discountRuleId: draftId,
      input: breadPercentInput(),
    );
    expect(update, BusinessCatalogDiscountSaveResult.success);
    final historyBefore = discountRepo.ruleHistory(draftId).length;
    final activate = discountRepo.activateRule(draftId);
    expect(
      activate,
      BusinessCatalogDiscountStatusChangeResult.activeIntervalOverlap,
    );
    expect(
      discountRepo.findById(draftId)!.status,
      BusinessCatalogPriceStatus.draft,
    );
    expect(discountRepo.ruleHistory(draftId).length, historyBefore);
  });

  test('invalid variant rejected without list change', () {
    final countBefore =
        discountRepo.listForCurrentScope(includeArchived: true).length;
    final result = discountRepo.createDraft(
      BusinessCatalogDiscountRuleInput(
        branchId: kDemoBranchTashkentCenterId,
        targetScope: BusinessCatalogDiscountTargetScope.product,
        listingId: kDemoCatalogProductBreadId,
        variantId: 'bad-variant',
        discountType: BusinessCatalogDiscountType.fixedAmount,
        fixedAmountSom: 100,
        effectiveFrom: kDemoCatalogPricingEpoch,
        priority: 1,
      ),
    );
    expect(result, BusinessCatalogDiscountSaveResult.invalidVariant);
    expect(
      discountRepo.listForCurrentScope(includeArchived: true).length,
      countBefore,
    );
  });
}

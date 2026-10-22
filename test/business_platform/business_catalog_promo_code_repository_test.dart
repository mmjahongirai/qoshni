import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/features/business_platform/data/business_catalog_discount_demo_seed.dart';
import 'package:qoshni/features/business_platform/data/business_catalog_inventory_demo_seed.dart';
import 'package:qoshni/features/business_platform/data/business_catalog_pricing_demo_seed.dart';
import 'package:qoshni/features/business_platform/data/business_catalog_promo_code_demo_seed.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_branch_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_catalog_category_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_catalog_discount_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_catalog_product_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_catalog_product_variant_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_catalog_promo_code_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_catalog_service_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_owner_profile_repository.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_promo_code.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_catalog_promo_code_repository.dart';

void main() {
  late InMemoryBusinessOwnerProfileRepository ownerRepo;
  late InMemoryBusinessCatalogCategoryRepository categoryRepo;
  late InMemoryBusinessCatalogProductRepository productRepo;
  late InMemoryBusinessCatalogServiceRepository serviceRepo;
  late InMemoryBusinessCatalogProductVariantRepository variantRepo;
  late InMemoryBusinessBranchRepository branchRepo;
  late InMemoryBusinessCatalogDiscountRepository discountRepo;
  late InMemoryBusinessCatalogPromoCodeRepository promoRepo;

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
    promoRepo = InMemoryBusinessCatalogPromoCodeRepository(
      ownerRepo,
      branchRepo,
      discountRepo,
    );
  });

  test('seed includes NON10 and scope isolation via normalized lookup', () {
    final list = promoRepo.listForCurrentScope();
    expect(list.any((p) => p.code == 'NON10'), isTrue);
    expect(
      promoRepo.findByNormalizedCode('non10')?.promoCodeId,
      kDemoCatalogPromoNon10Id,
    );
  });

  test('duplicate code rejected without mutating list', () {
    final before = promoRepo.listForCurrentScope().length;
    final result = promoRepo.createDraft(
      BusinessCatalogPromoCodeInput(
        branchId: kDemoBranchTashkentCenterId,
        code: 'NON10',
        discountRuleId: kDemoCatalogDiscountBreadPercentId,
        effectiveFrom: kDemoCatalogPricingEpoch,
      ),
    );
    expect(result, BusinessCatalogPromoCodeSaveResult.duplicateCode);
    expect(promoRepo.listForCurrentScope().length, before);
  });

  test('failNextSave does not change promos', () {
    promoRepo.failNextSave = true;
    final before = promoRepo.listForCurrentScope().length;
    final result = promoRepo.createDraft(
      BusinessCatalogPromoCodeInput(
        branchId: kDemoBranchTashkentCenterId,
        code: 'UNIQUE99',
        discountRuleId: kDemoCatalogDiscountBreadPercentId,
        effectiveFrom: kDemoCatalogPricingEpoch,
      ),
    );
    expect(result, BusinessCatalogPromoCodeSaveResult.failure);
    expect(promoRepo.listForCurrentScope().length, before);
  });

  test('usage snapshot reflects demo seed', () {
    final snap = promoRepo.usageSnapshot(
      promoCodeId: kDemoCatalogPromoTotalLimitId,
    );
    expect(snap.totalUses, 2);
  });
}

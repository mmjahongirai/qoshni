import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/features/business_platform/data/business_catalog_inventory_demo_seed.dart';
import 'package:qoshni/features/business_platform/data/business_catalog_pricing_demo_seed.dart';
import 'package:qoshni/features/business_platform/data/business_catalog_product_demo_seed.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_branch_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_catalog_category_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_catalog_pricing_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_catalog_product_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_catalog_product_variant_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_catalog_service_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_owner_profile_repository.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_listing_kind.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_price.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_price_status.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_catalog_pricing_repository.dart';

void main() {
  late InMemoryBusinessOwnerProfileRepository ownerRepo;
  late InMemoryBusinessCatalogCategoryRepository categoryRepo;
  late InMemoryBusinessCatalogProductRepository productRepo;
  late InMemoryBusinessCatalogServiceRepository serviceRepo;
  late InMemoryBusinessCatalogProductVariantRepository variantRepo;
  late InMemoryBusinessBranchRepository branchRepo;
  late InMemoryBusinessCatalogPricingRepository pricingRepo;

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
    pricingRepo = InMemoryBusinessCatalogPricingRepository(
      ownerRepo,
      productRepo,
      serviceRepo,
      variantRepo,
      branchRepo,
    );
    ownerRepo.ensureSessionProfile();
  });

  BusinessCatalogPriceInput breadBaseInput({DateTime? until}) {
    return BusinessCatalogPriceInput(
      listingKind: BusinessCatalogListingKind.product,
      listingId: kDemoCatalogProductBreadId,
      branchId: kDemoBranchTashkentCenterId,
      amountSom: 9000,
      currencyCode: kBusinessCatalogPriceCurrencyUzs,
      effectiveFrom: kDemoCatalogPricingEpoch,
      effectiveUntil: until,
    );
  }

  test('demo seed links stable catalog ids', () {
    final list = pricingRepo.listForCurrentScope(includeArchived: true);
    expect(list.length, 5);
    expect(
      pricingRepo.findById(kDemoCatalogPriceBreadBaseTashkentId)!.amountSom,
      8000,
    );
  });

  test('invalid variant scope rejected without state change', () {
    final countBefore = pricingRepo.listForCurrentScope(includeArchived: true).length;
    final result = pricingRepo.createDraft(
      BusinessCatalogPriceInput(
        listingKind: BusinessCatalogListingKind.product,
        listingId: kDemoCatalogProductBreadId,
        variantId: 'wrong-variant',
        branchId: kDemoBranchTashkentCenterId,
        amountSom: 100,
        currencyCode: kBusinessCatalogPriceCurrencyUzs,
        effectiveFrom: kDemoCatalogPricingEpoch,
      ),
    );
    expect(result, BusinessCatalogPricingSaveResult.invalidVariant);
    expect(
      pricingRepo.listForCurrentScope(includeArchived: true).length,
      countBefore,
    );
  });

  test('active price cannot be updated silently', () {
    final active = pricingRepo.findById(kDemoCatalogPriceBreadBaseTashkentId)!;
    final result = pricingRepo.updateDraft(
      priceId: active.priceId,
      input: breadBaseInput(),
    );
    expect(result, BusinessCatalogPricingSaveResult.activeImmutable);
    expect(
      pricingRepo.findById(active.priceId)!.amountSom,
      active.amountSom,
    );
  });

  test('revision creates new draft without mutating active record', () {
    final active = pricingRepo.findById(kDemoCatalogPriceBreadBaseTashkentId)!;
    final result = pricingRepo.createRevisionFromPrice(
      sourcePriceId: active.priceId,
      input: breadBaseInput(),
    );
    expect(result, BusinessCatalogPricingSaveResult.success);
    final stillActive = pricingRepo.findById(active.priceId)!;
    expect(stillActive.status, BusinessCatalogPriceStatus.active);
    expect(stillActive.amountSom, 8000);
    final drafts = pricingRepo
        .listForCurrentScope(status: BusinessCatalogPriceStatus.draft);
    expect(drafts.any((d) => d.revision == 2 && d.amountSom == 9000), isTrue);
  });

  test('activate rejects overlapping active interval', () {
    const draftId = kDemoCatalogPricePlovDraftId;
    final update = pricingRepo.updateDraft(
      priceId: draftId,
      input: breadBaseInput(),
    );
    expect(update, BusinessCatalogPricingSaveResult.success);
    final historyBefore = pricingRepo.priceHistory(draftId).length;
    final activate = pricingRepo.activatePrice(draftId);
    expect(
      activate,
      BusinessCatalogPricingStatusChangeResult.activeIntervalOverlap,
    );
    expect(
      pricingRepo.findById(draftId)!.status,
      BusinessCatalogPriceStatus.draft,
    );
    expect(pricingRepo.priceHistory(draftId).length, historyBefore);
  });

  test('invalid effective range rejected on draft update', () {
    final draft = pricingRepo.findById(kDemoCatalogPricePlovDraftId)!;
    final historyBefore = pricingRepo.priceHistory(draft.priceId).length;
    final result = pricingRepo.updateDraft(
      priceId: draft.priceId,
      input: BusinessCatalogPriceInput(
        listingKind: BusinessCatalogListingKind.product,
        listingId: kDemoCatalogProductPlovId,
        branchId: kDemoBranchTashkentCenterId,
        amountSom: 25000,
        currencyCode: kBusinessCatalogPriceCurrencyUzs,
        effectiveFrom: DateTime.utc(2025, 6, 1),
        effectiveUntil: DateTime.utc(2025, 5, 1),
      ),
    );
    expect(result, BusinessCatalogPricingSaveResult.invalidEffectiveRange);
    expect(pricingRepo.priceHistory(draft.priceId).length, historyBefore);
  });
}

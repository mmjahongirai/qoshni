import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/features/business_platform/data/business_catalog_product_demo_seed.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_catalog_category_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_catalog_product_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_catalog_product_variant_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_owner_profile_repository.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_listing_status.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_product_variant.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_catalog_product_variant_repository.dart';

void main() {
  late InMemoryBusinessOwnerProfileRepository ownerRepo;
  late InMemoryBusinessCatalogCategoryRepository categoryRepo;
  late InMemoryBusinessCatalogProductRepository productRepo;
  late InMemoryBusinessCatalogProductVariantRepository variantRepo;

  setUp(() {
    ownerRepo = InMemoryBusinessOwnerProfileRepository();
    categoryRepo = InMemoryBusinessCatalogCategoryRepository(ownerRepo);
    productRepo = InMemoryBusinessCatalogProductRepository(
      ownerRepo,
      categoryRepo,
    );
    variantRepo = InMemoryBusinessCatalogProductVariantRepository(
      ownerRepo,
      productRepo,
    );
    ownerRepo.ensureSessionProfile();
  });

  test('duplicate sku rejected case-insensitively', () {
    final result = variantRepo.createVariant(
      productId: kDemoCatalogProductBreadId,
      input: const BusinessCatalogProductVariantInput(
        label: 'Large',
        sku: 'brd-std-001',
        status: BusinessCatalogListingStatus.active,
      ),
    );
    expect(result, BusinessCatalogProductVariantSaveResult.duplicateSku);
  });

  test('variant requires valid parent product', () {
    final result = variantRepo.createVariant(
      productId: 'missing-product',
      input: const BusinessCatalogProductVariantInput(
        label: 'X',
        sku: 'NEW-SKU-1',
        status: BusinessCatalogListingStatus.draft,
      ),
    );
    expect(result, BusinessCatalogProductVariantSaveResult.invalidProduct);
  });
}

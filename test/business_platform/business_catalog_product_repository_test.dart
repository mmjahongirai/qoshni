import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/features/business_platform/data/business_catalog_product_demo_seed.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_catalog_category_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_catalog_product_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_catalog_service_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_catalog_demo_item_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_owner_profile_repository.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_listing_status.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_localized_fields.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_product.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_catalog_product_repository.dart';

void main() {
  late InMemoryBusinessOwnerProfileRepository ownerRepo;
  late InMemoryBusinessCatalogCategoryRepository categoryRepo;
  late InMemoryBusinessCatalogProductRepository productRepo;
  late InMemoryBusinessCatalogServiceRepository serviceRepo;

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
    ownerRepo.ensureSessionProfile();
  });

  test('demo products isolated from home mock ids', () {
    for (final p in productRepo.listForCurrentScope()) {
      expect(p.productId, startsWith('demo-catalog-item-'));
      expect(p.businessScopeId, 'session-owner-profile-demo');
    }
  });

  test('invalid category rejected on create', () {
    const input = BusinessCatalogProductInput(
      categoryId: 'not-in-scope',
      localized: BusinessCatalogLocalizedFields(nameEn: 'Test'),
      status: BusinessCatalogListingStatus.draft,
      attributes: [],
    );
    expect(
      productRepo.createProduct(input),
      BusinessCatalogProductSaveResult.invalidCategory,
    );
  });

  test('stable product id on update and failNextSave', () {
    final before = productRepo.findById(kDemoCatalogProductBreadId)!;
    productRepo.failNextSave = true;
    expect(
      productRepo.updateProduct(
        before.productId,
        BusinessCatalogProductInput(
          categoryId: before.categoryId,
          localized: const BusinessCatalogLocalizedFields(nameEn: 'No save'),
          status: before.status,
          attributes: before.attributes,
        ),
      ),
      BusinessCatalogProductSaveResult.failure,
    );
    expect(
      productRepo.findById(before.productId)!.localized.nameEn,
      before.localized.nameEn,
    );
  });

  test('overview stats from product and service repos', () {
    final overview = InMemoryBusinessCatalogOverviewRepository(
      productRepo,
      serviceRepo,
    );
    final stats = overview.overviewStatsForScope(
      categoryCount: categoryRepo.listForCurrentScope().length,
    );
    expect(stats.productCount, 3);
    expect(stats.serviceCount, 2);
    expect(stats.archivedItemCount, 0);
  });
}

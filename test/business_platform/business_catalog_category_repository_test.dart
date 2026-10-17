import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/features/business_platform/data/business_catalog_category_demo_seed.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_catalog_category_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_catalog_demo_item_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_owner_profile_repository.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_category.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_category_status.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_localized_fields.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_catalog_category_repository.dart';

void main() {
  late InMemoryBusinessOwnerProfileRepository ownerRepo;
  late InMemoryBusinessCatalogDemoItemRepository itemRepo;
  late InMemoryBusinessCatalogCategoryRepository categoryRepo;

  setUp(() {
    ownerRepo = InMemoryBusinessOwnerProfileRepository();
    itemRepo = InMemoryBusinessCatalogDemoItemRepository(ownerRepo);
    categoryRepo = InMemoryBusinessCatalogCategoryRepository(
      ownerRepo,
      itemRepo,
    );
    ownerRepo.ensureSessionProfile();
  });

  test('lists demo categories scoped to owner session', () {
    final categories = categoryRepo.listForCurrentScope();
    expect(categories, isNotEmpty);
    expect(categories.every((c) => c.isDemoSeed), isTrue);
    expect(categoryRepo.businessScopeId, 'session-owner-profile-demo');
  });

  test('overview stats match demo items', () {
    final stats = itemRepo.overviewStatsForScope(
      categoryCount: categoryRepo.listForCurrentScope().length,
    );
    expect(stats.categoryCount, 3);
    expect(stats.productCount, 3);
    expect(stats.serviceCount, 2);
    expect(stats.activeItemCount, 4);
    expect(stats.draftItemCount, 1);
  });

  test('create keeps stable id on update', () {
    const input = BusinessCatalogCategoryInput(
      localized: BusinessCatalogLocalizedFields(nameEn: 'Session category'),
      status: BusinessCatalogCategoryStatus.draft,
    );
    expect(categoryRepo.createCategory(input), BusinessCatalogCategorySaveResult.success);
    final created = categoryRepo.listForCurrentScope().last;
    expect(created.categoryId, startsWith('session-catalog-cat-'));

    final update = BusinessCatalogCategoryInput(
      localized: const BusinessCatalogLocalizedFields(nameEn: 'Renamed'),
      status: BusinessCatalogCategoryStatus.active,
    );
    expect(
      categoryRepo.updateCategory(created.categoryId, update),
      BusinessCatalogCategorySaveResult.success,
    );
    expect(categoryRepo.findById(created.categoryId)!.localized.nameEn, 'Renamed');
  });

  test('delete in use category is rejected', () {
    expect(
      categoryRepo.deleteCategory(kDemoCatalogCategoryFreshGoodsId),
      BusinessCatalogCategoryDeleteResult.inUse,
    );
    expect(
      categoryRepo.findById(kDemoCatalogCategoryFreshGoodsId),
      isNotNull,
    );
  });

  test('failNextSave preserves category data', () {
    final before = categoryRepo.findById(kDemoCatalogCategoryInStoreServicesId)!;
    categoryRepo.failNextSave = true;
    final result = categoryRepo.updateCategory(
      before.categoryId,
      BusinessCatalogCategoryInput(
        localized: const BusinessCatalogLocalizedFields(nameEn: 'Should not apply'),
        status: before.status,
      ),
    );
    expect(result, BusinessCatalogCategorySaveResult.failure);
    expect(
      categoryRepo.findById(before.categoryId)!.localized.nameEn,
      before.localized.nameEn,
    );
  });

  test('catalog demo ids isolated from onboarding profile drafts', () {
    for (final category in categoryRepo.listForCurrentScope()) {
      expect(category.categoryId, startsWith('demo-catalog-cat-'));
      expect(category.businessScopeId, isNot(contains('profile-draft')));
    }
  });
}

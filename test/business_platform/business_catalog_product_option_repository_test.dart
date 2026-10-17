import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/core/config/app_config.dart';
import 'package:qoshni/core/config/app_environment.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/features/business_platform/data/business_catalog_product_demo_seed.dart';
import 'package:qoshni/features/business_platform/data/business_catalog_product_option_demo_seed.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_catalog_product_option_repository.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_localized_fields.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_option.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_option_group.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_option_selection_mode.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_catalog_product_option_repository.dart';

void main() {
  setUp(() async {
    await configureDependencies(
      AppConfig.forEnvironment(AppEnvironment.development),
    );
  });

  tearDown(() async {
    await getIt.reset();
  });

  test('demo seed exposes stable group and option ids', () {
    final repo = getIt<BusinessCatalogProductOptionRepository>();
    final groups = repo.groupsForProduct(kDemoCatalogProductBreadId);
    expect(groups.length, 1);
    expect(groups.first.groupId, kDemoCatalogOptionGroupBreadSizeId);
    expect(groups.first.options.length, 2);
    expect(groups.first.options.first.optionId, 'demo-catalog-option-bread-small');
  });

  test('create group keeps stable id on update', () {
    final repo = getIt<BusinessCatalogProductOptionRepository>()
        as InMemoryBusinessCatalogProductOptionRepository;
    final create = repo.createGroup(
      productId: kDemoCatalogProductPlovId,
      input: const BusinessCatalogOptionGroupInput(
        localized: BusinessCatalogLocalizedFields(nameEn: 'Spice level'),
        description: BusinessCatalogLocalizedFields(),
        selectionMode: BusinessCatalogOptionSelectionMode.single,
        required: true,
        minSelections: 1,
        maxSelections: 1,
      ),
    );
    expect(create, BusinessCatalogOptionGroupSaveResult.success);
    final group = repo.groupsForProduct(kDemoCatalogProductPlovId).single;
    final groupId = group.groupId;
    final update = repo.updateGroup(
      groupId: groupId,
      input: const BusinessCatalogOptionGroupInput(
        localized: BusinessCatalogLocalizedFields(nameEn: 'Spice level updated'),
        description: BusinessCatalogLocalizedFields(),
        selectionMode: BusinessCatalogOptionSelectionMode.single,
        required: true,
        minSelections: 1,
        maxSelections: 1,
      ),
    );
    expect(update, BusinessCatalogOptionGroupSaveResult.success);
    expect(repo.findGroupById(groupId)?.groupId, groupId);
  });

  test('rejects group for unknown product', () {
    final repo = getIt<BusinessCatalogProductOptionRepository>();
    final result = repo.createGroup(
      productId: 'foreign-product-id',
      input: const BusinessCatalogOptionGroupInput(
        localized: BusinessCatalogLocalizedFields(nameEn: 'Bad'),
        description: BusinessCatalogLocalizedFields(),
        selectionMode: BusinessCatalogOptionSelectionMode.single,
        required: false,
        minSelections: 0,
        maxSelections: 1,
      ),
    );
    expect(result, BusinessCatalogOptionGroupSaveResult.invalidProduct);
  });

  test('archive group hides from active list', () {
    final repo = getIt<BusinessCatalogProductOptionRepository>();
    final archive = repo.archiveGroup(kDemoCatalogOptionGroupBreadSizeId);
    expect(archive, BusinessCatalogOptionGroupArchiveResult.success);
    expect(repo.groupsForProduct(kDemoCatalogProductBreadId), isEmpty);
    expect(
      repo.groupsForProduct(
        kDemoCatalogProductBreadId,
        includeArchived: true,
      ).length,
      1,
    );
  });

  test('option create keeps stable option id', () {
    final repo = getIt<BusinessCatalogProductOptionRepository>();
    final create = repo.createOption(
      groupId: kDemoCatalogOptionGroupBreadSizeId,
      input: const BusinessCatalogOptionInput(
        localized: BusinessCatalogLocalizedFields(nameEn: 'Medium'),
      ),
    );
    expect(create, BusinessCatalogOptionSaveResult.success);
    final group = repo.findGroupById(kDemoCatalogOptionGroupBreadSizeId)!;
    final medium = group.options.last;
    final optionId = medium.optionId;
    final update = repo.updateOption(
      optionId: optionId,
      input: const BusinessCatalogOptionInput(
        localized: BusinessCatalogLocalizedFields(nameEn: 'Medium loaf'),
        isActive: true,
      ),
    );
    expect(update, BusinessCatalogOptionSaveResult.success);
    expect(repo.findOptionById(optionId)?.optionId, optionId);
  });

  test('save failure flag returns failure without persisting', () {
    final repo = getIt<BusinessCatalogProductOptionRepository>()
        as InMemoryBusinessCatalogProductOptionRepository;
    repo.failNextSave = true;
    final before = repo.groupsForProduct(kDemoCatalogProductPlovId).length;
    final result = repo.createGroup(
      productId: kDemoCatalogProductPlovId,
      input: const BusinessCatalogOptionGroupInput(
        localized: BusinessCatalogLocalizedFields(nameEn: 'Fail'),
        description: BusinessCatalogLocalizedFields(),
        selectionMode: BusinessCatalogOptionSelectionMode.single,
        required: false,
        minSelections: 0,
        maxSelections: 1,
      ),
    );
    expect(result, BusinessCatalogOptionGroupSaveResult.failure);
    expect(repo.groupsForProduct(kDemoCatalogProductPlovId).length, before);
  });
}

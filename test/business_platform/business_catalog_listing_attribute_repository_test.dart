import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/core/config/app_config.dart';
import 'package:qoshni/core/config/app_environment.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/features/business_platform/data/business_catalog_listing_attribute_demo_seed.dart';
import 'package:qoshni/features/business_platform/data/business_catalog_product_demo_seed.dart';
import 'package:qoshni/features/business_platform/data/business_catalog_service_demo_seed.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_catalog_listing_attribute_repository.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_attribute_value_kind.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_listing_attribute.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_listing_kind.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_localized_fields.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_catalog_listing_attribute_repository.dart';

void main() {
  setUp(() async {
    await configureDependencies(
      AppConfig.forEnvironment(AppEnvironment.development),
    );
  });

  tearDown(() async {
    await getIt.reset();
  });

  test('demo attributes have stable ids for product and service', () {
    final repo = getIt<BusinessCatalogListingAttributeRepository>();
    final bread = repo.attributesForListing(
      listingKind: BusinessCatalogListingKind.product,
      listingId: kDemoCatalogProductBreadId,
    );
    expect(bread.single.attributeId, kDemoCatalogAttributeBreadUnitId);
    expect(bread.single.key, 'unit');

    final service = repo.attributesForListing(
      listingKind: BusinessCatalogListingKind.service,
      listingId: kDemoCatalogServicePackingId,
    );
    expect(service.single.attributeId, kDemoCatalogAttributeServiceDurationTypeId);
  });

  test('duplicate key rejected within listing', () {
    final repo = getIt<BusinessCatalogListingAttributeRepository>();
    const input = BusinessCatalogListingAttributeInput(
      key: 'origin',
      label: BusinessCatalogLocalizedFields(nameEn: 'Origin'),
      valueKind: BusinessCatalogAttributeValueKind.text,
      textValue: 'local',
      choiceValue: '',
    );
    expect(
      repo.createAttribute(
        listingKind: BusinessCatalogListingKind.product,
        listingId: kDemoCatalogProductPlovId,
        input: input,
      ),
      BusinessCatalogListingAttributeSaveResult.success,
    );
    expect(
      repo.createAttribute(
        listingKind: BusinessCatalogListingKind.product,
        listingId: kDemoCatalogProductPlovId,
        input: input,
      ),
      BusinessCatalogListingAttributeSaveResult.duplicateKey,
    );
  });

  test('update keeps stable attribute id', () {
    final repo = getIt<BusinessCatalogListingAttributeRepository>();
    final before = repo.findById(kDemoCatalogAttributeBreadUnitId)!;
    final update = repo.updateAttribute(
      attributeId: before.attributeId,
      input: const BusinessCatalogListingAttributeInput(
        key: 'unit',
        label: BusinessCatalogLocalizedFields(nameEn: 'Unit updated'),
        valueKind: BusinessCatalogAttributeValueKind.choice,
        textValue: '',
        choiceValue: 'baguette',
        numberValue: null,
      ),
    );
    expect(update, BusinessCatalogListingAttributeSaveResult.success);
    expect(repo.findById(before.attributeId)?.attributeId, before.attributeId);
    expect(repo.findById(before.attributeId)!.choiceValue, 'baguette');
  });

  test('invalid listing rejected', () {
    final repo = getIt<BusinessCatalogListingAttributeRepository>();
    final result = repo.createAttribute(
      listingKind: BusinessCatalogListingKind.product,
      listingId: 'home-mock-product',
      input: const BusinessCatalogListingAttributeInput(
        key: 'orphan',
        label: BusinessCatalogLocalizedFields(nameEn: 'Orphan'),
        valueKind: BusinessCatalogAttributeValueKind.text,
        textValue: 'x',
        choiceValue: '',
      ),
    );
    expect(result, BusinessCatalogListingAttributeSaveResult.invalidListing);
  });

  test('save failure does not persist', () {
    final repo = getIt<BusinessCatalogListingAttributeRepository>()
        as InMemoryBusinessCatalogListingAttributeRepository;
    repo.failNextSave = true;
    final before = repo.attributesForListing(
      listingKind: BusinessCatalogListingKind.product,
      listingId: kDemoCatalogProductPlovId,
    ).length;
    final result = repo.createAttribute(
      listingKind: BusinessCatalogListingKind.product,
      listingId: kDemoCatalogProductPlovId,
      input: const BusinessCatalogListingAttributeInput(
        key: 'spice',
        label: BusinessCatalogLocalizedFields(nameEn: 'Spice'),
        valueKind: BusinessCatalogAttributeValueKind.text,
        textValue: 'mild',
        choiceValue: '',
      ),
    );
    expect(result, BusinessCatalogListingAttributeSaveResult.failure);
    expect(
      repo.attributesForListing(
        listingKind: BusinessCatalogListingKind.product,
        listingId: kDemoCatalogProductPlovId,
      ).length,
      before,
    );
  });
}

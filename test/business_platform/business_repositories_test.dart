import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/core/config/app_config.dart';
import 'package:qoshni/core/config/app_environment.dart';
import 'package:qoshni/core/localization/generated/app_localizations_en.dart';
import 'package:qoshni/features/business_platform/data/business_profile_sample_data.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_inventory_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_offering_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_profile_repository.dart';
import 'package:qoshni/features/business_platform/domain/business_offering_availability_state.dart';
import 'package:qoshni/features/business_platform/domain/business_offering_kind.dart';
import 'package:qoshni/features/business_platform/domain/business_pricing_unit.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_inventory_repository.dart';
import 'package:qoshni/features/home/presentation/data/service_category_id.dart';

void main() {
  group('BusinessProfileRepository', () {
    late InMemoryBusinessProfileRepository repo;

    setUp(() {
      repo = InMemoryBusinessProfileRepository();
    });

    test('creates and lists user drafts', () {
      final id = repo.createDraft(
        businessName: 'Test Shop',
        categoryId: ServiceCategoryId.shops,
        description: 'Desc',
        addressDescription: 'Addr',
        workingHours: '9-18',
      );
      expect(id, isNotEmpty);
      expect(repo.listUserDrafts(), hasLength(1));
      expect(repo.userDraftById(id)?.businessName, 'Test Shop');
    });

    test('updates an existing draft', () {
      final id = repo.createDraft(
        businessName: 'A',
        categoryId: ServiceCategoryId.shops,
        description: 'D',
        addressDescription: 'Ad',
        workingHours: 'H',
      );
      final ok = repo.updateDraft(
        id: id,
        businessName: 'B',
        categoryId: ServiceCategoryId.pharmacy,
        description: 'D2',
        addressDescription: 'Ad2',
        workingHours: 'H2',
      );
      expect(ok, isTrue);
      expect(repo.userDraftById(id)?.businessName, 'B');
    });
  });

  group('BusinessOfferingRepository ownership', () {
    late InMemoryBusinessOfferingRepository offerings;

    setUp(() {
      offerings = InMemoryBusinessOfferingRepository();
    });

    test('scopes offerings to profile id', () {
      const profileA = 'draft-a';
      const profileB = 'draft-b';

      final offeringId = offerings.addOffering(
        businessProfileId: profileA,
        kind: BusinessOfferingKind.product,
        name: 'Hammer',
        description: 'Steel',
        pricingUnit: BusinessPricingUnit.perItem,
        samplePriceUzs: 1000,
      );
      expect(offeringId, isNotNull);

      expect(
        offerings.offeringById(
          businessProfileId: profileA,
          offeringId: offeringId!,
        ),
        isNotNull,
      );
      expect(
        offerings.offeringById(
          businessProfileId: profileB,
          offeringId: offeringId,
        ),
        isNull,
      );
    });
  });

  group('BusinessInventoryRepository', () {
    late InMemoryBusinessOfferingRepository offerings;
    late InMemoryBusinessInventoryRepository inventory;

    setUp(() {
      offerings = InMemoryBusinessOfferingRepository();
      inventory = InMemoryBusinessInventoryRepository(offerings);
    });

    test('saveInventory requires a matching offering', () {
      final result = inventory.saveInventory(
        businessProfileId: 'p1',
        offeringId: 'missing',
        availability: BusinessOfferingAvailabilityState.active,
        totalQuantity: 1,
        availableQuantity: 1,
      );
      expect(result, BusinessInventorySaveResult.offeringNotFound);
    });

    test('removeOffering clears inventory via repository cleanup', () {
      const profileId = 'draft-inv';
      final offeringId = offerings.addOffering(
        businessProfileId: profileId,
        kind: BusinessOfferingKind.product,
        name: 'Drill',
        description: 'Cordless',
        pricingUnit: BusinessPricingUnit.perItem,
        samplePriceUzs: 50000,
      )!;

      final save = inventory.saveInventory(
        businessProfileId: profileId,
        offeringId: offeringId,
        availability: BusinessOfferingAvailabilityState.active,
        totalQuantity: 5,
        availableQuantity: 3,
      );
      expect(save, BusinessInventorySaveResult.success);
      expect(
        inventory.inventoryFor(
          businessProfileId: profileId,
          offeringId: offeringId,
        ),
        isNotNull,
      );

      offerings.removeOffering(
        businessProfileId: profileId,
        offeringId: offeringId,
      );
      inventory.removeForOffering(
        businessProfileId: profileId,
        offeringId: offeringId,
      );

      expect(
        inventory.inventoryFor(
          businessProfileId: profileId,
          offeringId: offeringId,
        ),
        isNull,
      );
    });

    test('inventoryFor returns null when offering was removed', () {
      const profileId = 'draft-orphan';
      final offeringId = offerings.addOffering(
        businessProfileId: profileId,
        kind: BusinessOfferingKind.rental,
        name: 'Ladder',
        description: '3m',
        pricingUnit: BusinessPricingUnit.perDay,
        samplePriceUzs: 20000,
        demoDepositUzs: 50000,
      )!;

      inventory.saveInventory(
        businessProfileId: profileId,
        offeringId: offeringId,
        availability: BusinessOfferingAvailabilityState.paused,
        totalQuantity: 2,
        availableQuantity: 1,
      );

      offerings.removeOffering(
        businessProfileId: profileId,
        offeringId: offeringId,
      );

      expect(
        inventory.inventoryFor(
          businessProfileId: profileId,
          offeringId: offeringId,
        ),
        isNull,
      );
    });
  });

  group('Sample vs owner data planes', () {
    test('disabling sample flags hides samples but keeps user drafts', () {
      final l10n = AppLocalizationsEn();
      final profileRepo = InMemoryBusinessProfileRepository();
      final samplesOff = AppConfig.forEnvironment(AppEnvironment.production);
      final samplesOn = AppConfig.forEnvironment(AppEnvironment.development);

      expect(buildBusinessProfileSamples(l10n, samplesOff), isEmpty);
      expect(
        buildBusinessProfileSamples(l10n, samplesOn),
        isNotEmpty,
      );

      profileRepo.createDraft(
        businessName: 'Owner',
        categoryId: ServiceCategoryId.masters,
        description: 'D',
        addressDescription: 'A',
        workingHours: 'W',
      );

      expect(buildBusinessProfileSamples(l10n, samplesOff), isEmpty);
      expect(profileRepo.listUserDrafts(), hasLength(1));
      expect(
        profileRepo.listUserDrafts().first.id,
        isNot(kSampleRentalToolsProfileId),
      );
    });
  });
}

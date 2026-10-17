import 'package:qoshni/features/business_platform/data/business_catalog_product_demo_seed.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_listing_status.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_localized_fields.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_option.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_option_group.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_option_selection_mode.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_product.dart';

const String kDemoCatalogOptionGroupBreadSizeId = 'demo-catalog-option-group-bread-size';

List<BusinessCatalogOptionGroup> buildDemoCatalogOptionGroups({
  required String businessScopeId,
}) {
  final now = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
  const source = BusinessCatalogProductDataSource.demoSeed;

  return [
    BusinessCatalogOptionGroup(
      groupId: kDemoCatalogOptionGroupBreadSizeId,
      productId: kDemoCatalogProductBreadId,
      businessScopeId: businessScopeId,
      dataSource: source,
      status: BusinessCatalogListingStatus.active,
      localized: const BusinessCatalogLocalizedFields(
        nameUz: 'Non o‘lchami',
        nameRu: 'Размер хлеба',
        nameEn: 'Bread size',
      ),
      description: const BusinessCatalogLocalizedFields(
        descriptionEn: 'Choose a preview size (demo).',
      ),
      selectionMode: BusinessCatalogOptionSelectionMode.single,
      required: true,
      minSelections: 1,
      maxSelections: 1,
      options: [
        BusinessCatalogOption(
          optionId: 'demo-catalog-option-bread-small',
          groupId: kDemoCatalogOptionGroupBreadSizeId,
          productId: kDemoCatalogProductBreadId,
          businessScopeId: businessScopeId,
          dataSource: source,
          localized: const BusinessCatalogLocalizedFields(
            nameUz: 'Kichik',
            nameRu: 'Малый',
            nameEn: 'Small',
          ),
          isActive: true,
          createdAt: now,
          updatedAt: now,
        ),
        BusinessCatalogOption(
          optionId: 'demo-catalog-option-bread-large',
          groupId: kDemoCatalogOptionGroupBreadSizeId,
          productId: kDemoCatalogProductBreadId,
          businessScopeId: businessScopeId,
          dataSource: source,
          localized: const BusinessCatalogLocalizedFields(
            nameUz: 'Katta',
            nameRu: 'Большой',
            nameEn: 'Large',
          ),
          isActive: true,
          createdAt: now,
          updatedAt: now,
        ),
      ],
      createdAt: now,
      updatedAt: now,
    ),
  ];
}

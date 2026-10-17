import 'package:qoshni/features/business_platform/data/business_catalog_product_demo_seed.dart';
import 'package:qoshni/features/business_platform/data/business_catalog_service_demo_seed.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_attribute_value_kind.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_listing_attribute.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_listing_kind.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_localized_fields.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_product.dart';

const String kDemoCatalogAttributeBreadUnitId = 'demo-catalog-attr-bread-unit';
const String kDemoCatalogAttributeServiceDurationTypeId =
    'demo-catalog-attr-service-duration-type';

List<BusinessCatalogListingAttribute> buildDemoCatalogListingAttributes({
  required String businessScopeId,
}) {
  final now = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
  const source = BusinessCatalogProductDataSource.demoSeed;

  return [
    BusinessCatalogListingAttribute(
      attributeId: kDemoCatalogAttributeBreadUnitId,
      listingKind: BusinessCatalogListingKind.product,
      listingId: kDemoCatalogProductBreadId,
      businessScopeId: businessScopeId,
      dataSource: source,
      key: 'unit',
      label: const BusinessCatalogLocalizedFields(
        nameUz: 'O‘lchov birligi',
        nameRu: 'Единица',
        nameEn: 'Unit',
      ),
      valueKind: BusinessCatalogAttributeValueKind.choice,
      textValue: '',
      numberValue: null,
      choiceValue: 'loaf',
      createdAt: now,
      updatedAt: now,
    ),
    BusinessCatalogListingAttribute(
      attributeId: kDemoCatalogAttributeServiceDurationTypeId,
      listingKind: BusinessCatalogListingKind.service,
      listingId: kDemoCatalogServicePackingId,
      businessScopeId: businessScopeId,
      dataSource: source,
      key: 'service_type',
      label: const BusinessCatalogLocalizedFields(
        nameUz: 'Xizmat turi',
        nameRu: 'Тип услуги',
        nameEn: 'Service type',
      ),
      valueKind: BusinessCatalogAttributeValueKind.text,
      textValue: 'in_store',
      numberValue: null,
      choiceValue: '',
      createdAt: now,
      updatedAt: now,
    ),
  ];
}

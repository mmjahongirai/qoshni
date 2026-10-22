import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_attribute_value_kind.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_listing_attribute.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_listing_kind.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_localized_fields.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_product.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_listing_searchable_text.dart';

void main() {
  final l10nEn = lookupAppLocalizations(const Locale('en'));
  final l10nRu = lookupAppLocalizations(const Locale('ru'));

  BusinessCatalogListingAttribute _attr({
    required String key,
    required String labelEn,
    required String value,
    BusinessCatalogAttributeValueKind kind = BusinessCatalogAttributeValueKind.text,
  }) {
    return BusinessCatalogListingAttribute(
      attributeId: 'attr-$key',
      listingKind: BusinessCatalogListingKind.product,
      listingId: 'demo-catalog-item-bread',
      businessScopeId: 'scope',
      dataSource: BusinessCatalogProductDataSource.demoSeed,
      key: key,
      label: BusinessCatalogLocalizedFields(nameEn: labelEn),
      valueKind: kind,
      textValue: kind == BusinessCatalogAttributeValueKind.text ? value : '',
      numberValue: kind == BusinessCatalogAttributeValueKind.number ? double.tryParse(value) : null,
      choiceValue: kind == BusinessCatalogAttributeValueKind.choice ? value : '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  test('builds deterministic searchable text', () {
    const localized = BusinessCatalogLocalizedFields(
      nameEn: 'Fresh bread',
      descriptionEn: 'Daily baked bread',
    );
    final input = CatalogListingSearchableTextInput(
      localized: localized,
      categoryDisplayName: 'Fresh goods',
      variantLabels: ['Large', 'Small'],
      variantSkus: ['SKU-B', 'SKU-A'],
      attributes: [
        _attr(key: 'unit', labelEn: 'Unit', value: 'loaf', kind: BusinessCatalogAttributeValueKind.choice),
      ],
    );
    final once = buildCatalogListingSearchableText(l10nEn, input);
    final twice = buildCatalogListingSearchableText(l10nEn, input);
    expect(once, twice);
    expect(once, contains('Fresh bread'));
    expect(once, contains('SKU-A'));
    expect(once, contains('loaf'));
    expect(once.indexOf('SKU-A'), lessThan(once.indexOf('Unit')));
  });

  test('locale fallback uses Russian name when locale is ru', () {
    const localized = BusinessCatalogLocalizedFields(
      nameUz: 'Non',
      nameRu: 'Хлеб',
      nameEn: 'Bread',
    );
    final text = buildCatalogListingSearchableText(
      l10nRu,
      const CatalogListingSearchableTextInput(localized: localized),
    );
    expect(text.startsWith('Хлеб'), isTrue);
  });

  test('collapses whitespace and skips duplicate consecutive fragments', () {
    const localized = BusinessCatalogLocalizedFields(nameEn: 'Fresh   bread');
    final text = buildCatalogListingSearchableText(
      l10nEn,
      CatalogListingSearchableTextInput(
        localized: localized,
        categoryDisplayName: 'Fresh bread',
        legacyProductAttributes: const [
          CatalogProductAttribute(key: 'unit', value: 'loaf'),
        ],
      ),
    );
    expect(text.contains('  '), isFalse);
    expect(text.split('Fresh bread').length, lessThanOrEqualTo(3));
  });
}

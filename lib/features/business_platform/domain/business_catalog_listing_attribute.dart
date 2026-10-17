import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_attribute_value_kind.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_listing_kind.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_localized_fields.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_product.dart';

class BusinessCatalogListingAttribute {
  const BusinessCatalogListingAttribute({
    required this.attributeId,
    required this.listingKind,
    required this.listingId,
    required this.businessScopeId,
    required this.dataSource,
    required this.key,
    required this.label,
    required this.valueKind,
    required this.textValue,
    required this.numberValue,
    required this.choiceValue,
    required this.createdAt,
    required this.updatedAt,
  });

  final String attributeId;
  final BusinessCatalogListingKind listingKind;
  final String listingId;
  final String businessScopeId;
  final BusinessCatalogProductDataSource dataSource;
  final String key;
  final BusinessCatalogLocalizedFields label;
  final BusinessCatalogAttributeValueKind valueKind;
  final String textValue;
  final double? numberValue;
  final String choiceValue;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isDemoSeed => dataSource == BusinessCatalogProductDataSource.demoSeed;

  String displayLabel(AppLocalizations l10n) => displayFromLocalized(label, l10n);

  String canonicalValueString() {
    switch (valueKind) {
      case BusinessCatalogAttributeValueKind.text:
        return textValue.trim();
      case BusinessCatalogAttributeValueKind.number:
        final n = numberValue;
        if (n == null) {
          return '';
        }
        if (n == n.roundToDouble()) {
          return n.round().toString();
        }
        return n.toString();
      case BusinessCatalogAttributeValueKind.choice:
        return choiceValue.trim();
    }
  }

  BusinessCatalogListingAttribute copyWith({
    String? key,
    BusinessCatalogLocalizedFields? label,
    BusinessCatalogAttributeValueKind? valueKind,
    String? textValue,
    double? numberValue,
    bool clearNumber = false,
    String? choiceValue,
    DateTime? updatedAt,
  }) {
    return BusinessCatalogListingAttribute(
      attributeId: attributeId,
      listingKind: listingKind,
      listingId: listingId,
      businessScopeId: businessScopeId,
      dataSource: dataSource,
      key: key ?? this.key,
      label: label ?? this.label,
      valueKind: valueKind ?? this.valueKind,
      textValue: textValue ?? this.textValue,
      numberValue: clearNumber ? null : (numberValue ?? this.numberValue),
      choiceValue: choiceValue ?? this.choiceValue,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class BusinessCatalogListingAttributeInput {
  const BusinessCatalogListingAttributeInput({
    required this.key,
    required this.label,
    required this.valueKind,
    required this.textValue,
    this.numberValue,
    required this.choiceValue,
  });

  final String key;
  final BusinessCatalogLocalizedFields label;
  final BusinessCatalogAttributeValueKind valueKind;
  final String textValue;
  final double? numberValue;
  final String choiceValue;
}

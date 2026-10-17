import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_listing_attribute.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_localized_fields.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_product.dart';

/// Derived search text — not persisted as authoritative catalog data.
class CatalogListingSearchableTextInput {
  const CatalogListingSearchableTextInput({
    required this.localized,
    this.categoryDisplayName,
    this.variantLabels = const [],
    this.variantSkus = const [],
    this.attributes = const [],
    this.legacyProductAttributes = const [],
  });

  final BusinessCatalogLocalizedFields localized;
  final String? categoryDisplayName;
  final List<String> variantLabels;
  final List<String> variantSkus;
  final List<BusinessCatalogListingAttribute> attributes;
  final List<CatalogProductAttribute> legacyProductAttributes;
}

String buildCatalogListingSearchableText(
  AppLocalizations l10n,
  CatalogListingSearchableTextInput input,
) {
  final fragments = <String>[];

  void addPart(String? raw) {
    final normalized = _normalizeFragment(raw);
    if (normalized.isEmpty) {
      return;
    }
    if (fragments.isNotEmpty && fragments.last == normalized) {
      return;
    }
    fragments.add(normalized);
  }

  addPart(displayFromLocalized(input.localized, l10n));
  addPart(_descriptionForLocale(input.localized, l10n));
  addPart(input.categoryDisplayName);

  final labels = [...input.variantLabels]..sort();
  for (final label in labels) {
    addPart(label);
  }
  final skus = [...input.variantSkus]..sort();
  for (final sku in skus) {
    addPart(sku);
  }

  final sortedAttributes = [...input.attributes]..sort((a, b) => a.key.compareTo(b.key));
  for (final attribute in sortedAttributes) {
    addPart(attribute.displayLabel(l10n));
    addPart(attribute.canonicalValueString());
  }

  for (final legacy in input.legacyProductAttributes) {
    addPart(legacy.key);
    addPart(legacy.value);
  }

  return fragments.join(' ');
}

String _normalizeFragment(String? raw) {
  if (raw == null) {
    return '';
  }
  return raw.trim().replaceAll(RegExp(r'\s+'), ' ');
}

String _descriptionForLocale(
  BusinessCatalogLocalizedFields localized,
  AppLocalizations l10n,
) {
  final locale = l10n.localeName;
  if (locale.startsWith('uz') && localized.descriptionUz.trim().isNotEmpty) {
    return localized.descriptionUz.trim();
  }
  if (locale.startsWith('ru') && localized.descriptionRu.trim().isNotEmpty) {
    return localized.descriptionRu.trim();
  }
  if (localized.descriptionEn.trim().isNotEmpty) {
    return localized.descriptionEn.trim();
  }
  if (localized.descriptionUz.trim().isNotEmpty) {
    return localized.descriptionUz.trim();
  }
  if (localized.descriptionRu.trim().isNotEmpty) {
    return localized.descriptionRu.trim();
  }
  return localized.descriptionEn.trim();
}

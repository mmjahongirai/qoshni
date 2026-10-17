import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_listing_status.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_localized_fields.dart';

enum BusinessCatalogProductDataSource {
  demoSeed,
  userSession,
}

class CatalogProductAttribute {
  const CatalogProductAttribute({required this.key, required this.value});

  final String key;
  final String value;
}

class BusinessCatalogProduct {
  const BusinessCatalogProduct({
    required this.productId,
    required this.businessScopeId,
    required this.categoryId,
    required this.dataSource,
    required this.status,
    required this.localized,
    required this.attributes,
    required this.createdAt,
    required this.updatedAt,
  });

  final String productId;
  final String businessScopeId;
  final String categoryId;
  final BusinessCatalogProductDataSource dataSource;
  final BusinessCatalogListingStatus status;
  final BusinessCatalogLocalizedFields localized;
  final List<CatalogProductAttribute> attributes;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isDemoSeed => dataSource == BusinessCatalogProductDataSource.demoSeed;

  String displayName(AppLocalizations l10n) =>
      _displayFromLocalized(localized, l10n);

  BusinessCatalogProduct copyWith({
    String? categoryId,
    BusinessCatalogListingStatus? status,
    BusinessCatalogLocalizedFields? localized,
    List<CatalogProductAttribute>? attributes,
    DateTime? updatedAt,
  }) {
    return BusinessCatalogProduct(
      productId: productId,
      businessScopeId: businessScopeId,
      categoryId: categoryId ?? this.categoryId,
      dataSource: dataSource,
      status: status ?? this.status,
      localized: localized ?? this.localized,
      attributes: attributes ?? this.attributes,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class BusinessCatalogProductInput {
  const BusinessCatalogProductInput({
    required this.categoryId,
    required this.localized,
    required this.status,
    required this.attributes,
  });

  final String categoryId;
  final BusinessCatalogLocalizedFields localized;
  final BusinessCatalogListingStatus status;
  final List<CatalogProductAttribute> attributes;
}

String displayFromLocalized(
  BusinessCatalogLocalizedFields localized,
  AppLocalizations l10n,
) {
  return _displayFromLocalized(localized, l10n);
}

String _displayFromLocalized(
  BusinessCatalogLocalizedFields localized,
  AppLocalizations l10n,
) {
  final locale = l10n.localeName;
  if (locale.startsWith('uz') && localized.nameUz.trim().isNotEmpty) {
    return localized.nameUz.trim();
  }
  if (locale.startsWith('ru') && localized.nameRu.trim().isNotEmpty) {
    return localized.nameRu.trim();
  }
  if (localized.nameEn.trim().isNotEmpty) {
    return localized.nameEn.trim();
  }
  if (localized.nameUz.trim().isNotEmpty) {
    return localized.nameUz.trim();
  }
  if (localized.nameRu.trim().isNotEmpty) {
    return localized.nameRu.trim();
  }
  return localized.nameEn.trim();
}

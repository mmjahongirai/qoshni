import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_category_status.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_localized_fields.dart';

enum BusinessCatalogCategoryDataSource {
  demoSeed,
  userSession,
}

class BusinessCatalogCategory {
  const BusinessCatalogCategory({
    required this.categoryId,
    required this.businessScopeId,
    required this.dataSource,
    required this.status,
    required this.localized,
    this.parentCategoryId,
    required this.createdAt,
    required this.updatedAt,
  });

  final String categoryId;
  final String businessScopeId;
  final BusinessCatalogCategoryDataSource dataSource;
  final BusinessCatalogCategoryStatus status;
  final BusinessCatalogLocalizedFields localized;
  final String? parentCategoryId;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isDemoSeed => dataSource == BusinessCatalogCategoryDataSource.demoSeed;

  String displayName(AppLocalizations l10n) {
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

  BusinessCatalogCategory copyWith({
    BusinessCatalogCategoryStatus? status,
    BusinessCatalogLocalizedFields? localized,
    String? parentCategoryId,
    bool clearParent = false,
    DateTime? updatedAt,
  }) {
    return BusinessCatalogCategory(
      categoryId: categoryId,
      businessScopeId: businessScopeId,
      dataSource: dataSource,
      status: status ?? this.status,
      localized: localized ?? this.localized,
      parentCategoryId: clearParent ? null : (parentCategoryId ?? this.parentCategoryId),
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class BusinessCatalogCategoryInput {
  const BusinessCatalogCategoryInput({
    required this.localized,
    required this.status,
    this.parentCategoryId,
  });

  final BusinessCatalogLocalizedFields localized;
  final BusinessCatalogCategoryStatus status;
  final String? parentCategoryId;
}

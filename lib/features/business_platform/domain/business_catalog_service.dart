import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_listing_status.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_localized_fields.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_product.dart';

enum BusinessCatalogServiceDataSource {
  demoSeed,
  userSession,
}

class BusinessCatalogService {
  const BusinessCatalogService({
    required this.serviceId,
    required this.businessScopeId,
    required this.categoryId,
    required this.dataSource,
    required this.status,
    required this.localized,
    this.durationMinutes,
    required this.createdAt,
    required this.updatedAt,
  });

  final String serviceId;
  final String businessScopeId;
  final String categoryId;
  final BusinessCatalogServiceDataSource dataSource;
  final BusinessCatalogListingStatus status;
  final BusinessCatalogLocalizedFields localized;
  final int? durationMinutes;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isDemoSeed => dataSource == BusinessCatalogServiceDataSource.demoSeed;

  String displayName(AppLocalizations l10n) =>
      displayFromLocalized(localized, l10n);

  BusinessCatalogService copyWith({
    String? categoryId,
    BusinessCatalogListingStatus? status,
    BusinessCatalogLocalizedFields? localized,
    int? durationMinutes,
    bool clearDuration = false,
    DateTime? updatedAt,
  }) {
    return BusinessCatalogService(
      serviceId: serviceId,
      businessScopeId: businessScopeId,
      categoryId: categoryId ?? this.categoryId,
      dataSource: dataSource,
      status: status ?? this.status,
      localized: localized ?? this.localized,
      durationMinutes:
          clearDuration ? null : (durationMinutes ?? this.durationMinutes),
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class BusinessCatalogServiceInput {
  const BusinessCatalogServiceInput({
    required this.categoryId,
    required this.localized,
    required this.status,
    this.durationMinutes,
  });

  final String categoryId;
  final BusinessCatalogLocalizedFields localized;
  final BusinessCatalogListingStatus status;
  final int? durationMinutes;
}

import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_listing_status.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_localized_fields.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_option.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_option_selection_mode.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_product.dart';

class BusinessCatalogOptionGroup {
  const BusinessCatalogOptionGroup({
    required this.groupId,
    required this.productId,
    required this.businessScopeId,
    required this.dataSource,
    required this.status,
    required this.localized,
    required this.description,
    required this.selectionMode,
    required this.required,
    required this.minSelections,
    required this.maxSelections,
    required this.options,
    required this.createdAt,
    required this.updatedAt,
  });

  final String groupId;
  final String productId;
  final String businessScopeId;
  final BusinessCatalogProductDataSource dataSource;
  final BusinessCatalogListingStatus status;
  final BusinessCatalogLocalizedFields localized;
  final BusinessCatalogLocalizedFields description;
  final BusinessCatalogOptionSelectionMode selectionMode;
  final bool required;
  final int minSelections;
  final int maxSelections;
  final List<BusinessCatalogOption> options;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isArchived => status == BusinessCatalogListingStatus.archived;

  int get activeOptionCount => options.where((o) => o.isActive).length;

  String displayName(AppLocalizations l10n) =>
      displayFromLocalized(localized, l10n);

  BusinessCatalogOptionGroup copyWith({
    BusinessCatalogListingStatus? status,
    BusinessCatalogLocalizedFields? localized,
    BusinessCatalogLocalizedFields? description,
    BusinessCatalogOptionSelectionMode? selectionMode,
    bool? required,
    int? minSelections,
    int? maxSelections,
    List<BusinessCatalogOption>? options,
    DateTime? updatedAt,
  }) {
    return BusinessCatalogOptionGroup(
      groupId: groupId,
      productId: productId,
      businessScopeId: businessScopeId,
      dataSource: dataSource,
      status: status ?? this.status,
      localized: localized ?? this.localized,
      description: description ?? this.description,
      selectionMode: selectionMode ?? this.selectionMode,
      required: required ?? this.required,
      minSelections: minSelections ?? this.minSelections,
      maxSelections: maxSelections ?? this.maxSelections,
      options: options ?? this.options,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class BusinessCatalogOptionGroupInput {
  const BusinessCatalogOptionGroupInput({
    required this.localized,
    required this.description,
    required this.selectionMode,
    required this.required,
    required this.minSelections,
    required this.maxSelections,
    this.status = BusinessCatalogListingStatus.active,
  });

  final BusinessCatalogLocalizedFields localized;
  final BusinessCatalogLocalizedFields description;
  final BusinessCatalogOptionSelectionMode selectionMode;
  final bool required;
  final int minSelections;
  final int maxSelections;
  final BusinessCatalogListingStatus status;
}

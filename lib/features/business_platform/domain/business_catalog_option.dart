import 'package:qoshni/features/business_platform/domain/business_catalog_localized_fields.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_product.dart';

class BusinessCatalogOption {
  const BusinessCatalogOption({
    required this.optionId,
    required this.groupId,
    required this.productId,
    required this.businessScopeId,
    required this.dataSource,
    required this.localized,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  final String optionId;
  final String groupId;
  final String productId;
  final String businessScopeId;
  final BusinessCatalogProductDataSource dataSource;
  final BusinessCatalogLocalizedFields localized;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  BusinessCatalogOption copyWith({
    BusinessCatalogLocalizedFields? localized,
    bool? isActive,
    DateTime? updatedAt,
  }) {
    return BusinessCatalogOption(
      optionId: optionId,
      groupId: groupId,
      productId: productId,
      businessScopeId: businessScopeId,
      dataSource: dataSource,
      localized: localized ?? this.localized,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class BusinessCatalogOptionInput {
  const BusinessCatalogOptionInput({required this.localized, this.isActive = true});

  final BusinessCatalogLocalizedFields localized;
  final bool isActive;
}

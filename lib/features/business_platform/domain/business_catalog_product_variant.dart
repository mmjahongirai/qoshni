import 'package:qoshni/features/business_platform/domain/business_catalog_listing_status.dart';

enum BusinessCatalogProductVariantDataSource {
  demoSeed,
  userSession,
}

class BusinessCatalogProductVariant {
  const BusinessCatalogProductVariant({
    required this.variantId,
    required this.productId,
    required this.businessScopeId,
    required this.dataSource,
    required this.label,
    required this.sku,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  final String variantId;
  final String productId;
  final String businessScopeId;
  final BusinessCatalogProductVariantDataSource dataSource;
  final String label;
  final String sku;
  final BusinessCatalogListingStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isDemoSeed =>
      dataSource == BusinessCatalogProductVariantDataSource.demoSeed;

  BusinessCatalogProductVariant copyWith({
    String? label,
    String? sku,
    BusinessCatalogListingStatus? status,
    DateTime? updatedAt,
  }) {
    return BusinessCatalogProductVariant(
      variantId: variantId,
      productId: productId,
      businessScopeId: businessScopeId,
      dataSource: dataSource,
      label: label ?? this.label,
      sku: sku ?? this.sku,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class BusinessCatalogProductVariantInput {
  const BusinessCatalogProductVariantInput({
    required this.label,
    required this.sku,
    required this.status,
  });

  final String label;
  final String sku;
  final BusinessCatalogListingStatus status;
}

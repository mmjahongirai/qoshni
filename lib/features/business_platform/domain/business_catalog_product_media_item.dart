import 'package:qoshni/features/business_platform/domain/business_catalog_product.dart';

enum BusinessCatalogProductMediaPreviewKind {
  demoPlaceholder,
  localSession,
}

class BusinessCatalogProductMediaItem {
  const BusinessCatalogProductMediaItem({
    required this.mediaId,
    required this.productId,
    required this.businessScopeId,
    required this.dataSource,
    required this.previewKind,
    required this.sortIndex,
    required this.isPrimary,
    required this.displayLabel,
    required this.createdAt,
    required this.updatedAt,
  });

  final String mediaId;
  final String productId;
  final String businessScopeId;
  final BusinessCatalogProductDataSource dataSource;
  final BusinessCatalogProductMediaPreviewKind previewKind;
  final int sortIndex;
  final bool isPrimary;
  final String displayLabel;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isDemoSeed => dataSource == BusinessCatalogProductDataSource.demoSeed;

  BusinessCatalogProductMediaItem copyWith({
    int? sortIndex,
    bool? isPrimary,
    String? displayLabel,
    DateTime? updatedAt,
  }) {
    return BusinessCatalogProductMediaItem(
      mediaId: mediaId,
      productId: productId,
      businessScopeId: businessScopeId,
      dataSource: dataSource,
      previewKind: previewKind,
      sortIndex: sortIndex ?? this.sortIndex,
      isPrimary: isPrimary ?? this.isPrimary,
      displayLabel: displayLabel ?? this.displayLabel,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

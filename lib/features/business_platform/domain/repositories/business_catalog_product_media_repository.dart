import 'dart:typed_data';

import 'package:qoshni/features/business_platform/domain/business_catalog_product_media_item.dart';

enum BusinessCatalogProductMediaSaveResult {
  success,
  notFound,
  invalidProduct,
  failure,
}

abstract class BusinessCatalogProductMediaRepository {
  String get businessScopeId;

  List<BusinessCatalogProductMediaItem> mediaForProduct(String productId);

  Uint8List? previewBytesForMedia(String mediaId);

  BusinessCatalogProductMediaSaveResult addLocalSessionPreview({
    required String productId,
    required Uint8List bytes,
    required String displayLabel,
  });

  BusinessCatalogProductMediaSaveResult setPrimary({
    required String productId,
    required String mediaId,
  });

  BusinessCatalogProductMediaSaveResult reorderMedia({
    required String productId,
    required List<String> orderedMediaIds,
  });

  BusinessCatalogProductMediaSaveResult removeSessionMedia(String mediaId);
}

import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_product_media_item.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_catalog_product_media_repository.dart';

class BusinessCatalogProductMediaController extends ChangeNotifier {
  BusinessCatalogProductMediaController(this._repository);

  final BusinessCatalogProductMediaRepository _repository;

  bool _saveBusy = false;

  bool get saveBusy => _saveBusy;

  List<BusinessCatalogProductMediaItem> mediaForProduct(String productId) =>
      _repository.mediaForProduct(productId);

  Uint8List? previewBytes(String mediaId) =>
      _repository.previewBytesForMedia(mediaId);

  void refresh() => notifyListeners();

  Future<BusinessCatalogProductMediaSaveResult> addLocalSessionPreview({
    required String productId,
    required Uint8List bytes,
    required String displayLabel,
  }) async {
    return _save(
      () => _repository.addLocalSessionPreview(
        productId: productId,
        bytes: bytes,
        displayLabel: displayLabel,
      ),
    );
  }

  Future<BusinessCatalogProductMediaSaveResult> setPrimary({
    required String productId,
    required String mediaId,
  }) async {
    return _save(
      () => _repository.setPrimary(productId: productId, mediaId: mediaId),
    );
  }

  Future<BusinessCatalogProductMediaSaveResult> reorderMedia({
    required String productId,
    required List<String> orderedMediaIds,
  }) async {
    return _save(
      () => _repository.reorderMedia(
        productId: productId,
        orderedMediaIds: orderedMediaIds,
      ),
    );
  }

  Future<BusinessCatalogProductMediaSaveResult> _save(
    BusinessCatalogProductMediaSaveResult Function() action,
  ) async {
    if (_saveBusy) {
      return BusinessCatalogProductMediaSaveResult.failure;
    }
    _saveBusy = true;
    notifyListeners();
    await Future<void>.delayed(Duration.zero);
    final result = action();
    _saveBusy = false;
    notifyListeners();
    return result;
  }
}

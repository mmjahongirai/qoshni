import 'dart:typed_data';

import 'package:qoshni/features/business_platform/data/business_catalog_product_media_demo_seed.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_product.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_product_media_item.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_catalog_product_media_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_catalog_product_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_owner_profile_repository.dart';

class InMemoryBusinessCatalogProductMediaRepository
    implements BusinessCatalogProductMediaRepository {
  InMemoryBusinessCatalogProductMediaRepository(
    this._ownerProfileRepository,
    this._productRepository,
  );

  final BusinessOwnerProfileRepository _ownerProfileRepository;
  final BusinessCatalogProductRepository _productRepository;

  final Map<String, List<BusinessCatalogProductMediaItem>> _mediaByScope = {};
  final Map<String, Uint8List> _sessionPreviewBytes = {};
  int _userMediaCounter = 0;

  bool failNextSave = false;

  @override
  String get businessScopeId =>
      _ownerProfileRepository.ensureSessionProfile().sessionProfileId;

  @override
  List<BusinessCatalogProductMediaItem> mediaForProduct(String productId) {
    if (!_productInScope(productId)) {
      return const [];
    }
    final items = _ensureScopeList()
        .where((m) => m.productId == productId)
        .toList()
      ..sort((a, b) => a.sortIndex.compareTo(b.sortIndex));
    return List.unmodifiable(items);
  }

  @override
  Uint8List? previewBytesForMedia(String mediaId) {
    return _sessionPreviewBytes[mediaId];
  }

  @override
  BusinessCatalogProductMediaSaveResult addLocalSessionPreview({
    required String productId,
    required Uint8List bytes,
    required String displayLabel,
  }) {
    if (failNextSave) {
      failNextSave = false;
      return BusinessCatalogProductMediaSaveResult.failure;
    }
    if (!_productInScope(productId)) {
      return BusinessCatalogProductMediaSaveResult.invalidProduct;
    }
    if (bytes.isEmpty) {
      return BusinessCatalogProductMediaSaveResult.failure;
    }
    final now = DateTime.now();
    _userMediaCounter++;
    final mediaId = 'session-catalog-media-$_userMediaCounter';
    final list = _ensureScopeList();
    final existing = list.where((m) => m.productId == productId).toList();
    final isFirst = existing.isEmpty;
    list.add(
      BusinessCatalogProductMediaItem(
        mediaId: mediaId,
        productId: productId.trim(),
        businessScopeId: businessScopeId,
        dataSource: BusinessCatalogProductDataSource.userSession,
        previewKind: BusinessCatalogProductMediaPreviewKind.localSession,
        sortIndex: existing.length,
        isPrimary: isFirst,
        displayLabel: displayLabel.trim().isEmpty ? 'image' : displayLabel.trim(),
        createdAt: now,
        updatedAt: now,
      ),
    );
    _sessionPreviewBytes[mediaId] = bytes;
    return BusinessCatalogProductMediaSaveResult.success;
  }

  @override
  BusinessCatalogProductMediaSaveResult setPrimary({
    required String productId,
    required String mediaId,
  }) {
    final list = _ensureScopeList();
    final productMedia =
        list.where((m) => m.productId == productId.trim()).toList();
    if (productMedia.every((m) => m.mediaId != mediaId)) {
      return BusinessCatalogProductMediaSaveResult.notFound;
    }
    for (var i = 0; i < list.length; i++) {
      final item = list[i];
      if (item.productId != productId.trim()) {
        continue;
      }
      list[i] = item.copyWith(
        isPrimary: item.mediaId == mediaId,
        updatedAt: DateTime.now(),
      );
    }
    return BusinessCatalogProductMediaSaveResult.success;
  }

  @override
  BusinessCatalogProductMediaSaveResult reorderMedia({
    required String productId,
    required List<String> orderedMediaIds,
  }) {
    final list = _ensureScopeList();
    final productMedia =
        list.where((m) => m.productId == productId.trim()).toList();
    if (productMedia.length != orderedMediaIds.length) {
      return BusinessCatalogProductMediaSaveResult.failure;
    }
    final idSet = productMedia.map((m) => m.mediaId).toSet();
    if (!orderedMediaIds.every(idSet.contains)) {
      return BusinessCatalogProductMediaSaveResult.failure;
    }
    for (var index = 0; index < orderedMediaIds.length; index++) {
      final mediaId = orderedMediaIds[index];
      final i = list.indexWhere((m) => m.mediaId == mediaId);
      if (i >= 0) {
        list[i] = list[i].copyWith(
          sortIndex: index,
          updatedAt: DateTime.now(),
        );
      }
    }
    return BusinessCatalogProductMediaSaveResult.success;
  }

  @override
  BusinessCatalogProductMediaSaveResult removeSessionMedia(String mediaId) {
    final list = _ensureScopeList();
    final index = list.indexWhere((m) => m.mediaId == mediaId);
    if (index < 0) {
      return BusinessCatalogProductMediaSaveResult.notFound;
    }
    final item = list[index];
    if (item.dataSource != BusinessCatalogProductDataSource.userSession) {
      return BusinessCatalogProductMediaSaveResult.failure;
    }
    final wasPrimary = item.isPrimary;
    final productId = item.productId;
    list.removeAt(index);
    _sessionPreviewBytes.remove(mediaId);
    if (wasPrimary) {
      final remaining = list.where((m) => m.productId == productId).toList()
        ..sort((a, b) => a.sortIndex.compareTo(b.sortIndex));
      if (remaining.isNotEmpty) {
        setPrimary(productId: productId, mediaId: remaining.first.mediaId);
      }
    }
    return BusinessCatalogProductMediaSaveResult.success;
  }

  bool _productInScope(String productId) {
    final product = _productRepository.findById(productId.trim());
    return product != null && product.businessScopeId == businessScopeId;
  }

  List<BusinessCatalogProductMediaItem> _ensureScopeList() {
    final scope = businessScopeId;
    return _mediaByScope.putIfAbsent(
      scope,
      () => buildDemoCatalogProductMedia(businessScopeId: scope),
    );
  }
}

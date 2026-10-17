import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/core/config/app_config.dart';
import 'package:qoshni/core/config/app_environment.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/features/business_platform/data/business_catalog_product_demo_seed.dart';
import 'package:qoshni/features/business_platform/data/business_catalog_product_media_demo_seed.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_catalog_product_media_repository.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_product_media_item.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_catalog_product_media_repository.dart';

void main() {
  setUp(() async {
    await configureDependencies(
      AppConfig.forEnvironment(AppEnvironment.development),
    );
  });

  tearDown(() async {
    await getIt.reset();
  });

  test('demo media uses placeholder preview without bytes', () {
    final repo = getIt<BusinessCatalogProductMediaRepository>();
    final items = repo.mediaForProduct(kDemoCatalogProductBreadId);
    expect(items.length, 1);
    expect(items.first.mediaId, kDemoCatalogMediaBreadPrimaryId);
    expect(items.first.previewKind, BusinessCatalogProductMediaPreviewKind.demoPlaceholder);
    expect(repo.previewBytesForMedia(items.first.mediaId), isNull);
  });

  test('local session preview stores bytes in memory only', () {
    final repo = getIt<BusinessCatalogProductMediaRepository>()
        as InMemoryBusinessCatalogProductMediaRepository;
    final bytes = Uint8List.fromList([1, 2, 3, 4]);
    final result = repo.addLocalSessionPreview(
      productId: kDemoCatalogProductPlovId,
      bytes: bytes,
      displayLabel: 'plov.png',
    );
    expect(result, BusinessCatalogProductMediaSaveResult.success);
    final items = repo.mediaForProduct(kDemoCatalogProductPlovId);
    expect(items.length, 1);
    expect(items.first.isPrimary, isTrue);
    expect(repo.previewBytesForMedia(items.first.mediaId), bytes);
  });

  test('setPrimary switches primary flag', () {
    final repo = getIt<BusinessCatalogProductMediaRepository>();
    repo.addLocalSessionPreview(
      productId: kDemoCatalogProductPlovId,
      bytes: Uint8List.fromList([9]),
      displayLabel: 'a.png',
    );
    repo.addLocalSessionPreview(
      productId: kDemoCatalogProductPlovId,
      bytes: Uint8List.fromList([8]),
      displayLabel: 'b.png',
    );
    final items = repo.mediaForProduct(kDemoCatalogProductPlovId);
    final secondId = items.last.mediaId;
    expect(repo.setPrimary(productId: kDemoCatalogProductPlovId, mediaId: secondId),
        BusinessCatalogProductMediaSaveResult.success);
    final updated = repo.mediaForProduct(kDemoCatalogProductPlovId);
    expect(updated.where((m) => m.isPrimary).single.mediaId, secondId);
  });

  test('reorder updates sort indices', () {
    final repo = getIt<BusinessCatalogProductMediaRepository>();
    repo.addLocalSessionPreview(
      productId: kDemoCatalogProductPlovId,
      bytes: Uint8List.fromList([1]),
      displayLabel: '1.png',
    );
    repo.addLocalSessionPreview(
      productId: kDemoCatalogProductPlovId,
      bytes: Uint8List.fromList([2]),
      displayLabel: '2.png',
    );
    var items = repo.mediaForProduct(kDemoCatalogProductPlovId);
    final ids = items.map((m) => m.mediaId).toList().reversed.toList();
    expect(
      repo.reorderMedia(productId: kDemoCatalogProductPlovId, orderedMediaIds: ids),
      BusinessCatalogProductMediaSaveResult.success,
    );
    items = repo.mediaForProduct(kDemoCatalogProductPlovId);
    expect(items.first.mediaId, ids.first);
  });

  test('invalid product id rejected', () {
    final repo = getIt<BusinessCatalogProductMediaRepository>();
    final result = repo.addLocalSessionPreview(
      productId: 'not-in-scope',
      bytes: Uint8List.fromList([1]),
      displayLabel: 'x.png',
    );
    expect(result, BusinessCatalogProductMediaSaveResult.invalidProduct);
  });
}

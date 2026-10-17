import 'package:qoshni/features/business_platform/domain/business_catalog_demo_item.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_listing_status.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_catalog_demo_item_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_catalog_product_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_catalog_service_repository.dart';

/// Aggregates product/service preview data for stats and category delete guards.
class InMemoryBusinessCatalogOverviewRepository
    implements BusinessCatalogDemoItemRepository {
  InMemoryBusinessCatalogOverviewRepository(
    this._productRepository,
    this._serviceRepository,
  );

  final BusinessCatalogProductRepository _productRepository;
  final BusinessCatalogServiceRepository _serviceRepository;

  @override
  String get businessScopeId => _productRepository.businessScopeId;

  @override
  int countItemsReferencingCategory(String categoryId) {
    return _productRepository.countReferencingCategory(categoryId) +
        _serviceRepository.countReferencingCategory(categoryId);
  }

  @override
  BusinessCatalogOverviewStats overviewStatsForScope({
    required int categoryCount,
  }) {
    var active = 0;
    var draft = 0;
    var archived = 0;
    for (final product in _productRepository.listForCurrentScope()) {
      switch (product.status) {
        case BusinessCatalogListingStatus.active:
          active++;
        case BusinessCatalogListingStatus.draft:
          draft++;
        case BusinessCatalogListingStatus.archived:
          archived++;
      }
    }
    for (final service in _serviceRepository.listForCurrentScope()) {
      switch (service.status) {
        case BusinessCatalogListingStatus.active:
          active++;
        case BusinessCatalogListingStatus.draft:
          draft++;
        case BusinessCatalogListingStatus.archived:
          archived++;
      }
    }
    return BusinessCatalogOverviewStats(
      categoryCount: categoryCount,
      productCount: _productRepository.listForCurrentScope().length,
      serviceCount: _serviceRepository.listForCurrentScope().length,
      activeItemCount: active,
      draftItemCount: draft,
      archivedItemCount: archived,
    );
  }
}

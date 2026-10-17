import 'package:qoshni/features/business_platform/data/business_catalog_demo_item_seed.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_demo_item.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_catalog_demo_item_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_owner_profile_repository.dart';

class InMemoryBusinessCatalogDemoItemRepository
    implements BusinessCatalogDemoItemRepository {
  InMemoryBusinessCatalogDemoItemRepository(this._ownerProfileRepository);

  final BusinessOwnerProfileRepository _ownerProfileRepository;

  final Map<String, List<BusinessCatalogDemoItem>> _itemsByScope = {};

  @override
  String get businessScopeId =>
      _ownerProfileRepository.ensureSessionProfile().sessionProfileId;

  @override
  List<BusinessCatalogDemoItem> listForCurrentScope() {
    return List.unmodifiable(_ensureScopeList());
  }

  @override
  int countItemsReferencingCategory(String categoryId) {
    return _ensureScopeList()
        .where((item) => item.categoryId == categoryId)
        .length;
  }

  @override
  BusinessCatalogOverviewStats overviewStatsForScope({
    required int categoryCount,
  }) {
    final items = _ensureScopeList();
    var products = 0;
    var services = 0;
    var active = 0;
    var draft = 0;
    for (final item in items) {
      if (item.isProduct) {
        products++;
      } else if (item.isService) {
        services++;
      }
      if (item.status == BusinessCatalogDemoItemStatus.active) {
        active++;
      } else {
        draft++;
      }
    }
    return BusinessCatalogOverviewStats(
      categoryCount: categoryCount,
      productCount: products,
      serviceCount: services,
      activeItemCount: active,
      draftItemCount: draft,
    );
  }

  List<BusinessCatalogDemoItem> _ensureScopeList() {
    final scope = businessScopeId;
    return _itemsByScope.putIfAbsent(
      scope,
      () => buildDemoCatalogItems(businessScopeId: scope),
    );
  }
}

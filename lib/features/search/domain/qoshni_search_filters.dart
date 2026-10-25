import 'package:qoshni/features/home/presentation/data/service_category_id.dart';
import 'package:qoshni/features/search/domain/qoshni_search_location.dart';

class QoshniSearchFilters {
  const QoshniSearchFilters({
    this.categoryScope,
    this.onlyOpen = false,
    this.maxDistanceMeters,
    this.searchLocation,
  });

  final ServiceCategoryId? categoryScope;
  final bool onlyOpen;
  final int? maxDistanceMeters;
  final QoshniSearchLocation? searchLocation;
}

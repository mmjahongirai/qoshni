import 'package:qoshni/features/search/domain/qoshni_search_location.dart';

/// Verified branch pin for map rendering (from search read model only).
class QoshniMapBranchMarker {
  const QoshniMapBranchMarker({
    required this.stableId,
    required this.title,
    required this.location,
  });

  final String stableId;
  final String title;
  final QoshniSearchLocation location;
}

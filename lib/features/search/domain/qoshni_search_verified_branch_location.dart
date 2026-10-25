import 'package:qoshni/features/search/domain/qoshni_search_location.dart';

/// Verified branch coordinates returned by the search read model (not GPS).
class QoshniSearchVerifiedBranchLocation {
  const QoshniSearchVerifiedBranchLocation({
    required this.searchLocation,
  });

  final QoshniSearchLocation searchLocation;
}

import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/features/search/data/qoshni_search_remote_dtos.dart';

void main() {
  test('remote dto parses verified branch coordinates', () {
    final dto = QoshniSearchRemoteResultItemDto.fromJson({
      'stable_id': 'business:onboarding:abc',
      'kind': 'business',
      'title': 'Shop',
      'is_sponsored': false,
      'branch_latitude': 41.31,
      'branch_longitude': 69.28,
    });
    expect(dto.branchLatitude, 41.31);
    expect(dto.branchLongitude, 69.28);
  });
}

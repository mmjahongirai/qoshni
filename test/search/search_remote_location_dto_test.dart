import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/features/search/data/qoshni_search_remote_dtos.dart';

void main() {
  test('remote discovery dto includes optional coordinates', () {
    final json = const QoshniSearchRemoteRequestDto(
      query: 'apteka',
      maxDistanceMeters: 5000,
      searchLatitude: 41.31,
      searchLongitude: 69.28,
    ).toJson();

    expect(json['search_latitude'], 41.31);
    expect(json['search_longitude'], 69.28);
    expect(json['max_distance_meters'], 5000);
  });
}

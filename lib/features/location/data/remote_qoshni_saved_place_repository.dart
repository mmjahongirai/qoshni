import 'package:dio/dio.dart';
import 'package:qoshni/core/network/api_client.dart';
import 'package:qoshni/features/location/data/saved_place_dtos.dart';
import 'package:qoshni/features/location/domain/qoshni_geo_coordinates.dart';
import 'package:qoshni/features/location/domain/qoshni_saved_place.dart';
import 'package:qoshni/features/location/domain/repositories/qoshni_saved_place_repository.dart';

class RemoteQoshniSavedPlaceRepository implements QoshniSavedPlaceRepository {
  RemoteQoshniSavedPlaceRepository({
    required ApiClient apiClient,
    required this.accessTokenProvider,
    required this.ownerUserId,
  }) : _dio = apiClient.dio;

  final Dio _dio;
  final Future<String?> Function() accessTokenProvider;
  final String ownerUserId;

  Future<Map<String, String>> _headers() async {
    final token = await accessTokenProvider();
    if (token == null || token.isEmpty) {
      throw StateError('Authentication required for saved places');
    }
    return {'Authorization': 'Bearer $token'};
  }

  QoshniSavedPlace _map(SavedPlaceRemoteDto dto) {
    final coordinates = QoshniGeoCoordinates.tryCreate(
      latitude: dto.latitude,
      longitude: dto.longitude,
    );
    if (coordinates == null) {
      throw StateError('Invalid saved place coordinates from server');
    }
    return QoshniSavedPlace(
      id: dto.id,
      ownerUserId: ownerUserId,
      label: dto.label,
      coordinates: coordinates,
      addressDescription: dto.addressDescription,
    );
  }

  @override
  Future<List<QoshniSavedPlace>> listForCurrentUser() async {
    final response = await _dio.get<List<dynamic>>(
      '/api/v1/saved-places',
      options: Options(headers: await _headers()),
    );
    final raw = response.data ?? const [];
    return raw
        .map(
          (item) => _map(
            SavedPlaceRemoteDto.fromJson(item as Map<String, dynamic>),
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<QoshniSavedPlace> create({
    required String label,
    required QoshniGeoCoordinates coordinates,
    String? addressDescription,
  }) async {
    final dto = SavedPlaceRemoteDto(
      id: '',
      label: label,
      latitude: coordinates.latitude,
      longitude: coordinates.longitude,
      addressDescription: addressDescription,
    );
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/v1/saved-places',
      data: dto.toCreateJson(
        label: label,
        latitude: coordinates.latitude,
        longitude: coordinates.longitude,
        addressDescription: addressDescription,
      ),
      options: Options(headers: await _headers()),
    );
    return _map(SavedPlaceRemoteDto.fromJson(response.data ?? {}));
  }

  @override
  Future<QoshniSavedPlace> update({
    required String placeId,
    String? label,
    QoshniGeoCoordinates? coordinates,
    String? addressDescription,
    bool clearAddressDescription = false,
  }) async {
    final dto = SavedPlaceRemoteDto(id: placeId, label: label ?? '', latitude: 0, longitude: 0);
    final response = await _dio.patch<Map<String, dynamic>>(
      '/api/v1/saved-places/$placeId',
      data: dto.toUpdateJson(
        label: label,
        latitude: coordinates?.latitude,
        longitude: coordinates?.longitude,
        addressDescription: addressDescription,
        clearAddressDescription: clearAddressDescription,
      ),
      options: Options(headers: await _headers()),
    );
    return _map(SavedPlaceRemoteDto.fromJson(response.data ?? {}));
  }

  @override
  Future<void> delete({required String placeId}) async {
    await _dio.delete<void>(
      '/api/v1/saved-places/$placeId',
      options: Options(headers: await _headers()),
    );
  }
}
